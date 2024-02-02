#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][Int]$priority = 0
)
$utils_module_path = [System.IO.Path]::GetFullPath("/fieldsets-lib/pwsh/utils/")
Import-Module -Function checkDependencies, lockfileExists, createLockfile -Name "$($utils_module_path)/utils.psm1"

$padded_priority = $priority.ToString("D2")
$script_token = "init-phase"
$lockfile = "$($padded_priority)-$($script_token).complete"
$lockfile_path = "/data/checkpoints/phases/"

$dependencies_met = checkDependencies
if ($dependencies_met) {
    if (! (lockfileExists "$($lockfile_path)/$($lockfile)")) {
        Set-Location -Path "/fieldsets-plugins/"
        $plugin_dirs = Get-ChildItem -Path "/fieldsets-plugins/*" -Directory |
        Select-Object FullName, Name, LastWriteTime, CreationTime
        # Check to make sure all plugin dependencies are met.
        foreach ($plugin in $plugin_dirs) {
            if (Test-Path -Path "$($plugin.FullName)/init.sh") {
                Write-Information -MessageData "Initializing plugin $($plugin.FullName)" -InformationAction Continue
                Set-Location -Path "$($plugin.FullName)"
                chmod +x "$($plugin.FullName)/init.sh"
                & "bash" -c "exec `"$($plugin.FullName)/init.sh`""
            }
        }
        createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)"
        [Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
        [Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
    }
} else {
    Throw "Missing Dependencies"
}
Set-Location -Path "/fieldsets/"