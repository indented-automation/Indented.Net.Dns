function Update-InternalRootHints {
    <#
    .SYNOPSIS
        Updates the root hints file from InterNIC then re-initializes the internal cache.
    .DESCRIPTION
        The root hints file is used as the basis of an internal DNS cache. The content of the root hints file is used during iterative name resolution.
    .PARAMETER Source
        Update-InternalRootHints attempts to download a named.root file from InterNIC by default. An alternative root hints source may be specified here.
    .EXAMPLE
        Update-InternalRootHints
    #>

    [CmdletBinding()]
    param (
        [URI]$Source = "http://www.internic.net/domain/named.root"
    )

    Invoke-WebRequest -Uri $Source |
        Select-Object -ExpandProperty Content |
        Set-Content $psscriptroot\var\named.root
    Initialize-InternalDnsCache
}