#!/usr/bin/env pwsh

##
# Asynchronous Script for parseDataHook callbacks
##
Param(
    [Parameter(Mandatory=$true,Position=0)][String]$callback,
    [Parameter(Mandatory=$false,Position=1)][String]$json_data
)

$module_path = [System.IO.Path]::GetFullPath((Join-Path -Path '/usr/local/fieldsets/lib/' -ChildPath "./fieldsets.psm1"))
Import-Module -Name "$($module_path)"

Exit