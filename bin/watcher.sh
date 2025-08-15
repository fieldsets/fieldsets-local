#!/usr/bin/env pwsh

Param(
    [Parameter(Mandatory=$true,Position=0)][String]$phase,
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='Load')][String]$source,
    [Parameter(Mandatory=$true,Position=2,ParameterSetName='Load')][String]$path,
    [Parameter(Mandatory=$true,Position=3,ParameterSetName='Load')][String]$callback,
    [Parameter(Mandatory=$false,Position=5,ParameterSetName='Load')][String]$encoded_targets = $null
)

$module_path = [System.IO.Path]::GetFullPath((Join-Path -Path '/usr/local/fieldsets/lib/' -ChildPath "./fieldsets.psm1"))
Import-Module -Name "$($module_path)"

Unregister-Event -SourceIdentifier "$($source)_$($phase)_target_change" -ErrorAction SilentlyContinue
Remove-Event -SourceIdentifier "$($source)_$($phase)_target_change" -ErrorAction SilentlyContinue

$watcherTimeout = 15
$target_directory = [System.IO.Path]::GetFullPath($path)

$targets = $null
if ($null -ne $encoded_targets) {
    $decoded_targets = [System.Convert]::FromBase64String("$($encoded_targets)")
    $targets_json_data = [System.Text.Encoding]::Unicode.GetString($decoded_targets)
    $targets = ConvertFrom-Json -InputObject $targets_json_data -Depth 10 -NoEnumerate
}
if ($null -ne $targets) {
    $watched_checksums = @{}

    $watcher = New-Object System.IO.FileSystemWatcher $target_directory -Property @{
        IncludeSubdirectories = $false
        NotifyFilter = [System.IO.NotifyFilters]'LastWrite,Size,CreationTime,Attributes'
        EnableRaisingEvents = $false
    }

    Register-ObjectEvent $watcher Changed -SourceIdentifier "$($source)_$($phase)_target_change"

    foreach ($target_data in $targets) {
        $target_file = $target_data.('target')
        $target_path = [System.IO.Path]::GetFullPath((Join-Path -Path $target_directory -ChildPath "./$($target_file)"))

        if (Test-Path -Path $target_path) {
            $target_args = $target_data.('args') | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10 -AsHashtable -NoEnumerate
            $watched_checksums["$($target_path)"] = @{
                args = $target_args
                checksum = (Get-FileHash "$($target_path)").Hash
            }
            $watcher.Filters.Add($target_file)
        } else {
            Write-Host "Cannot find watch target: $($target_path)"
        }
    }

    $watcher.EnableRaisingEvents = $true
    $running = $true
    Write-Host "Watching $($source) target directory: $($path)"
    try {
        do {
            try {
                [System.Management.Automation.PSEventArgs]$e = Wait-Event -SourceIdentifier "$($source)_$($phase)_target_change" -Timeout $watcherTimeout
                # Will fail if timed_out
                [string]$name = $e.SourceEventArgs.Name
                # The type of change
                [System.IO.WatcherChangeTypes]$changeType = $e.SourceEventArgs.ChangeType
                if ("$($changeType)" -eq 'Changed') {
                    # The time and date of the event
                    [string]$timeStamp = $e.TimeGenerated.ToString("yyyy-MM-dd HH:mm:ss")

                    Write-Host "--- START [$($e.EventIdentifier)] $changeType $name $timeStamp"
                    Write-Host "$(ConvertTo-Json $e -Depth 10)"

                    $file_path = $e.SourceEventArgs.FullPath
                    $current_checksum = (Get-FileHash "$($file_path)").Hash
                    $watched_checksums["$($file_path)"]['checksum'] = $current_checksum
                    $callback_args = $watched_checksums["$($file_path)"]['args']

                    Write-Host "Name: $($name)"
                    Write-Host "Type: $($changeType)"
                    Write-Host "$(ConvertTo-Json $callback_args -Depth 10)"

                    $db_connection_info = parseDataHook -Name 'fieldsets_db_connect_info'

                    $db_connection = getDBConnection @db_connection_info
                    # Remove the event because we handled it
                    Remove-Event -EventIdentifier $($e.EventIdentifier)

                    & "$($callback)" -connection $db_connection -path $file_path @callback_args

                    Write-Host "--- END [$($e.EventIdentifier)] $changeType $name $timeStamp"
                }
            } catch {
                # Containerized and mounted volumes will not trigger events so we create file checksums to ensure nothing has changed.
                $watched_checksums.GetEnumerator() | ForEach-Object {
                    $watched_file_path = $_.Key
                    $watched_file = Get-Item -Path $watched_file_path

                    $watched_file_data = $_.Value
                    $prev_checksum = $watched_file_data['checksum']
                    $current_checksum = (Get-FileHash "$($watched_file_path)").Hash
                    if ($prev_checksum -ne $current_checksum) {
                        Write-Host "$($watched_file_path) Changed"
                        $event_args = [System.IO.FileSystemEventArgs]::new(4, "$($path)","$($watched_file.Name)")
                        New-Event -SourceIdentifier "$($source)_$($phase)_target_change" -EventArguments $event_args -Sender $watcher | Out-Null
                        $watched_checksums["$($watched_file_path )"]['checksum'] = $current_checksum
                    }
                }
                continue
            }
        } while ($running)
    } finally {
        Unregister-Event "$($source)_$($phase)_target_change"
    }
} else {
    Write-Host "watcher.sh: Invalid Targets Array"
}

Exit