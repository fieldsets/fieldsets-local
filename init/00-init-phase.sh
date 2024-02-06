#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][Int]$priority = 0,
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "init"
)
[Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $null, "User")
[Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $null, "User")

$utils_module_path = [System.IO.Path]::GetFullPath("/fieldsets-lib/pwsh/utils/")
Import-Module -Function checkDependencies, lockfileExists, createLockfile -Name "$($utils_module_path)/utils.psm1"

$padded_priority = $priority.ToString("D2")
$script_token = "$($phase)-phase"
$lockfile_path = "/data/checkpoints/${ENVIRONMENT}/phases/"

# Create our path if it does not exist
if (!(Test-Path -Path "$($lockfile_path)/$($phase)/")) {
    New-Item -Path "$($lockfile_path)" -Name "$($phase)" -ItemType Directory
}
$dependencies_met = checkDependencies
if ($dependencies_met) {
    Set-Location -Path "/fieldsets-plugins/"
    $plugin_dirs = Get-ChildItem -Path "/fieldsets-plugins/*" -Directory |
    Select-Object FullName, Name, LastWriteTime, CreationTime
    # Check to make sure all plugin dependencies are met.
    foreach ($plugin in $plugin_dirs) {
        if (Test-Path -Path "$($plugin.FullName)/init.sh") {
            $lockfile = "$($padded_priority)-plugin-$($plugin.Name).$($phase).complete"
            if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
                Write-Information -MessageData "Initializing plugin $($plugin.FullName)" -InformationAction Continue
                Set-Location -Path "$($plugin.FullName)"
                chmod +x "$($plugin.FullName)/init.sh"
                & "bash" -c "exec `"$($plugin.FullName)/init.sh`""
                createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)"
            }
        }
    }
    [Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
    [Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
} else {
    Throw "Missing Dependencies"
}
Set-Location -Path "/fieldsets/"