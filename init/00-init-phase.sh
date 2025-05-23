#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false)][String]$priority = "00",
    [Parameter(Mandatory=$false)][String]$phase = "init"
)

<##
 # Init scripts are run only once. Usually on the first server start up.
 # Plugins that are added after the first install will have init scripts run at the first restart or can be manually triggered by running this script directly.
 # Scripts are flagged with a lockfile after they are run successfully.
 # If you need to rerun and init script you can delete the corresponding file found in /$lockfile_path/init
 ##>

[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $null)
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $null)

Write-Host "###### BEGIN INIT PHASE ######"

$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/pwsh")
Import-Module -Function lockfileExists, createLockfile -Name "$($module_path)/utils.psm1"
Import-Module -Function checkDependencies, isPluginPhaseContainer, getPluginPriorityList -Name "$($module_path)/plugins.psm1"

$script_token = "$($phase)-phase"
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$dotnet_ver = [System.Environment]::GetEnvironmentVariable('DOTNET_VERSION')

$cache_type = [System.Environment]::GetEnvironmentVariable('FIELDSETS_CACHE')

$lockfile_path = "/usr/local/fieldsets/data/checkpoints/$($envname)/$($hostname)/phases/"
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

# Create our path if it does not exist
if (!(Test-Path -Path "/usr/local/fieldsets/data/checkpoints/")) {
    # Its our first run. So lets display a message
    Write-Host "Fieldsets Framework is initializing. This first startup may take a while to install any missing libraries and modules."
    New-Item -Path "/usr/local/fieldsets/data" -Name "checkpoints" -ItemType Directory | Out-Null
}
if (!(Test-Path -Path "/usr/local/fieldsets/data/checkpoints/$($envname)")) {
    New-Item -Path "/usr/local/fieldsets/data/checkpoints" -Name "$($envname)" -ItemType Directory | Out-Null
}
if (!(Test-Path -Path "/usr/local/fieldsets/data/checkpoints/$($envname)/$($hostname)")) {
    New-Item -Path "/usr/local/fieldsets/data/checkpoints/$($envname)" -Name "$($hostname)" -ItemType Directory | Out-Null
}
if (!(Test-Path -Path "$($lockfile_path)")) {
    New-Item -Path "/usr/local/fieldsets/data/checkpoints/$($envname)/$($hostname)" -Name "phases" -ItemType Directory | Out-Null
}
if (!(Test-Path -Path "$($lockfile_path)/$($phase)/")) {
    New-Item -Path "$($lockfile_path)" -Name "$($phase)" -ItemType Directory | Out-Null
}

# Create our log path
if (!(Test-Path -Path "/usr/local/fieldsets/data/logs/")) {
    New-Item -Path "/usr/local/fieldsets/data" -Name "logs" -ItemType Directory | Out-Null
}

if (!(Test-Path -Path "/usr/local/fieldsets/data/logs/$($envname)")) {
    New-Item -Path "/usr/local/fieldsets/data/logs" -Name "$($envname)" -ItemType Directory | Out-Null
}

if (!(Test-Path -Path "$($log_path)")) {
    New-Item -Path "/usr/local/fieldsets/data/logs/$($envname)" -Name "$($hostname)" -ItemType Directory | Out-Null
}

if (!(Test-Path -Path "$($log_path)/$($script_token).log")) {
    New-Item -Path "$($log_path)" -Name "$($script_token).log" -ItemType File | Out-Null
}

# Install dependencies
# Check if we are using the default memcached cache and install if necessary.
Write-Host $cache_type
if ($cache_type -eq 'memcached') {
    $lockfile = "$($priority)-$($cache_type).$($phase).complete"
    if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
        $stdErrLog = "/data/logs/$($cache_type).stderr.log"
        $stdOutLog = "/data/logs/$($cache_type).stdout.log"
        $processOptions = @{
            Filepath = "apt-get"
            ArgumentList = "install -y --no-install-recommends memcached libmemcached-tools"
            RedirectStandardInput = "/dev/null"
            RedirectStandardError = $stdErrLog
            RedirectStandardOutput = $stdOutLog
        }
        Start-Process @processOptions -Wait
        Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "$($log_path)/$($script_token).log" -Append

        createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    }
}

# Install libraries
try {
    Get-Module -ListAvailable -Name ImportExcel
} catch {
    Install-Module ImportExcel -Scope AllUsers -Force -AllowClobber | Out-Null
}

try {
    Get-Package -Name ClickHouse.Client
} catch {
    Install-Package ClickHouse.Client -Source NuGet.org -Scope AllUsers -Force -AllowClobber | Out-Null
}

try {
    Get-Package -Name Npgsql | Out-Null
} catch {
    Install-Package Npgsql -Source NuGet.org -Scope AllUsers -Force -AllowClobber | Out-Null
}

try {
    Get-Package -Name Microsoft.Extensions.Logging.Abstractions -RequiredVersion "$($dotnet_ver).0.0" | Out-Null
} catch {
    Install-Package Microsoft.Extensions.Logging.Abstractions -RequiredVersion "${DOTNET_VERSION}.0.0" -Source NuGet.org -Scope AllUsers -Force | Out-Null
}

# Check to make sure all plugin dependencies are met.
$dependencies_met = checkDependencies
if ($dependencies_met) {
    Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
    # Ordered plugins by priority
    $plugins_priority_list = getPluginPriorityList
    foreach ($plugin_dirs in $plugins_priority_list.Values) {
        foreach ($plugin_dir in $plugin_dirs) {
            if ($null -ne $plugin_dir) {
                $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
                Write-Host "Checking Plugin: $($plugin.BaseName)"
                if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                    Write-Host "$($phase) phase for plugin: $($plugin.BaseName)"
                    if (Test-Path -Path "$($plugin.FullName)/$($phase).sh") {
                        $lockfile = "$($priority)-plugin-$($plugin.Name).$($phase).complete"
                        if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
                            Set-Location -Path "$($plugin.FullName)" | Out-Null
                            chmod +x "$($plugin.FullName)/$($phase).sh" | Out-Null
                            $stdErrLog = "/data/logs/$($script_token).stderr.log"
                            $stdOutLog = "/data/logs/$($script_token).stdout.log"
                            $processOptions = @{
                                Filepath = "$($plugin.FullName)/$($phase).sh"
                                RedirectStandardInput = "/dev/null"
                                RedirectStandardError = $stdErrLog
                                RedirectStandardOutput = $stdOutLog
                            }
                            Start-Process @processOptions -Wait
                            Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "$($log_path)/$($script_token).log" -Append

                            createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
                        }
                    }
                }
            }
        }
    }
    [System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token)
    [System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority)
} else {
    if ($false -eq $dependencies_met) {
        Throw "Missing Dependencies"
    }
}
Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null

Write-Host "###### END INIT PHASE ######"
