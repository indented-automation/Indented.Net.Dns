function GetDnsSuffixSearchList {
    <#
    .SYNOPSIS
        Attempt to discover a DNS suffix search list.
    .DESCRIPTION
        Attempt to discover a DNS suffix search list.
    #>

    [CmdletBinding()]
    param (
        [String]$Name
    )

    if (-not $Name.EndsWith('.')) {
        if (-not $psversiontable.Platform -or $psversiontable.Platform -eq 'Win32NT') {
            $params = @{
                ClassName = 'Win32_NetworkAdapterConfiguration'
                Property  = 'DNSDomainSuffixSearchOrder'
            }
            (Get-CimInstance @params).DNSDomainSuffixSearchOrder
        } elseif (Test-Path '/etc/resolv.conf') {
            Get-Content '/etc/resolv.conf' | Where-Object { $_ -match '^search (.+)' } | ForEach-Object {
                $matches[1] -split '\s+'
            }
        }
    }
}