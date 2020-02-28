$Script:Settings = Get-Content -Path "$PSScriptRoot\Settings.json" | ConvertFrom-Json

[string]$functionRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve

Get-ChildItem -Path $functionRoot -Filter '*.ps1' -Recurse | ForEach-Object -Process {
    Write-Verbose -Message ("Importing function {0}." -f $_.FullName)
    . $_.FullName | Out-Null
}