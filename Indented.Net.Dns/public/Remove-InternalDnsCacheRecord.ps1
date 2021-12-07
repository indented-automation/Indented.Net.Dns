function Remove-InternalDnsCacheRecord {
    <#
    .SYNOPSIS
        Remove a single entry from the internal DNS cache.
    .DESCRIPTION
        Remove a single entry from the internal DNS cache.
    .EXAMPLE
        Remove-InternalDnsCacheRecord someName -RecordType A
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the record to retrieve.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [string]$Name,

        # The record type to retrieve.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateSet('A', 'AAAA')]
        [RecordType]$RecordType
    )

    process {
        if (-not $Name.EndsWith('.')) {
            $Name += '.'
        }

        if ($Script:dnsCache.Contains($Name)) {
            if ($PSCmdlet.ShouldProcess('Removing {0} from cache' -f $Name)) {
                if ($RecordType) {
                    $Script:dnsCache[$Name] = $Script:dnsCache[$Name] | Where-Object {
                        $_.RecordType -ne $RecordType
                    }

                    if ($Script:dnsCache[$Name].Count -eq 0) {
                        $Script:dnsCache.Remove($Name)
                    }
                } else {
                    $Script:dnsCache.Remove($Name)
                }
            }
        }
    }
}
