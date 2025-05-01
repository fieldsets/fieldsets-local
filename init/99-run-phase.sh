#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][String]$priority = "99",
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "run"
)
$script_token = "$($phase)-phase"
Write-Host "###### BEGIN RUN PHASE ######"

$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/pwsh")
Import-Module -Function isPluginPhaseContainer, buildPluginPriortyList -Name "$($module_path)/plugins.psm1"

Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
# Ordered plugins by priority
$plugins_priority_list = buildPluginPriortyList
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

if (!(Test-Path -Path "$($log_path)/$($script_token).log")) {
    New-Item -Path "$($log_path)" -Name "$($script_token).log" -ItemType File | Out-Null
}

# Create a Powershell session which all of our framework code will be executed in.
foreach ($plugin_dirs in $plugins_priority_list.Values) {
    foreach ($plugin_dir in $plugin_dirs) {
        if ($null -ne $plugin_dir) {
            $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
            if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                Write-Host "$($phase) phase for plugin: $($plugin.BaseName)"
                if (Test-Path -Path "$($plugin.FullName)/$($phase).sh") {
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
                    Start-Process @processOptions
                    Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "$($log_path)/$($script_token).log" -Append
                }
            }
        }
    }
}
[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token)
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority)

Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null
Exit
