function Add-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Add a new CacheRecord to the DNS cache object.
    .DESCRIPTION
        Cache records must expose the following property members:

          - Name
          - TTL
          - RecordType
          - IPAddress
    .INPUTS
        Indented.Net.Dns.CacheRecord
    .EXAMPLE
        $CacheRecord | Add-InternalDnsCacheRecord
    #>

    [CmdletBinding(DefaultParameterSetName = 'CacheRecord')]
    [OutputType('DnsCacheRecord')]
    param (
        # A record to add to the cache.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'CacheRecord')]
        [PSTypeName('DnsCacheRecord')]
        $CacheRecord,

        # A resource record to add to the cache.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ResourceRecord')]
        [DnsResourceRecord]$ResourceRecord,

        # The cache object type.
        [ValidateSet('Address', 'Hint')]
        [String]$ResourceType = "Address",

        # A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
        [Switch]$Permanent
    )

    begin {
        if (-not $Permanent) {
            $time = Get-Date
        }
    }

    process {
        if ($ResourceRecord) {
            $CacheRecord = $ResourceRecord | Select-Object Name, TTL, RecordType, IPAddress |
                Add-Member -TypeName 'DnsCacheRecord' -PassThru
        }

        $CacheRecord |
            Add-Member ResourceType $ResourceType -PassThru |
            Add-Member Time $Time -PassThru |
            Add-Member Status -MemberType ScriptProperty -Value {
                if ($this.Time) {
                    if ($this.Time.AddSeconds($this.TTL) -lt (Get-Date)) {
                        'Expired'
                    } else {
                        'Active'
                    }
                } else {
                    'Permanent'
                }
            }

        if ($Script:dnsCache.Contains($CacheRecord.Name)) {
            # Add the record to the cache if it doesn't already exist.
            if (-not ($CacheRecord | Get-InternalDnsCacheRecord)) {
                $Script:dnsCache[$CacheRecord.Name] += $CacheRecord
            }
        } else {
            $Script:dnsCache.Add($CacheRecord.Name, @($CacheRecord))
            if (-not ($Script:dnsCacheReverse.Contains($CacheRecord.IPAddress))) {
                $Script:dnsCacheReverse.Add($CacheRecord.IPAddress, $CacheRecord.Name)
            }
        }
    }
}