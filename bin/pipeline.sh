#!/usr/bin/env -S pwsh -NoLogo -NoExit -WorkingDirectory "/usr/local/fieldsets/"

$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')

$fieldsets_local_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_LOCAL_HOST')
$home_path = [System.Environment]::GetEnvironmentVariable('HOME')
$session_port = [System.Environment]::GetEnvironmentVariable('SSH_PORT')
$ssh_key_path = [System.Environment]::GetEnvironmentVariable('SSH_KEY_PATH')
$session_key = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_KEY')
if ($ssh_key_path.StartsWith('~')) {
    $ssh_key_path = $ssh_key_path.Replace('~', "$($home_path)")
}
$session_key_path = [System.IO.Path]::GetFullPath((Join-Path -Path $ssh_key_path -ChildPath $session_key))

#$pipeline_session = Get-PSSession -Name 'fieldsets-pipeline' -ErrorAction SilentlyContinue
#if ($null -eq $pipeline_session) {
#    $pipeline_session = New-PSSession -Name 'fieldsets-pipeline' -HostName $fieldsets_local_host -Options @{StrictHostKeyChecking='no'} -Port $session_port -KeyFilePath $session_key_path
#}

Write-Host "## Pipeline Initializing ##"
#Enter-PSSession -Session $pipeline_session

# Prime the cache
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/")
Import-Module -Function session_cache_init, session_cache_set, session_cache_get -Name "$($module_path)/pwsh/cache.psm1"

#Write-Output "## Initializing Session Cache ##"
#$session = session_cache_init
#$is_initialized = session_cache_get -Key 'initialized' -Session ($session)

#if ($is_initialized -eq $true) {
#    Write-Output "Session cache initialized successfully."
#    session_cache_set -Key 'current-checkpoint' -Value 'session-cache-initialized' -Session ($session)
#} else {
#    Write-Output "Failed to initialize session cache."
#}

# Import the rest of the modules
Import-Module -Name "$($module_path)/fieldsets.psm1"
Get-Content $pipelinestdErrLog, $pipelinestdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)/pipeline.log" -Append

# Run through all plugins in priority order
$phase_scripts = Get-Item -Path "/docker-entrypoint-init.d/*.sh" | Select-Object BaseName, FullName

foreach ($phase_path in $phase_scripts) {
    Write-Host $phase_path.FullName
    $stdErrLog = "/data/logs/pipeline.phase.stderr.log"
    $stdOutLog = "/data/logs/pipeline.phase..stdout.log"
    $processOptions = @{
        Filepath = "$($phase_path.FullName)"
        RedirectStandardInput = "/dev/null"
        RedirectStandardError = $stdErrLog
        RedirectStandardOutput = $stdOutLog
    }
    Start-Process @processOptions -Wait
    Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)/pipeline.log" -Append
}

#Exit-PSSession
while($true) {
    Start-Sleep -Seconds 60
}