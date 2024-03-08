#!/usr/bin/env pwsh

$POSTGRES_HOST = [System.Environment]::GetEnvironmentVariable('POSTGRES_HOST')
$POSTGRES_DB = [System.Environment]::GetEnvironmentVariable('POSTGRES_DB')
$POSTGRES_PORT = [System.Environment]::GetEnvironmentVariable('POSTGRES_PORT')
$POSTGRES_USER = [System.Environment]::GetEnvironmentVariable('POSTGRES_USER')
$POSTGRES_PASSWORD = [System.Environment]::GetEnvironmentVariable('POSTGRES_PASSWORD')

[Environment]::SetEnvironmentVariable("PGPASSWORD", $POSTGRES_PASSWORD)

$import_stmt = "CALL fieldsets.import_json_schemas();"
& "psql" -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$import_stmt"
Write-Output "Schemas imported from pipeline.imports"
