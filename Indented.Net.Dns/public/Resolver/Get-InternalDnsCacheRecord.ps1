function Get-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Get the content of the internal DNS cache used by Get-Dns.
    .DESCRIPTION
        Get-InternalDnsCacheRecord displays records held in the cache.
    .INPUTS
        Indented.Net.Dns.CacheRecord
        Indented.Net.Dns.ResourceRecord
    .EXAMPLE
        Get-InternalDnsCacheRecord
    .EXAMPLE
        Get-InternalDnsCacheRecord a.root-servers.net A
    #>

    [CmdletBinding()]
    [OutputType('DnsCacheRecord')]
    param (
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [String]$Name,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [RecordType]$RecordType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [IPAddress]$IPAddress,

        [ValidateSet('Address', 'Hint')]
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
                $Name = '{0}.' -f $Name
            }
            if ($Script:dnsCache.Contains($Name)) {
                $Script:dnsCache[$Name] | Where-Object $whereStatement
            }
        } else {
            # Each key may contain multiple values. Forcing a pass through ForEach-Object will
            # remove the multi-dimensional aspect of the return value.
            $Script:dnsCache.Values | ForEach-Object { $_ } | Where-Object $whereStatement
        }
    }
}