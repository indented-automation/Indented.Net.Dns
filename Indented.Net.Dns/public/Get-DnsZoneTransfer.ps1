function Get-DnsZoneTransfer {
    <#
    .SYNOPSIS
        Get the content of a DNS zone using zone transfer.

    .DESCRIPTION
        Get the content of a DNS zone using zone transfer.
    #>

    [CmdletBinding()]
    param (
        # The name of the zone to transfer.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [TransformDnsName()]
        [ValidateDnsName()]
        [string]$ZoneName,

        # If the serial number is set, an incremental zone transfer is performed.
        [UInt32]$SerialNumber,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [UInt16]$Port = 53,

        # By default, queries will timeout after 5 seconds. The value may be set between 1 and 30 seconds.
        [ValidateRange(1, 30)]
        [byte]$Timeout = 5,

        # Force the use of IPv6 for queries, if this parameter is set and the ComputerName is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
        [switch]$IPv6,

        # A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).
        #
        # If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
        #
        # If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.
        [Alias('Server')]
        [string]$ComputerName
    )

    begin {
        try {
            $serverIPAddress = ResolveDnsServer -ComputerName $ComputerName -IPv6:$IPv6
            if ($serverIPAdddress.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
                Write-Verbose 'IPv6 server value used. Using IPv6 transport.'
                $IPv6 = $true
            }
            $ComputerName = $serverIPAddress
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    process {
        if ($SerialNumber) {
            $dnsMessage = [DnsMessage]::new(
                $ZoneName,
                'IXFR',
                'IN',
                $SerialNumber
            )
        } else {
            $dnsMessage = [DnsMessage]::new(
                $ZoneName,
                'AXFR',
                'IN'
            )
        }

        $dnsClient = [DnsClient]::new(
            $true,
            ([IPAddress]$ComputerName).AddressFamily -eq 'InterNetworkV6',
            $Timeout,
            $Timeout
        )

        $dnsClient.SendQuestion(
            $dnsMessage,
            $ComputerName,
            $Port
        )

        $dnsResponse = $dnsClient.ReceiveAnswer()
        $dnsResponse.ComputerName = $dnsClient.RemoteEndPoint
        $dnsResponse.TimeTaken = $dnsClient.TimeTaken.TotalMilliseconds
        $dnsClient.Close()

        $dnsResponse
    }
}
