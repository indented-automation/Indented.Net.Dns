function Initialize-InternalDnsCache {
    <#
    .SYNOPSIS
        Initializes a basic DNS cache for use by Get-Dns.
    .DESCRIPTION
        Get-Dns maintains a limited DNS cache, capturing A and AAAA records, to assist name server resolution (for values passed using the Server parameter).

        The cache may be manipulated using *-InternalDnsCacheRecord CmdLets.
    .EXAMPLE
        Initialize-InternalDnsCache
    #>

    [CmdletBinding()]
    param( )

    # These two variables are consumed by all other -InternalDnsCacheRecord CmdLets.

    # The primary cache variable stores a stub resource record
    $Script:dnsCache = @{}

    $path = Join-Path $myinvocation.MyCommand.Module.ModuleBase 'var\named.root'
    if (Test-Path $path) {
        Get-Content $path |
            Where-Object { -not $_.StartsWith(';') -and $_ -cmatch '\d+\s+A' } |
            ForEach-Object { [DnsCacheRecord]::Parse($_) } |
            Add-InternalDnsCacheRecord -ResourceType Hint -Permanent
    }
}