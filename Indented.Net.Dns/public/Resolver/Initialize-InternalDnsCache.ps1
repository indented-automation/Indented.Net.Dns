using namespace Indented.Net.Dns

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
    if (Get-Variable DnsCache -Scope Script -ErrorAction SilentlyContinue) {
        Remove-Variable DnsCache -Scope Script
    }
    New-Variable DnsCache -Scope Script -Value @{}

    # Allows quick, if limited, reverse lookups against the cache.
    if (Get-Variable DnsCacheReverse -Scope Script -ErrorAction SilentlyContinue) {
        Remove-Variable DnsCache -Scope Script
    }
    New-Variable DnsCacheReverse -Scope Script -Value @{}

    if (Test-Path $psscriptroot\var\named.root) {
        Get-Content $psscriptroot\var\named.root | 
            Where-Object { $_ -match '(?<Name>\S+)\s+(?<TTL>\d+)\s+(IN\s+)?(?<RecordType>A\s+|AAAA\s+)(?<IPAddress>\S+)' } |
            ForEach-Object {
                [PSCustomObject]@{
                    Name       = $matches.Name;
                    TTL        = [UInt32]$matches.TTL;
                    RecordType = [RecordType]$matches.RecordType;
                    IPAddress  = [IPAddress]$matches.IPAddress;
                } | Add-Member -TypeName 'Indented.Net.Dns.CacheRecord' -PassThru |
                    Add-InternalDnsCacheRecord -Permanent -ResourceType Hint
            }
    }
}