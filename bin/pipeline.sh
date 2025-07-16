#!/usr/bin/env -S pwsh -NoLogo -NoExit -WorkingDirectory "/usr/local/fieldsets/"

$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/")
Import-Module -Name "$($module_path)/fieldsets.psm1"

Write-Host "## Pipeline Initializing ##"

Write-Output "## Initializing Session Cache ##"
session_cache_connect
# Start Fresh & Flush
# session_cache_flush

$session_cache = session_cache_init

Write-Output $session_cache

#$is_initialized = session_cache_get -Key 'initialized' -Session ($session)

#if ($is_initialized -eq $true) {
#    Write-Output "Session cache initialized successfully."
#    session_cache_set -Key 'current-checkpoint' -Value 'session-cache-initialized' -Session ($session)
#} else {
#    Write-Output "Failed to initialize session cache."
#}

# Import the rest of the modules

# Run through all plugins in priority order
$phase_scripts = Get-Item -Path "/docker-entrypoint-init.d/*.sh"

foreach ($phase_path in $phase_scripts) {
    Write-Host $phase_path.FullName
    $phase_priority, $phase_name = ($phase_path.BaseName).Split('-')[0,1]

    $phase_details = @{
        phase = $phase_name
        phase_priority = $phase_priority
        phase_path = $phase_path.FullName
        phase_status = 'active'
        current = $phase_name
        current_priority = $phase_priority
        current_path = $phase_path.FullName
        current_status = 'active'
    }
    $phase_json = ConvertTo-Json -InputObject $phase_details -Compress -Depth 5
    session_cache_set -Key 'fieldsets_pipeline_phase' -Type 'object' -Value $($phase_json)

    $stdErrLog = "/data/logs/pipeline.phase.stderr.log"
    $stdOutLog = "/data/logs/pipeline.phase.stdout.log"
    $processOptions = @{
        Filepath = "$($phase_path.FullName)"
        RedirectStandardInput = "/dev/null"
        RedirectStandardError = $stdErrLog
        RedirectStandardOutput = $stdOutLog
    }
    Start-Process @processOptions -Wait
    Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)/pipeline.log" -Append
    $phase_details['parent_status'] = 'complete'
    $phase_json = ConvertTo-Json -InputObject $phase_details -Compress -Depth 5
    session_cache_set -Key 'fieldsets_pipeline_phase' -Type 'object' -Value $($phase_json)
}

$priority_queue = session_cache_get -key 'fieldsets_plugin_priority'

session_cache_disconnect

Exit