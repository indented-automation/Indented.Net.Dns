# Development mode importer

$paths = 'enum', 'class', 'private', 'public' | ForEach-Object {
    Join-Path $psscriptroot $_
}
Get-ChildItem $paths -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
. $psscriptroot\InitializeModule.ps1

InitializeModule