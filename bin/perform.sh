#!/usr/bin/env pwsh

##
# Asynchronous Script for performActionHook callbacks
##
Param(
    [Parameter(Mandatory=$true,Position=0)][String]$callback
)

$module_path = [System.IO.Path]::GetFullPath((Join-Path -Path '/usr/local/fieldsets/lib/' -ChildPath "./fieldsets.psm1"))
Import-Module -Name "$($module_path)"


Exit