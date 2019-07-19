function Get-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Get the content of the internal DNS cache used by Get-Dns.
    .DESCRIPTION
        Get-InternalDnsCacheRecord displays records held in the cache.
    .INPUTS
        Indented.Net.Dns.CacheRecord
    .EXAMPLE
        Get-InternalDnsCacheRecord
    .EXAMPLE
        Get-InternalDnsCacheRecord a.root-servers.net A
    #>

    [CmdletBinding()]
    [OutputType('DnsCacheRecord')]
    param (
        # The name of the record to retrieve.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [String]$Name,

        # The record type to retrieve.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [String]$RecordType,

        # The resource type to retrieve.
        [ValidateSet('Address', 'Hint')]
        [String]$ResourceType
    )

    process {
        if ($Name) {
            if (-not $Name.EndsWith('.')) {
                $Name += '.'
            }
            if ($Script:dnsCache.Contains($Name)) {
                $Script:dnsCache[$Name] | Where-Object {
                    -not $RecordType -or $_.RecordType -eq $RecordType
                }
            }
        } else {
            $Script:dnsCache.Values | ForEach-Object { $_ } | Where-Object {
                (-not $RecordType -or $_.RecordType -eq $RecordType) -and
                (-not $ResourceType -or $_.ResourceType -eq $ResourceType)
            }
        }
    }
}