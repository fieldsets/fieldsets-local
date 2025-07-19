#!/usr/bin/env -S pwsh -NoLogo -NoExit -WorkingDirectory "/usr/local/fieldsets/"

$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$session_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_PORT')
$session_key = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_KEY')
$cache_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_CACHE_HOST')
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/")
Import-Module -Name "$($module_path)/fieldsets.psm1"

addCoreHooks
# Clobber init_phase function to add add in custom hooks pre-init phase.
performActionHook -Name 'fieldsets_init_phase'

Write-Host "## Pipeline Initializing ##"
performActionHook -Name 'fieldsets_init_local_env'

$hook_args = @{
    HostName = $cache_host
    Port = $session_port
    Key = $session_key
}
$connect_info = parseDataHook -Name 'fieldsets_session_connect_info' -Data $hook_args

session_connect @connect_info

performActionHook -Name 'fieldsets_init_session_env'
# Start Fresh & Flush
# session_cache_flush

Write-Output "## Initializing Session Cache ##"
cache_init

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

session_disconnect

Exit