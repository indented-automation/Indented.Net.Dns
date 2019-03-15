function Remove-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Remove an entry from the DNS cache object.
    .DESCRIPTION
        Remove-InternalDnsCacheRecord allows the removal of individual records from the cache, or removal of all records which expired.
    .INPUTS
      Indented.DnsResolver.RecordType
    .EXAMPLE
      Get-InternalDnsCacheRecord a.root-servers.net | Remove-InternalDnsCacheRecord
    .EXAMPLE
      Remove-InternalDnsCacheRecord -AllExpired
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'CacheRecord')]
    param(
        # A record to add to the cache.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'CacheRecord')]
        [PSTypeName('Indented.Net.Dns.CacheRecord')]
        $CacheRecord,

        # A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
        [Parameter(Mandatory, ParameterSetName = 'AllExpired')]
        [Switch]$AllExpired
    )

    begin {
        if ($AllExpired) {
            $expiredRecords = Get-InternalDnsCacheRecord | Where-Object Status -eq 'Expired'
            $expiredRecords | Remove-InternalDnsCacheRecord
        }
    }

    process {
        if (-not $AllExpired) {
            if ($Script:dnsCacheReverse.Contains($CacheRecord.IPAddress)) {
                $Script:dnsCacheReverse.Remove($CacheRecord.IPAddress)
            }
            if ($Script:dnsCache.Contains($CacheRecord.Name)) {
                $Script:dnsCache[$CacheRecord.Name] = $Script:dnsCache[$CacheRecord.Name] |
                    Where-Object { $_.IPAddress -ne $CacheRecord.IPAddress -and $_.RecordType -ne $CacheRecord.RecordType }

                if ($Script:dnsCache[$CacheRecord.Name].Count -eq 0) {
                    if ($pscmdlet.ShouldProcess('Removing {0} from cache' -f $CacheRecord.Name)) {
                        $Script:dnsCache.Remove($CacheRecord.Name)
                    }
                }
            }
        }
    }
}