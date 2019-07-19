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
        [Switch]$ExpiredOnly
    )

    if ($ExpiredOnly) {
        (Get-InternalDnsCacheRecord | Where-Object { $_.HasExpired() }) |
            Remove-InternalDnsCacheRecord
    } else {
        if ($pscmdlet.ShouldProcess('Clearing DNS cache')) {
            $Script:dnsCache.Clear()
        }
    }
}