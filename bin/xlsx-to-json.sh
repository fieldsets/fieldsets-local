#!/usr/bin/env pwsh
Param(
    [Parameter(Mandatory=$false,Position=0)][String]$input_file_path = '/usr/local/fieldsets/apps/econcircles/data/sharepoint/StockScreener/Archive/stock_screener_2024_04_08.xlsx',
    [Parameter(Mandatory=$false,Position=1)][String]$output_filepath = '/usr/local/fieldsets/apps/econcircles/data/sharepoint/DB/Reports/StockScreener/stock_screener_2024_04_08.json',
    [Parameter(Mandatory=$false,Position=2)][String]$sheet_name = 'Dashboard',
    [Parameter(Mandatory=$false,Position=3)][String]$field_map = '/usr/local/fieldsets/apps/econcircles/data/sharepoint/DB/Reports/StockScreener_field_map.json'
)

#$module_path = "/usr/local/fieldsets/lib/pwsh/utils/"
#$env:PSModulePath = $module_path + $env:PSModulePath
#[Environment]::SetEnvironmentVariable("PSModulePath", $env:PSModulePath)

#$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Import-Module ImportExcel

$worksheet = Import-Excel -Path $input_file_path -WorksheetName "$($sheet_name)"
$result_array = [System.Collections.Generic.List[String]]::new()

foreach ($sheet in $results) {
    Write-Output $sheet
}