function Clear-InternalDnsCache {
    <#
    .SYNOPSIS
        Clears expired entries from the internal DNS cache.
    .DESCRIPTION
        Clear expired entries from the internal DNS cache.
    .EXAMPLE
        Clear-InternalDnsCacheRecord
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [switch]$ExpiredOnly
    )

    if ($ExpiredOnly) {
        (Get-InternalDnsCacheRecord | Where-Object { $_.HasExpired() }) |
            Remove-InternalDnsCacheRecord
    } else {
        if ($PSCmdlet.ShouldProcess('Clearing DNS cache')) {
            $Script:dnsCache.Clear()
        }
    }
}
