function Get-InternalDnsCacheRecord {
    # .SYNOPSIS
    #   Get the content of the internal DNS cache used by Get-Dns.
    # .DESCRIPTION
    #   Get-InternalDnsCacheRecord displays records held in the cache.
    # .INPUTS
    #   Indented.DnsResolver.RecordType
    #   System.Net.IPAddress
    #   System.String
    # .OUTPUTS
    #   Indented.DnsResolver.Message.CacheRecord
    # .EXAMPLE
    #   Get-InternalDnsCacheRecord
    # .EXAMPLE
    #   Get-InternalDnsCacheRecord a.root-servers.net A
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     23/03/2017 - Chris Dent - Modernisation passd
    #     13/01/2015 - Chris Dent - Forked from source module.

    [CmdletBinding()]
    param(
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [String]$Name,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [Indented.DnsResolver.RecordType]$RecordType,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [IPAddress]$IPAddress,

        [ValidateSet("Address", "Hint")]
        [String]$ResourceType
    )

    process {
        $whereStatementText = '$_'
        if ($ResourceType) {
            $whereStatementText += ' -and $_.ResourceType -eq $ResourceType'
        }
        if ($RecordType) {
            $whereStatementText += ' -and $_.RecordType -eq $RecordType'
        }
        if ($IPAddress) {
            $whereStatementText += ' -and $_.IPAddress -eq $IPAddress'
        }
        # Create a ScriptBlock using the statements above.
        $whereStatement = [ScriptBlock]::Create($whereStatementText)

        if ($Name) {
            if (-not $Name.EndsWith('.')) {
                $Name = "$Name."
            }
            if ($DnsCache.Contains($Name)) {
                $DnsCache[$Name] | Where-Object $whereStatement
            }
        } else {
            # Each key may contain multiple values. Forcing a pass through ForEach-Object will
            # remove the multi-dimensional aspect of the return value.
            $DnsCache.Values | ForEach-Object { $_ } | Where-Object $whereStatement
        }
    }
}