#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][Int]$priority = 1,
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "config"
)
$script_token = "$($phase)-phase"

Set-Location -Path "/fieldsets-plugins/"
$plugin_dirs = Get-ChildItem -Path "/fieldsets-plugins/*" -Directory |
Select-Object FullName, Name, LastWriteTime, CreationTime
# Check to make sure all plugin dependencies are met.
foreach ($plugin in $plugin_dirs) {
    if (Test-Path -Path "$($plugin.FullName)/config.sh") {
        Write-Information -MessageData "Configuring plugin $($plugin.FullName)" -InformationAction Continue
        Set-Location -Path "$($plugin.FullName)"
        chmod +x "$($plugin.FullName)/config.sh"
        & "bash" -c "exec `"$($plugin.FullName)/config.sh`""
    }
}
[Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
[Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
Set-Location -Path "/fieldsets/"