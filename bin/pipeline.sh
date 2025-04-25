#!/usr/bin/env pwsh

$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$fieldsets_local_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_LOCAL_HOST')
$home_path = [System.Environment]::GetEnvironmentVariable('HOME')
$session_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_HOST')
$ssh_key_path = [System.Environment]::GetEnvironmentVariable('SSH_KEY_PATH')
$session_port = [System.Environment]::GetEnvironmentVariable('SSH_PORT')
$session_key = [System.Environment]::GetEnvironmentVariable('FIELDSETS_SESSION_KEY')
if ($ssh_key_path.StartsWith('~')) {
    $ssh_key_path = $ssh_key_path.Replace('~', "$($home_path)")
}
$session_key_path = [System.IO.Path]::GetFullPath((Join-Path -Path $ssh_key_path -ChildPath $session_key))
if (($null -eq $session_host) -or ("$($session_host)".Length -eq 0)) {
    $session_host = $fieldsets_local_host
}

$pipeline_session = New-PSSession -Name FieldsetsLocalSession -HostName $session_host -Options @{StrictHostKeyChecking='no'} -Port $session_port -KeyFilePath $session_key_path
Enter-PSSession -Session $pipeline_session
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/")
Import-Module -Name "$($module_path)/fieldsets.psm1"

$npgsql_package_path = (Get-Package "Npgsql").Source
$npgsql_path = [System.IO.Path]::GetFullPath((Join-Path -Path "$((Get-Item -Path "$($npgsql_package_path)").Directory)" -ChildPath "./lib/net8.0/Npgsql.dll"))
Add-Type -Path "$($npgsql_path)"

[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", 'pipeline-init')
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", '00')

Push-Location '/usr/local/fieldsets/'

$plugins = cache_get -key 'plugin_priority_queue'
Write-Host $plugins

$phase_scripts = Get-Item -Path "/docker-entrypoint-init.d/*.sh" | Select-Object BaseName, FullName
foreach ($phase_path in $phase_scripts) {
    Write-Host $phase_path.FullName
    $processOptions = @{
        Filepath = "$($phase_path.FullName)"
        RedirectStandardInput = "/dev/null"
        RedirectStandardError = "/dev/tty"
        RedirectStandardOutput = "$($log_path)/$($script_token).log"
    }
    Start-Process @processOptions -Wait
}

Pop-Location
Exit-PSSession
