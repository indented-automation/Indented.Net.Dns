using namespace System.Management.Automation
using namespace System.Net.Sockets

function Get-Dns {
    <#
    .SYNOPSIS
        Get a DNS resource record from a DNS server.
    .DESCRIPTION
        Get-Dns is a debugging resolver tool similar to dig and nslookup.
    .EXAMPLE
        Get-Dns hostname

        Attempt to resolve hostname using the system-configured search list.
    .EXAMPLE
        Get-Dns www.domain.example

        The system-configured search list will be appended to this query before it is executed.
    .EXAMPLE
        Get-Dns www.domain.example.

        The name is fully-qualified (or root terminated), no additional suffixes will be appended.
    .EXAMPLE
        Get-Dns example. -DnsSec

        Request ANY record for the co.uk domain, advertising DNSSEC support.
    #>

    [CmdletBinding()]
    [OutputType('DnsMessage')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    param (
        # A resource name to query, by default Get-Dns will use '.' as the name. IP addresses (IPv4 and IPv6) are automatically converted into an appropriate format to aid PTR queries.
        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [TransformDnsName()]
        [ValidateDnsName()]
        [string]$Name = ".",

        # Any resource record type, by default a query for ANY will be sent.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [Alias('Type')]
        [RecordType]$RecordType = [RecordType]::ANY,

        # By default the class is IN. CH (Chaos) may be used to query for name server information. HS (Hesoid) may be used if the name server supports it.
        [RecordClass]$RecordClass = [RecordClass]::IN,

        # Remove the Recursion Desired (RD) flag from a query. Recursion is requested by default.
        [Alias('NoRecurse')]
        [switch]$NoRecursion,

        # Advertise support for DNSSEC when executing a query.
        [switch]$DnsSec,

        # Enable EDNS support, suppresses OPT RR advertising client support in DNS question. Automatically enabled if DNSSEC is requested.
        [switch]$EDns,

        # By default the EDns buffer size is set to 4096 bytes.
        [ushort]$EDnsBufferSize = 4096,

        # Disables conversion of international domain names to unicode in responses.
        [switch]$DisableIdnConversion,

        # Disable the use of TCP if a truncated response (TC flag) is seen when using UDP.
        [Alias('Ignore')]
        [switch]$NoTcpFallback,

        # If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries. If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.
        #
        # An empty search list by be specified by providing an empty array for this parameter.
        [AllowEmptyCollection()]
        [string[]]$SearchList = (GetDnsSuffixSearchList),

        # Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
        [Alias('vc')]
        [switch]$Tcp,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [ushort]$Port = 53,

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
        [string]$ComputerName = (Get-DnsServerList -IPv6:$IPv6 | Select-Object -First 1),

        # Forces Get-Dns to output intermediate requests which would normally be hidden, such as NXDomain replies when using a SearchList.
        [switch]$DnsDebug
    )

    begin {
        Clear-InternalDnsCache -ExpiredOnly
    }

    process {
        try {
            $serverIPAddress = ResolveDnsServer -ComputerName $ComputerName -IPv6:$IPv6
            if ($serverIPAdddress.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
                Write-Verbose "Resolve-DnsServer: IPv6 server value used. Using IPv6 transport."
                $IPv6 = $true
            }
            $ComputerName = $serverIPAddress
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        $querySearchList = $SearchList
        if ($Name.EndsWith('.')) {
            $querySearchList = ''
        } elseif ($Name.IndexOf('.') -ne $Name.LastIndexOf('.')) {
            $querySearchList += ''
        }

        $querySearchListPosition = 0
        foreach ($suffix in $querySearchList) {
            $querySearchListPosition++

            if ($suffix) {
                $fullName = '{0}.{1}' -f $Name, $suffix
            } else {
                $fullName = $Name
            }

            $dnsMessage = [DnsMessage]::new(
                $fullName,
                $RecordType,
                $RecordClass
            )

            if ($EDns -or $DnsSec) {
                $dnsMessage.SetEDnsBufferSize($EDnsBufferSize)
            }
            if ($DnsSec) {
                $dnsMessage.SetAcceptDnsSec()
            }
            if ($NoRecursion) {
                $dnsMessage.DisableRecursion()
            }

            try {
                $dnsClient = [DnsClient]::new(
                    $Tcp.IsPresent,
                    ([IPAddress]$ComputerName).AddressFamily -eq 'InterNetworkV6',
                    $Timeout,
                    $Timeout
                )

                $dnsClient.SendQuestion(
                    $dnsMessage,
                    $ComputerName,
                    $Port
                )

                $dnsResponse = $dnsClient.ReceiveAnswer(-not $DisableIdnConversion)
                $dnsResponse.ComputerName = $dnsClient.RemoteEndPoint
                $dnsResponse.TimeTaken = $dnsClient.TimeTaken.TotalMilliseconds
                $dnsClient.Close()

                if ($dnsResponse.Header.RCode -ne 'NXDOMAIN' -or
                    $querySearchListPosition -eq $querySearchList.Count -or
                    $dnsDebug) {

                    if ($dnsResponse.Header.Flags -band 'TC' -and -not $NoTcpFallback) {
                        Write-Debug 'Response is truncated. Resending using TCP'

                        Get-Dns @psboundparameters -Tcp

                        break
                    } else {
                        $dnsResponse
                    }

                    if (-not $dnsDebug) {
                        break
                    }
                }
            } catch [SocketException] {
                $errorRecord = [ErrorRecord]::new(
                    $_.Exception,
                    'Timeout',
                    [ErrorCategory]::ConnectionError,
                    $Socket
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}
