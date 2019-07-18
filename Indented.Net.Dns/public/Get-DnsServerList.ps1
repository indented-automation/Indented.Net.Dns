using namespace System.Management.Automation
using namespace System.Net.NetworkInformation
using namespace System.Net.Sockets

function Get-DnsServerList {
    <#
    .SYNOPSIS
        Gets a list of network interfaces and attempts to return a list of DNS server IP addresses.
    .DESCRIPTION
        Get-DnsServerList uses System.Net.NetworkInformation to return a list of operational ethernet or wireless interfaces. IP properties are returned, and an attempt to return a list of DNS server addresses is made. If successful, the DNS server list is returned.
    .EXAMPLE
        Get-DnsServerList
    .EXAMPLE
        Get-DnsServerList -IPv6
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # Find DNS servers which support IPv6.
        [Switch]$IPv6
    )

    if ($IPv6) {
        $AddressFamily = [AddressFamily]::InterNetworkv6
    } else {
        $AddressFamily = [AddressFamily]::InterNetwork
    }

    if ([NetworkInterface]::GetIsNetworkAvailable()) {
        [NetworkInterface]::GetAllNetworkInterfaces().
            Where{ $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -match 'Ethernet|Wireless' }.
            ForEach{ $_.GetIPProperties().DnsAddresses }.
            Where{ $_.AddressFamily -eq $AddressFamily }
    } else {
        $errorRecord = [ErrorRecord]::new(
            [InvalidOperationException]::new('Failed to locate an available network'),
            'NoDnsServersAvailable',
            'InvalidOperation',
            $null
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
    }
}