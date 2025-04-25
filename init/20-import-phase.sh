#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][String]$priority = "20",
    [Parameter(Mandatory=$false,Position=1)][String]$phase = "import"
)
$script_token = "$($phase)-phase"
$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib/pwsh")
Import-Module -Function lockfileExists, createLockfile -Name "$($module_path)/utils.psm1"
Import-Module -Function isPluginPhaseContainer, buildPluginPriortyList -Name "$($module_path)/plugins.psm1"
Import-Module -Function getDBConnection -Name "$($module_path)/db.psm1"

Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
# Ordered plugins by priority
$dotnet_ver = [System.Environment]::GetEnvironmentVariable('DOTNET_VERSION')
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$lockfile_path = "/usr/local/fieldsets/data/checkpoints/$($envname)/$($hostname)/phases/"
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

if (!(Test-Path -Path "$($log_path)/$($script_token).log")) {
    New-Item -Path "$($log_path)" -Name "$($script_token).log" -ItemType File | Out-Null
}

# Set up DB connection

$db_host = [System.Environment]::GetEnvironmentVariable('POSTGRES_HOST')
$db_port = [System.Environment]::GetEnvironmentVariable('POSTGRES_PORT')
$db_user = [System.Environment]::GetEnvironmentVariable('POSTGRES_USER')
$db_password = [System.Environment]::GetEnvironmentVariable('POSTGRES_PASSWORD')
$db_name = [System.Environment]::GetEnvironmentVariable('POSTGRES_DB')

$trigger_role = [System.Environment]::GetEnvironmentVariable('POSTGRES_TRIGGER_ROLE')

$store_host = [System.Environment]::GetEnvironmentVariable('CLICKHOUSE_HOST')
$store_port = [System.Environment]::GetEnvironmentVariable('CLICKHOUSE_PORT')
$store_user = [System.Environment]::GetEnvironmentVariable('CLICKHOUSE_USER')
$store_password = [System.Environment]::GetEnvironmentVariable('CLICKHOUSE_PASSWORD')
$store_name = [System.Environment]::GetEnvironmentVariable('CLICKHOUSE_DB')


[System.Environment]::SetEnvironmentVariable('PGUSER', $db_user) | Out-Null
[System.Environment]::SetEnvironmentVariable('PGPASSWORD', $db_password) | Out-Null

$db_connection = getDBConnection
$db_connection.Open()
$db_command = $db_connection.CreateCommand()

<##
 # Create Foreign Schemas
 ##>
$lockfile = "$($priority)-create-foreign-schemas.complete"
if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
    # Create Local File Server for Imports for scraper outputs.
    $db_command.CommandText = "CREATE SERVER IF NOT EXISTS file_server FOREIGN DATA WRAPPER file_fdw;"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_command.CommandText = "CREATE EXTENSION IF NOT EXISTS clickhouse_fdw;"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_command.CommandText = "CREATE SERVER IF NOT EXISTS clickhouse_server FOREIGN DATA WRAPPER clickhouse_fdw OPTIONS(dbname '$($store_name)', host '$($store_host)', port '$($store_port)');"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_command.CommandText = "CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER clickhouse_server OPTIONS (user '$($store_user)', password '$($store_password)');"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_command.CommandText = "CREATE USER MAPPING IF NOT EXISTS FOR $($trigger_role) SERVER clickhouse_server OPTIONS (user '$($store_user)', password '$($store_password)');"
    $db_command.ExecuteNonQuery() | Out-Null

    createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    Write-Output "Foreign Schemas Created."
}

<##
 # Create Tables
 ##>
 $lockfile = "$($priority)-create-tables.complete"
if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
    $sql_stmt_files = Get-Item -Path "/usr/local/fieldsets/sql/tables/*.sql" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
    foreach ($sql_file in $sql_stmt_files) {
        $db_command.CommandText = Get-Content -Raw -Path "$($sql_file.FullName)"
        if ("$($db_command.CommandText)".Length -gt 0) {
            $db_command.ExecuteNonQuery() | Out-Null
        }
    }
    createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    Write-Output "Tables Created."
}

<##
 # Create functions
 ##>
$lockfile = "$($priority)-create-functions.complete"
if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
    $sql_stmt_files = Get-Item -Path "/usr/local/fieldsets/sql/functions/*.sql" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
    foreach ($sql_file in $sql_stmt_files) {
        $db_command.CommandText = Get-Content -Raw -Path "$($sql_file.FullName)"
        if ("$($db_command.CommandText)".Length -gt 0) {
            $db_command.ExecuteNonQuery() | Out-Null
        }
    }
    createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    Write-Output "Functions Created."
}

<##
 # Create Stored Procedures
 ##>
$lockfile = "$($priority)-create-stored-procedures.complete"
if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
    $sql_stmt_files = Get-Item -Path "/usr/local/fieldsets/sql/stored_procedures/*.sql" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
    foreach ($sql_file in $sql_stmt_files) {
        $db_command.CommandText = Get-Content -Raw -Path "$($sql_file.FullName)"
        if ("$($db_command.CommandText)".Length -gt 0) {
            $db_command.ExecuteNonQuery() | Out-Null
        }
    }
    createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    Write-Output "Stored Procedures Created."
}

<##
 # Create Triggers
 ##>
$lockfile = "$($priority)-create-triggers.complete"
if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
    $sql_stmt_files = Get-Item -Path "/usr/local/fieldsets/sql/triggers/*.sql" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
    foreach ($sql_file in $sql_stmt_files) {
        $db_command.CommandText = Get-Content -Raw -Path "$($sql_file.FullName)"
        if ("$($db_command.CommandText)".Length -gt 0) {
            $db_command.ExecuteNonQuery() | Out-Null
        }
    }
    createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
    Write-Output "Triggers Created."
}

$db_connection.Close()

# Execute plugin import phase scripts
$plugins_priority_list = buildPluginPriortyList
foreach ($plugin_dirs in $plugins_priority_list.Values) {
    foreach ($plugin_dir in $plugin_dirs) {
        if ($null -ne $plugin_dir) {
            $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
            if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                Write-Host "Pre $($phase) phase for plugin: $($plugin.BaseName)"
                if (Test-Path -Path "$($plugin.FullName)/$($phase).sh") {
                    Set-Location -Path "$($plugin.FullName)" | Out-Null
                    chmod +x "$($plugin.FullName)/$($phase).sh" | Out-Null
                    $processOptions = @{
                        Filepath = "$($plugin.FullName)/$($phase).sh"
                        RedirectStandardInput = "/dev/null"
                        RedirectStandardError = "/dev/tty"
                        RedirectStandardOutput = "$($log_path)/$($script_token).log"
                    }
                    Start-Process @processOptions  -Wait
                }
            }
        }
    }
}
# Import any schemas and data
$db_connection.Open()
$db_command = $db_connection.CreateCommand()

$db_command.CommandText = "CALL fieldsets.import_json_schemas();"
$db_command.ExecuteNonQuery() | Out-Null

$db_command.CommandText = "CALL fieldsets.import_json_data();"
$db_command.ExecuteNonQuery() | Out-Null

$db_connection.Close()

[System.Environment]::SetEnvironmentVariable("FieldSetsLastCheckpoint", $script_token, "User")
[System.Environment]::SetEnvironmentVariable("FieldSetsLastPriority", $priority, "User")
Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null
Exit
