#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false)][String]$priority = "30",
    [Parameter(Mandatory=$false)][String]$phase = "run"
)
$script_token = "$($phase)-phase"
Write-Host "###### BEGIN RUN PHASE ######"

$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib")
Import-Module -Name "$($module_path)/fieldsets.psm1"

Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
# Ordered plugins by priority
$plugins_priority_list = getPluginPriorityList
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

if (!(Test-Path -Path "$($log_path)/$($script_token).log")) {
    New-Item -Path "$($log_path)" -Name "$($script_token).log" -ItemType File | Out-Null
}
$stdErrLog = "/data/logs/$($script_token).stderr.log"
$stdOutLog = "/data/logs/$($script_token).stdout.log"

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
                    $processOptions = @{
                        Filepath = "$($plugin.FullName)/$($phase).sh"
                        RedirectStandardInput = "/dev/null"
                        RedirectStandardError = $stdErrLog
                        RedirectStandardOutput = $stdOutLog
                    }
                    Start-Process @processOptions
                }
            }
        }
    }
}
Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null

Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "$($log_path)/$($script_token).log" -Append
Exit