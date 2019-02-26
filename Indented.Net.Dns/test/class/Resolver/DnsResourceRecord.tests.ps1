param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf('\test'))
    Import-Module $moduleBase -Force
}

InModuleScope Indented.Net.Dns {
    Describe DnsResourceRecord {

    }
}