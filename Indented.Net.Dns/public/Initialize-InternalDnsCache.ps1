function Initialize-InternalDnsCache {
    <#
    .SYNOPSIS
        Initializes a basic DNS cache for use by Get-Dns.

    .DESCRIPTION
        Get-Dns maintains a limited DNS cache, capturing A and AAAA records, to assist name server resolution (for values passed using the Server parameter).

        The cache may be manipulated using *-InternalDnsCacheRecord Cmdlets.

    .EXAMPLE
        Initialize-InternalDnsCache

        Initialize the cache.
    #>

    [CmdletBinding()]
    param( )

    $Script:dnsCache = @{}

    $path = Join-Path $MyInvocation.MyCommand.Module.ModuleBase 'var\named.root'
    if (Test-Path $path) {
        Get-Content $path |
            Where-Object { -not $_.StartsWith(';') -and $_ -cmatch '\d+\s+A' } |
            ForEach-Object { [DnsCacheRecord]::Parse($_) } |
            Add-InternalDnsCacheRecord -ResourceType Hint -Permanent
    }
}
