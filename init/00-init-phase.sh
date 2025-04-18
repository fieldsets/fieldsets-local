#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][String]$priority = "00",
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "init"
)
<##
 # Init scripts are run only once. Usually on the first server start up.
 # Plugins that are added after the first install will have init scripts run at the first restart or can be manually triggered by running this script directly.
 # Scripts are flagged with a lockfile after they are run successfully.
 # If you need to rerun and init script you can delete the corresponding file found in /$lockfile_path/init
 ##>
[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $null, "User")
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $null, "User")

$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/pwsh")
Import-Module -Function lockfileExists, createLockfile -Name "$($module_path)/utils.psm1"
Import-Module -Function checkDependencies, isPluginPhaseContainer, buildPluginPriortyList -Name "$($module_path)/plugins.psm1"

$script_token = "$($phase)-phase"
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$lockfile_path = "/usr/local/fieldsets/data/checkpoints/$($envname)/$($hostname)/phases/"

# Create our path if it does not exist
if (!(Test-Path -Path "/usr/local/fieldsets/data/checkpoints/")) {
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
# Check to make sure all plugin dependencies are met.
$dependencies_met = checkDependencies
if ($dependencies_met) {
    Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
    # Ordered plugins by priority
    $plugins_priority_list = buildPluginPriortyList
    foreach ($plugin_dirs in $plugins_priority_list.Values) {
        foreach ($plugin_dir in $plugin_dirs) {
            if ($null -ne $plugin_dir) {
                $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
                Write-Host "Checking Plugin: $($plugin.BaseName)"
                if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                    Write-Host "$($phase) phase for plugin: $($plugin.BaseName)"
                    if (Test-Path -Path "$($plugin.FullName)/init.sh") {
                        $lockfile = "$($priority)-plugin-$($plugin.Name).$($phase).complete"
                        if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
                            Set-Location -Path "$($plugin.FullName)" | Out-Null
                            chmod +x "$($plugin.FullName)/init.sh" | Out-Null
                            & "bash" -c "exec `"$($plugin.FullName)/init.sh`""
                            createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
                        }
                    }
                }
            }
        }
    }
    [System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
    [System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
} else {
    if ($false -eq $dependencies_met) {
        Throw "Missing Dependencies"
    }
}
Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null
Exit
