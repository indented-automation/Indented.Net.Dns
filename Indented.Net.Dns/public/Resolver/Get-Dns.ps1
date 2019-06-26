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
        Get-Dns www.domain.example -NoSearchList

        No additional suffixes will be appended.
    .EXAMPLE
        Get-Dns www.domain.example -Iterative

        Attempt to perform an iterative lookup of www.domain.example, starting from the root hints.
    .EXAMPLE
        Get-Dns www.domain.example CNAME -NSSearch

        Attempt to return the CNAME record for www.domain.example from all authoritative servers for the parent zone.
    .EXAMPLE
        Get-Dns -Version -Server 10.0.0.1

        Request a version string from the server 10.0.0.1.
    .EXAMPLE
        Get-Dns domain.example -ZoneTransfer -Server 10.0.0.1

        Request a zone transfer, using AXFR, for domain.example from the server 10.0.0.1.
    .EXAMPLE
        Get-Dns domain.example -ZoneTransfer -SerialNumber 2 -Server 10.0.0.1

        Request a zone transfer, using IXFR and the serial number 2, for domain.example from the server 10.0.0.1.
    .EXAMPLE
        Get-Dns example. -DnsSec

        Request ANY record for the co.uk domain, advertising DNSSEC support.
    .LINK
        http://www.ietf.org/rfc/rfc1034.txt
        http://www.ietf.org/rfc/rfc1035.txt
        http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
    #>

    [CmdletBinding(DefaultParameterSetname = 'RecursiveQuery')]
    [OutputType('DnsMessage')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param (
        # A resource name to query, by default Get-Dns will use '.' as the name. IP addresses (IPv4 and IPv6) are automatically converted into an appropriate format to aid PTR queries.
        [ValidateDnsName()]
        [String]$Name = ".",

        # Any resource record type, by default a query for ANY will be sent.
        [Alias('Type')]
        [RecordType]$RecordType = [RecordType]::ANY,

        # By default the class is IN. CH (Chaos) may be used to query for name server information. HS (Hesoid) may be used if the name server supports it.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [RecordClass]$RecordClass = [RecordClass]::IN,

        # Remove the Recursion Desired (RD) flag from a query. Recursion is requested by default.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Alias('NoRecurse')]
        [Switch]$NoRecursion,

        # Advertise support for DNSSEC when executing a query.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$DnsSec,

        # Enable EDNS support, suppresses OPT RR advertising client support in DNS question.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$EDns,

        # By default the EDns buffer size is set to 4096 bytes.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [UInt16]$EDnsBufferSize = 4096,

        # Disable the use of TCP if a truncated response (TC flag) is seen when using UDP.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$NoTcpFallback,

        # If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries. If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.
        #
        # SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [String[]]$SearchList,

        # The use of a SearchList can be explicitly suppressed using the NoSearchList parameter.
        #
        # SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Switch]$NoSearchList,

        # A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).
        #
        # If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
        #
        # If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [Alias('ComputerName')]
        [String]$Server = (Get-DnsServerList -IPv6:$IPv6 | Select-Object -First 1),

        # Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$Tcp,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [UInt16]$Port = 53,

        # By default, queries will timeout after 5 seconds. The value may be set between 1 and 30 seconds.
        [ValidateRange(1, 30)]
        [Byte]$Timeout = 5,

        # Force the use of IPv6 for queries, if this parameter is set and the Server is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [Switch]$IPv6,

        # Forces Get-Dns to output intermediate requests which would normally be hidden, such as NXDomain replies when using a SearchList.
        [Switch]$DnsDebug
    )

    begin {
        Remove-InternalDnsCacheRecord -AllExpired
    }

    process {
        # Global query options

        $GlobalOptions = @{}
        if (-not $EDns -and $DnsSec) {
            Write-Warning "Get-Dns: EDNS support is mandatory for DNSSEC. Enabling EDNS for this request."
            $EDns = $true
        }
        if ($EDns) {
            $GlobalOptions.Add('EDns', $true)
        } else {
            $GlobalOptions.Add('EDnsBufferSize', $EDnsBufferSize)
        }
        if ($DnsSec) {
            $GlobalOptions.Add('DnsSec', $true)
        }
        if ($NoTcpFallback) {
            $GlobalOptions.Add('NoTcpFallback', $true)
        }

        try {
            $serverIPAddress = Resolve-DnsServer -Server $Server -IPv6:$IPv6
            if ($serverIPAdddress.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
                Write-Verbose "Resolve-DnsServer: IPv6 server value used. Using IPv6 transport."
                $IPv6 = $true
            }
            $Server = $serverIPAddress
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }

        $SearchStatus = [RCode]::NXDomain
        $i = 0

        foreach ($suffix in $SearchList) {
            if ($suffix) {
                $fullName = '{0}.{1}' -f $Name, $suffix
            } else {
                $fullName = $Name
            }

            # Move this.
            Write-Debug ("Get-Dns: Query: {0} {1} {2} :: Server: {3} Protocol: {4} AddressFamily: {5}" -f @(
                $FullName
                $RecordClass
                $RecordType
                $Server
                ('UDP', 'TCP')[$Tcp.ToBool()]
                ('IPv4', 'IPv6')[$IPv6.ToBool()]
            ))

            $message = [DnsMessage]::new(
                $FullName,
                $RecordType,
                $RecordClass
            )

            if ($EDns) {
                $message.SetEDnsBufferSize($EDnsBufferSize)
            }
            if ($DnsSec) {
                $message.SetAcceptDnsSec()
            }
            if ($NoRecursion) {
                $message.Header.Flags = [HeaderFlags]([UInt16]$DnsQuery.Header.Flags -bxor [UInt16][HeaderFlags]::RD)
            }

            $client = [DnsClient]@{
                Server         = $Server
                Port           = $Port
                SendTimeout    = $Timeout
                ReceiveTimeout = $Timeout
                UseTcp         = $Tcp
            }

            try {
                $client.SendQuestion($message)
                $client.ReceiveAnswer()

                if ($SearchStatus -ne [RCode]::NXDomain -or $DnsDebug) {
                    if ($DnsResponse.Header.Flags -band [HeaderFlags]::TC) {
                        if ($NoTcpFallback) {
                            $DnsResponse
                        } else {
                            Write-Debug 'Response is truncated. Resending using TCP'
                            $DnsResponse = $null
                            Get-Dns @psboundparameters -Tcp
                        }
                    } else {
                        $DnsResponse
                    }

                    if ($DnsResponse) {
                        $DnsResponse.TimeTaken = (New-TimeSpan $Start (Get-Date)).TotalMilliseconds
                        $DnsResponse.Server = $DnsResponseData.RemoteEndpoint

                        # Update the SearchList loop exit criteria
                        $SearchStatus = $DnsResponse.Header.RCode

                        if ($Server -ne $serverIPAddress) {
                            $DnsResponse.Server = '{0} ({1})' -f $Server, $DnsResponse.Server
                        }

                        if ($SearchStatus -eq [RCode]::NXDomain -and $i -eq ($SearchList.Count - 1)) {
                            Write-Warning ('Get-Dns: Name ({0}) does not exist.' -f $Name)
                        }
                    }
                }

                $client.Close()

            } catch [SocketException] {
                $errorRecord = [ErrorRecord]::new(
                    [SocketException]::new($_.Exception.InnerException.NativeErrorCode),
                    'Timeout',
                    [ErrorCategory]::ConnectionError,
                    $Socket
                )
                $pscmdlet.ThrowTerminatingError($errorRecord)
            } catch {

            }
        }
    }
}