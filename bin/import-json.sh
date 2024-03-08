#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$true,Position=0)][String]$token,
    [Parameter(Mandatory=$true,Position=1)][String]$source,
    [Parameter(Mandatory=$true,Position=2)][String]$json,
    [Parameter(Mandatory=$false,Position=3)][String]$type = 'schema',
    [Parameter(Mandatory=$false,Position=4)][Int]$priority = 0
)

$POSTGRES_HOST = [System.Environment]::GetEnvironmentVariable('POSTGRES_HOST')
$POSTGRES_DB = [System.Environment]::GetEnvironmentVariable('POSTGRES_DB')
$POSTGRES_PORT = [System.Environment]::GetEnvironmentVariable('POSTGRES_PORT')
$POSTGRES_USER = [System.Environment]::GetEnvironmentVariable('POSTGRES_USER')
$POSTGRES_PASSWORD = [System.Environment]::GetEnvironmentVariable('POSTGRES_PASSWORD')

[Environment]::SetEnvironmentVariable("PGPASSWORD", $POSTGRES_PASSWORD)

$insert_stmt = "INSERT INTO pipeline.imports(token, source, type, priority, data) VALUES ('$($token)', '$($source)', '$($type)', $($priority), '$($json)'::JSONB) ON CONFLICT DO NOTHING;"
& "psql" -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$insert_stmt"
