function Add-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Add a new CacheRecord to the DNS cache object.
    .DESCRIPTION
        The DNS cache is used to reduce the effort required to resolve DNS server names used with the ComputerName parameter.
    .INPUTS
        DnsCacheRecord
        DnsResourceRecord
    .EXAMPLE
        $CacheRecord | Add-InternalDnsCacheRecord
    #>

    [CmdletBinding(DefaultParameterSetName = 'CacheRecord')]
    [OutputType('DnsCacheRecord')]
    param (
        # A record to add to the cache.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'CacheRecord')]
        [DnsCacheRecord]$CacheRecord,

        # A resource record to add to the cache.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ResourceRecord')]
        [DnsResourceRecord]$ResourceRecord,

        # The cache object type.
        [CacheResourceType]$ResourceType = 'Address',

        # A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
        [Switch]$Permanent
    )

    process {
        if ($ResourceRecord) {
            $CacheRecord = $ResourceRecord
        }

        $CacheRecord.ResourceType = $ResourceType
        if ($Permanent) {
            $CacheRecord.IsPermanent = $true
        }

        if ($Script:dnsCache.Contains($CacheRecord.Name)) {
            if ($Script:dnsCache.Contains($CacheRecord.Name)) {
                $Script:dnsCache[$CacheRecord.Name] += $CacheRecord
            }
        } else {
            $Script:dnsCache.Add($CacheRecord.Name, @($CacheRecord))
        }
    }
}