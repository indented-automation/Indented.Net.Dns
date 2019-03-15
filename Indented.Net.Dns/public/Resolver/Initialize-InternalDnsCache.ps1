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

    # Allows quick, if limited, reverse lookups against the cache.
    $Script:dnsCacheReverse = @{}

    if (Test-Path $psscriptroot\var\named.root) {
        Get-Content $psscriptroot\var\named.root |
            Where-Object { $_ -match '(?<Name>\S+)\s+(?<TTL>\d+)\s+(IN\s+)?(?<RecordType>A\s+|AAAA\s+)(?<IPAddress>\S+)' } |
            ForEach-Object {
                [PSCustomObject]@{
                    Name       = $matches.Name
                    TTL        = [UInt32]$matches.TTL
                    RecordType = [RecordType]$matches.RecordType
                    IPAddress  = [IPAddress]$matches.IPAddress
                    PSTypeName = 'DnsCacheRecord'
                }
            } |
            Add-InternalDnsCacheRecord -Permanent -ResourceType Hint
    }
}