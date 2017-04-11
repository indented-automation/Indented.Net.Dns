function Remove-InternalDnsCacheRecord {
    # .SYNOPSIS
    #   Remove an entry from the DNS cache object.
    # .DESCRIPTION
    #   Remove-InternalDnsCacheRecord allows the removal of individual records from the cache, or removal of all records which expired.
    # .PARAMETER CacheRecord
    #   A record to add to the cache.
    # .PARAMETER Permanent
    #   A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
    # .INPUTS
    #   Indented.DnsResolver.RecordType
    # .EXAMPLE
    #   Get-InternalDnsCacheRecord a.root-servers.net | Remove-InternalDnsCacheRecord
    # .EXAMPLE
    #   Remove-InternalDnsCacheRecord -AllExpired
    # .NOTES
    #   Change log:
    #     23/03/2017 - Chris Dent - Modernisation passd
    #     28/04/2014 - Chris Dent - Released.

    [CmdletBinding(DefaultParameterSetName = 'CacheRecord')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CacheRecord')]
        [PSTypeName('Indented.Net.Dns.CacheRecord')]
        $CacheRecord,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllExpired')]
        [Switch]$AllExpired
    )

    begin {
        if ($AllExpired) {
            $ExpiredRecords = Get-InternalDnsCacheRecord | Where-Object { $_.Status -eq 'Expired' }
            $ExpiredRecords | Remove-InternalDnsCacheRecord
        }
    }

    process {
        if (-not $AllExpired) {
            if ($DnsCacheReverse.Contains($CacheRecord.IPAddress)) {
                $DnsCacheReverse.Remove($CacheRecord.IPAddress)
            }
            if ($DnsCache.Contains($CacheRecord.Name)) {
                $DnsCache[$CacheRecord.Name] = $DnsCache[$CacheRecord.Name] |
                    Where-Object { $_.IPAddress -ne $CacheRecord.IPAddress -and $_.RecordType -ne $CacheRecord.RecordType }
                    
                if ($DnsCache[$CacheRecord.Name].Count -eq 0) {
                    $DnsCache.Remove($CacheRecord.Name)
                }
            }
        }
    }
}