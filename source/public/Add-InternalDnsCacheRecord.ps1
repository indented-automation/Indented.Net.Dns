function Add-InternalDnsCacheRecord {
    # .SYNOPSIS
    #   Add a new CacheRecord to the DNS cache object.
    # .DESCRIPTION
    #   Cache records must expose the following property members:
    #
    #    - Name
    #    - TTL
    #    - RecordType
    #    - IPAddress
    #
    # .PARAMETER CacheRecord
    #   A record to add to the cache.
    # .PARAMETER Permanent
    #   A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
    # .INPUTS
    #   Indented.Net.Dns.CacheRecord
    # .EXAMPLE
    #   $CacheRecord | Add-InternalDnsCacheRecord
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.
    #     07/04/2015 - Chris Dent - BugFix: Type check for CacheRecord.
    #     13/01/2015 - Chris Dent - Forked from source module.

    [CmdletBinding(DefaultParameterSetName = 'CacheRecord')]
    [OutputType('Indented.Net.Dns.CacheRecord')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CacheRecord')]
        [PSTypeName('Indented.Net.Dns.CacheRecord')]
        $CacheRecord,

        [Parameter(Mandatory = $true, ParameterSetName = 'ResourceRecord')]
        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord,

        [ValidateSet('Address', 'Hint')]
        [String]$ResourceType = "Address",

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
                Add-Member -TypeName 'Indented.Net.Dns.CacheRecord' -PassThru
        }

        $CacheRecord |
            Add-Member ResourceType $ResourceType -PassThru |
            Add-Member Time $Time -PassThru |
            Add-Member Status -MemberType ScriptProperty -Value {
                if ($this.Time) {
                    if ($this.Time.AddSeconds($this.TTL) -lt (Get-Date)) {
                        "Expired"
                    } else {
                        "Active"
                    }
                } else {
                    "Permanent"
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