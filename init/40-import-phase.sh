#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][String]$priority = "40",
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "import"
)
$script_token = "$($phase)-phase"
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/pwsh")
Import-Module -Function isPluginPhaseContainer, buildPluginPriortyList -Name "$($module_path)/plugins.psm1"

Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
# Ordered plugins by priority
$plugins_priority_list = buildPluginPriortyList
foreach ($plugin_dirs in $plugins_priority_list.Values) {
    foreach ($plugin_dir in $plugin_dirs) {
        if ($null -ne $plugin_dir) {
            $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
            if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                Write-Host "Pre $($phase) phase for plugin: $($plugin.BaseName)"
                if (Test-Path -Path "$($plugin.FullName)/import.sh") {
                    Set-Location -Path "$($plugin.FullName)" | Out-Null
                    chmod +x "$($plugin.FullName)/import.sh" | Out-Null
                    & "bash" -c "exec `"$($plugin.FullName)/import.sh`" -preimport"
                }
            }
        }
    }
}
[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null
Exit
