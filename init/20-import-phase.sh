#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false)][String]$priority = "20",
    [Parameter(Mandatory=$false)][String]$phase = "import"
)
<##
 # Import phase scripts are run only once. Usually on the first server start up.
 # Plugins that are added after the first install will have import scripts run at the first restart or can be manually triggered by running this script directly.
 # Scripts are flagged with a lockfile after they are run successfully.
 # If you want to run data imports for an application, create your data import scripts to be called by the run phase.
 ##>

$script_token = "$($phase)-phase"
Write-Host "###### BEGIN IMPORT PHASE ######"

$module_path = [System.IO.Path]::GetFullPath("/usr/local/fieldsets/lib")
Import-Module -Name "$($module_path)/fieldsets.psm1"

Set-Location -Path "/usr/local/fieldsets/plugins/" | Out-Null
# Ordered plugins by priority
$envname = [System.Environment]::GetEnvironmentVariable('ENVIRONMENT')
$hostname = [System.Environment]::GetEnvironmentVariable('HOSTNAME')
$lockfile_path = "/data/checkpoints/$($envname)/$($hostname)/phases/"
$log_path = "/usr/local/fieldsets/data/logs/$($envname)/$($hostname)"

if (!(Test-Path -Path "$($log_path)/$($script_token).log")) {
    New-Item -Path "$($log_path)" -Name "$($script_token).log" -ItemType File | Out-Null
}

# Set up DB connection
$db_type = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB')
$db_user = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_USER')
$db_password = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PASSWORD')
$db_name = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_NAME')
$db_schema = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_SCHEMA')
$db_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_HOST')
$db_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PORT')
$dotnet_ver = [System.Environment]::GetEnvironmentVariable('DOTNET_VERSION')

$trigger_role = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_TRIGGER_ROLE')
#$trigger_password = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_TRIGGER_ROLE_PASSWORD')

$store_type = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE')
$store_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE_HOST')
$store_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE_PORT')
$store_user = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE_USER')
$store_password = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE_PASSWORD')
$store_name = [System.Environment]::GetEnvironmentVariable('FIELDSETS_STORE_NAME')

if ("$($db_type)" -eq 'postgres') {
    [System.Environment]::SetEnvironmentVariable('PGUSER', $db_user) | Out-Null
    [System.Environment]::SetEnvironmentVariable('PGPASSWORD', $db_password) | Out-Null

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
    $db_connection = getDBConnection @db_connection_info
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

        if ("$($store_type)" -eq 'clickhouse') {
            $db_command.CommandText = "CREATE EXTENSION IF NOT EXISTS clickhouse_fdw;"
            $db_command.ExecuteNonQuery() | Out-Null

            $db_command.CommandText = "CREATE SERVER IF NOT EXISTS clickhouse_server FOREIGN DATA WRAPPER clickhouse_fdw OPTIONS(dbname '$($store_name)', host '$($store_host)', port '$($store_port)');"
            $db_command.ExecuteNonQuery() | Out-Null

            $db_command.CommandText = "CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER clickhouse_server OPTIONS (user '$($store_user)', password '$($store_password)');"
            $db_command.ExecuteNonQuery() | Out-Null

            $db_command.CommandText = "CREATE USER MAPPING IF NOT EXISTS FOR $($trigger_role) SERVER clickhouse_server OPTIONS (user '$($store_user)', password '$($store_password)');"
            $db_command.ExecuteNonQuery() | Out-Null
        }

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

    $lockfile = "$($priority)-import-core.complete"
    if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
        # Import any predefined schemas and data
        $db_connection.Open()
        $db_command = $db_connection.CreateCommand()

        $db_command.CommandText = "CALL fieldsets.import_json_schemas();"
        $db_command.ExecuteNonQuery() | Out-Null

        $db_command.CommandText = "CALL fieldsets.import_json_data();"
        $db_command.ExecuteNonQuery() | Out-Null

        $db_connection.Close()
        createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
        Write-Output "Imported Core Schema & Data."
    }
}

# Execute plugin import phase scripts
$plugins_priority_list = getPluginPriorityList
foreach ($plugin_dirs in $plugins_priority_list.Values) {
    foreach ($plugin_dir in $plugin_dirs) {
        if ($null -ne $plugin_dir) {
            $plugin = Get-Item -Path "$($plugin_dir)" | Select-Object FullName, Name, BaseName, LastWriteTime, CreationTime
            if (isPluginPhaseContainer -plugin "$($plugin.BaseName)") {
                Write-Host "$($phase) phase for plugin: $($plugin.BaseName)"
                if (Test-Path -Path "$($plugin.FullName)/$($phase).sh") {
                    $lockfile = "$($priority)-plugin-$($plugin.Name).$($phase).complete"
                    if (! (lockfileExists "$($lockfile_path)/$($phase)/$($lockfile)")) {
                        Set-Location -Path "$($plugin.FullName)" | Out-Null
                        chmod +x "$($plugin.FullName)/$($phase).sh" | Out-Null
                        $stdErrLog = "/data/logs/$($script_token).stderr.log"
                        $stdOutLog = "/data/logs/$($script_token).stdout.log"
                        $processOptions = @{
                            Filepath = "$($plugin.FullName)/$($phase).sh"
                            RedirectStandardInput = "/dev/null"
                            RedirectStandardError = $stdErrLog
                            RedirectStandardOutput = $stdOutLog
                        }
                        Start-Process @processOptions -Wait
                        Get-Content $stdErrLog, $stdOutLog | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } | Out-File "$($log_path)/$($script_token).log" -Append

                        createLockfile -lockfile "$($lockfile)" -lockfile_path "$($lockfile_path)/$($phase)" | Out-Null
                    }
                }
            }
        }
    }
}

if ("$($db_type)" -eq 'postgres') {
    # On startup always import any schemas and data
    $db_connection.Open()
    $db_command = $db_connection.CreateCommand()

    $db_command.CommandText = "CALL fieldsets.import_json_schemas();"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_command.CommandText = "CALL fieldsets.import_json_data();"
    $db_command.ExecuteNonQuery() | Out-Null

    $db_connection.Close()
}

Set-Location -Path "/usr/local/fieldsets/apps/" | Out-Null

Write-Host "###### END IMPORT PHASE ######"
Exit