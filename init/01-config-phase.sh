#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][Int]$priority = 1,
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "config"
)
$script_token = "$($phase)-phase"
$utils_module_path = [System.IO.Path]::GetFullPath("/fieldsets-lib/pwsh/")
Import-Module -Function isPluginPhaseContainer -Name "$($utils_module_path)/plugins.psm1"

Set-Location -Path "/fieldsets-plugins/" | Out-Null
$plugin_dirs = Get-ChildItem -Path "/fieldsets-plugins/*" -Directory | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
# Only run config phase for plugin if on correct container.
foreach ($plugin in $plugin_dirs) {
    if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
        Write-Host "$($phase) Phase for Plugin: $($plugin.BaseName)"
        if (Test-Path -Path "$($plugin.FullName)/config.sh") {
            Write-Information -MessageData "Configuring plugin $($plugin.FullName)" -InformationAction Continue
            Set-Location -Path "$($plugin.FullName)" | Out-Null
            chmod +x "$($plugin.FullName)/config.sh"
            & "bash" -c "exec `"$($plugin.FullName)/config.sh`""
        }
    }
}
[Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
[Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
Set-Location -Path "/fieldsets/" | Out-Null
Exit
Exit-PSHostProcess