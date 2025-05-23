#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$true,Position=0)][String]$token,
    [Parameter(Mandatory=$true,Position=1)][String]$source,
    [Parameter(Mandatory=$true,Position=2)][String]$json,
    [Parameter(Mandatory=$false,Position=3)][String]$type = 'schema',
    [Parameter(Mandatory=$false,Position=4)][Int]$priority = 0,
    [Parameter(Mandatory=$false,Position=5)][String]$database = 'fieldsets'
)
$db_type = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB')
$db_host = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_HOST')
$db_name = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_NAME')
$db_port = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PORT')
$db_user = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_USER')
$db_password = [System.Environment]::GetEnvironmentVariable('FIELDSETS_DB_PASSWORD')

if ("$($db_type)" -eq 'postgres') {
    [Environment]::SetEnvironmentVariable("PGPASSWORD", $db_password)
    $escaped_json = [string]::Format('$JSON${0}$JSON$::JSONB',$json)
    $insert_stmt = "INSERT INTO pipeline.imports(token, source, type, priority, data) VALUES ('$($token)', '$($source)', '$($type)', $($priority), $($escaped_json)) ON CONFLICT DO NOTHING;"
    & "psql" -v ON_ERROR_STOP=1 --host "$($db_host)" --port "$($db_port)" --username "$($db_user)" --dbname "$($db_name)" -c "$insert_stmt"
}
