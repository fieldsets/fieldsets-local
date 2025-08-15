#!/usr/bin/env -S pwsh -NoLogo -WorkingDirectory "/usr/local/fieldsets/"

$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$session_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_PORT')
$session_key_filename = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_KEY')
$session_key_path = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_KEY_PATH')
$cache_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_CACHE_HOST')
$module_path = [System.IO.Path]::GetFullPath((Join-Path -Path '/usr/local/fieldsets/lib/' -ChildPath "./fieldsets.psm1"))
Import-Module -Name "$($module_path)"
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

addCoreHooks

Write-Host "## Pipeline Initializing ##"
performActionHook -Name 'fieldsets_set_local_env'

# Set up DB connection
$db_type = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB')
$db_user = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_USER')
$db_password = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PASSWORD')
$db_name = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_NAME')
$db_schema = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_SCHEMA')
$db_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_HOST')
$db_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PORT')
$dotnet_ver = [System.Environment]::GetEnvironmentVariable('DOTNET_VERSION')

$db_credentials = @{
    type = $db_type
    dbname = $db_name
    hostname = $db_host
    schema = $db_schema
    port = $db_port
    user = $db_user
    password = $db_password
    dotnet_ver = $dotnet_ver
}
$db_connection_info = parseDataHook -Name 'fieldsets_db_connect_info' -Data $db_credentials

$session_key = (Join-Path -Path "$($session_key_path)" -ChildPath "$($session_key_filename)")

$hook_args = @{
    HostName = $cache_host
    Port = $session_port
    Key = $session_key
}
$connect_info = parseDataHook -Name 'fieldsets_session_connect_info' -Data $hook_args

session_connect @connect_info
if ("$($db_type)" -eq 'postgres') {
    [System.Environment]::SetEnvironmentVariable('PGUSER', $db_user) | Out-Null
    [System.Environment]::SetEnvironmentVariable('PGPASSWORD', $db_password) | Out-Null
}
performActionHook -Name 'fieldsets_set_session_env'
# Start Fresh & Flush
# session_cache_flush

Write-Output "## Initializing Session Cache ##"
cache_init
# Make sure our DB connection info is cached
getDBConnection @db_connection_info | Out-Null

# Import the rest of the modules
# Run through all plugins in priority order
$phase_scripts = Get-Item -Path "/docker-entrypoint-init.d/*-phase.sh"

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
    cache_set -Key 'fieldsets_pipeline_phase' -Type 'object' -Value $($phase_json) -Expires 0

    performActionHook -Name "fieldsets_pre_$($phase_name)_phase"

    $stdErrLog = "/data/logs/pipeline.stderr.log"
    $stdOutLog = "/data/logs/pipeline.stdout.log"
    $processOptions = @{
        Filepath = "$($phase_path.FullName)"
        RedirectStandardInput = "/dev/null"
        RedirectStandardError = $stdErrLog
        RedirectStandardOutput = $stdOutLog
    }
    Start-Process @processOptions -Wait
    performActionHook -Name "fieldsets_post_$($phase_name)_phase"

    $phase_details['parent_status'] = 'complete'
    $phase_json = ConvertTo-Json -InputObject $phase_details -Compress -Depth 5
    cache_set -Key 'fieldsets_pipeline_phase' -Type 'object' -Value $($phase_json) -Expires 0
}

Write-Host "## Session Cache Set ##"

Write-Host "## Pipeline - Extract Phase##"
performActionHook -Name 'fieldsets_watch_extract_targets'
performActionHook -Name 'fieldsets_schedule_extract_targets'

Write-Host "## Pipeline - Transform Phase##"
performActionHook -Name 'fieldsets_watch_transform_targets'
performActionHook -Name 'fieldsets_schedule_transform_targets'

Write-Host "## Pipeline - Load Phase##"
performActionHook -Name 'fieldsets_watch_load_targets'
performActionHook -Name 'fieldsets_schedule_load_targets'

Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '`x1b`[[0-9;]*m','' } | Out-File "$($log_path)/pipeline.log" -Append

session_disconnect
Write-Host "## Pipeline Complete ##"

Exit


