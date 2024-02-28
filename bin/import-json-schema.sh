#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$true,Position=0)][String]$token
    [Parameter(Mandatory=$true,Position=1)][String]$source
    [Parameter(Mandatory=$true,Position=2)][String]$json
    [Parameter(Mandatory=$false,Position=3)][String]$type = 'schema'
    [Parameter(Mandatory=$false,Position=4)][Int]$order = 0
)


#select * from jsonb_to_recordset((select schema_data['fields'] from imports)) as field(token text, label text, type text, store text, values text[])
