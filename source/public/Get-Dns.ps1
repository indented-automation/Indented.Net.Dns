using namespace Indented.Net.Dns
using namespace System.Management.Automation
using namespace System.Net.Sockets

function Get-Dns {
    # .SYNOPSIS
    #   Get a DNS resource record from a DNS server.
    # .DESCRIPTION
    #   Get-Dns is a debugging resolver tool similar to dig and nslookup.
    # .PARAMETER DnsDebug
    #   Forces Get-Dns to output intermediate requests which would normally be hidden, such as NXDomain replies when using a SearchList.
    # .PARAMETER DnsSec
    #   Advertise support for DNSSEC when executing a query.
    # .PARAMETER EDnsBufferSize
    #   By default the EDns buffer size is set to 4096 bytes. If NoEDns is used this value is ignored.
    # .PARAMETER IPv6
    #   Force the use of IPv6 for queries, if this parameter is set and the Server is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
    # .PARAMETER Iterative
    #   Perform a full iterative search for a name starting with the root servers. Intermediate queries are resolved using the locally configured name server to reduce the work-load as Get-Dns does not implement response caching.
    # .PARAMETER Name
    #   A resource name to query, by default Get-Dns will use '.' as the name. IP addresses (IPv4 and IPv6) are automatically converted into an appropriate format to aid PTR queries.
    # .PARAMETER NoEDns
    #   Disable EDNS support, suppresses OPT RR advertising client support in DNS question.
    # .PARAMETER NoRecursion
    #   Remove the Recursion Desired (RD) flag from a query. Recursion is requested by default.
    # .PARAMETER NoSearchList
    #   The use of a SearchList can be explicitly suppressed using the NoSearchList parameter.
    #
    #   SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
    # .PARAMETER NoTcpFallback
    #   Disable the use of TCP if a truncated response (TC flag) is seen when using UDP.
    # .PARAMETER NSSearch
    #   Locate the authoritative servers for a zone (using Server as a starting point), then execute a the query against each authoritative server. Aids the testing of replication failure between authoritative servers.
    # .PARAMETER Port
    #   By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
    # .PARAMETER RecordClass
    #   By default the class is IN. CH (Chaos) may be used to query for name server information. HS (Hesoid) may be used if the name server supports it.
    # .PARAMETER RecordType
    #   Any resource record type, by default a query for ANY will be sent.
    # .PARAMETER SearchList
    #   If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries. If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.
    #
    #   SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
    # .PARAMETER SerialNumber
    #   The SerialNumber is used only if the RecordType is set to IXFR (either directly, or by using the ZoneTransfer parameter).
    # .PARAMETER Server
    #   A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter). 
    #
    #   If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
    #
    #   If no server name is defined, the Get-DnsServerList CmdLet is used to discover locally configured DNS servers.
    # .PARAMETER Tcp
    #   Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
    # .PARAMETER Timeout
    #   By default, queries will timeout after 5 seconds. The default value can be changed using the Timeout parameter. The value may be set between 1 and 30 seconds.
    # .PARAMETER Version
    #   Generates and sends a query for version.bind. using TXT as the RecordType and CH (Chaos) as the RecordClass.
    # .PARAMETER ZoneTransfer
    #   Constructs and executes a zone transfer request. If SerialNumber is also set an IXFR request will be generated using the algorithm discussed in draft-ietf-dnsind-ixfr-01. If SerialNumber is not set an AXFR request will be sent.
    #
    #   The use of TCP or UDP for zone transfer requests is fixed, AXFR will always use TCP. IXFR will attempt UDP and switch to TCP if a stub response is returned.
    # .OUTPUTS
    #   Indented.DnsResolver.Message
    # .EXAMPLE
    #   Get-Dns hostname
    #
    #   Attempt to resolve hostname using the system-configured search list.
    # .EXAMPLE
    #   Get-Dns www.domain.example
    #
    #   The system-configured search list will be appended to this query before it is executed.
    # .EXAMPLE
    #   Get-Dns www.domain.example.
    #
    #   The name is fully-qualified (or root terminated), no additional suffixes will be appended.
    # .EXAMPLE
    #   Get-Dns www.domain.example -NoSearchList
    #
    #   No additional suffixes will be appended.
    # .EXAMPLE
    #   Get-Dns www.domain.example -Iterative
    #
    #   Attempt to perform an iterative lookup of www.domain.example, starting from the root hints.
    # .EXAMPLE
    #   Get-Dns www.domain.example CNAME -NSSearch
    #
    #   Attempt to return the CNAME record for www.domain.example from all authoritative servers for the parent zone.
    # .EXAMPLE
    #   Get-Dns -Version -Server 10.0.0.1
    #
    #   Request a version string from the server 10.0.0.1.
    # .EXAMPLE
    #   Get-Dns domain.example -ZoneTransfer -Server 10.0.0.1
    #
    #   Request a zone transfer, using AXFR, for domain.example from the server 10.0.0.1.
    # .EXAMPLE
    #   Get-Dns domain.example -ZoneTransfer -SerialNumber 2 -Server 10.0.0.1
    #
    #   Request a zone transfer, using IXFR and the serial number 2, for domain.example from the server 10.0.0.1.
    # .EXAMPLE
    #   Get-Dns example. -DnsSec
    #
    #   Request ANY record for the co.uk domain, advertising DNSSEC support.
    # .LINK
    #   http://www.ietf.org/rfc/rfc1034.txt
    #   http://www.ietf.org/rfc/rfc1035.txt
    #   http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Moderisation pass
    #     28/04/2014 - Chris Dent - Released.

    [CmdletBinding(DefaultParameterSetname = 'RecursiveQuery')]
    param(
        [Parameter(Position = 1, ParameterSetName = 'RecursiveQuery')]
        [Parameter(Position = 1, ParameterSetName = 'IterativeQuery')]
        [Parameter(Position = 1, ParameterSetName = 'NSSearch')]
        [Parameter(Position = 1, ParameterSetName = 'ZoneTransfer')]
        [ValidateDnsName()]
        [String]$Name = ".",

        [Parameter(Position = 2, ParameterSetname = 'RecursiveQuery')]
        [Parameter(Position = 2, ParameterSetname = 'IterativeQuery')]
        [Parameter(Position = 2, ParameterSetName = 'NSSearch')]
        [Alias('Type')]
        [RecordType]$RecordType = [RecordType]::ANY,

        [Parameter(Mandatory = $true, ParameterSetName = 'IterativeQuery')]
        [Alias('Trace')]
        [Switch]$Iterative,

        [Parameter(Mandatory = $true, ParameterSetName = 'NSSearch')]
        [Switch]$NSSearch,

        [Parameter(Mandatory = $true, ParameterSetName = 'Version')]
        [Switch]$Version,

        [Parameter(Mandatory = $true, ParameterSetName = 'ZoneTransfer')]
        [Alias('Transfer')]
        [Switch]$ZoneTransfer,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [RecordClass]$RecordClass = [RecordClass]::IN,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Alias('NoRecurse')]
        [Switch]$NoRecursion,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$DnsSec,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$NoEDns,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [UInt16]$EDnsBufferSize = 4096,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'IterativeQuery')]
        [Parameter(ParameterSetName = 'NSSearch')]
        [Switch]$NoTcpFallback,    

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [String[]]$SearchList,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Switch]$NoSearchList,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [UInt32]$SerialNumber,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [Alias('ComputerName')]
        [String]$Server = (Get-DnsServerList -IPv6:$IPv6 | Select-Object -First 1),

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$Tcp,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [UInt16]$Port = 53,

        [ValidateRange(1, 30)]
        [Byte]$Timeout = 5,

        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [Switch]$IPv6,

        [Switch]$DnsDebug
    )

    # Cache maintenance

    Remove-InternalDnsCacheRecord -AllExpired

    # Reset global control flags

    $Script:DnsTCEndFound = $false

    # Global query options

    $GlobalOptions = @{}
    if ($NoEDns -and $DnsSec) {
        Write-Warning "Get-Dns: EDNS support is mandatory for DNSSEC. Enabling EDNS for this request."
        $NoEDns = $false
    }
    if ($NoEDns) {
        $GlobalOptions.Add('NoEDns', $true) 
    } else {
        $GlobalOptions.Add('EDnsBufferSize', $EDnsBufferSize)     
    }
    if ($DnsSec) {
        $GlobalOptions.Add('DnsSec', $true)
    }
    if ($NoTcpFallback) {
        $GlobalOptions.Add('NoTcpFallback', $true) 
    }

    if ($IPv6) {
        $serverRecordType = [Indented.DnsResolver.RecordType]::AAAA
    } else {
        $serverRecordType = [Indented.DnsResolver.RecordType]::A
    }

    # Recursive call to find the IP address associated with a server name (if a name is supplied instead of an IP)
    $ipAddress = New-Object IPAddress 0
    if ([IPAddress]::TryParse($Server, [Ref]$ipAddress)) {
        # Forcefully switch to IPv6 mode if an IPv6 server address is supplied.
        if ($ipAddress.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
            Write-Verbose "Get-Dns: Server: IPv6 Server value used. Switching to IPv6 transport."
            $IPv6 = $true
        }
    } else {
        # Unable to parse the server as an IP address. Attempt to resolve it.

        # Attempt a cache lookup - Note: This will not catch servers names which resolve because suffixes have been added.
        $CachedServer = Get-InternalDnsCacheRecord $Server $ServerRecordType
        if ($CachedServer) {
            Write-Verbose "Get-Dns: Cache: Using Server ($Server) from cache."
            $IPAddress = $CachedServer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress
        } else {
            # If the cache lookup fails, execute a full lookup
            Write-Verbose "Get-Dns: Server: Attempting to lookup $Server $ServerRecordType"
            $DnsResponse = Get-Dns $Server -RecordType $ServerRecordType

            if ($DnsResponse.Answer) {
                # Addresses will be returned using round-robin ordering. Honour that and use the first address.
                $IPAddress = $DnsResponse.Answer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress

                # Add the response to the cache.
                Write-Verbose "Get-Dns: Cache: Adding Server ($Server) to cache."
                $DnsResponse.Answer | ForEach-Object {
                    Add-InternalDnsCacheRecord -ResourceRecord $_
                }
            }
        }
        if ($IPAddress) {
            $Server = $IPAddress
        } else {
            # Failed to resolve name. Return an error.
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
                (New-Object ArgumentException "Unable to find an IP address for the specified name server ($Server)."),
                "ArgumentException",
                [Management.Automation.ErrorCategory]::InvalidArgument,
                $Server)
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
        }
    }

    # Suffix search list

    # Used if:
    #
    # 1. The name does not end with '.' (root terminated).
    # 2. A search list has not been defined.
    #
    # Skipped if:
    #
    # 1. An Iterative query is being performed.
    # 2. A zone transfer is not being performed (AXFR or IXFR).
    # 3. NoSearchList has been set.
    #
    # Applies to both single-label and multi-label names.
    if ($NoSearchList -or $NSSearch -or $Iterative -or $ZoneTransfer -or $Name.EndsWith('.')) {
        $SearchList = ""
    } else {
        if (-not $SearchList) {
            # If a search list has not been passed using the SearchList parameter attempt to discover one.
            $SearchList = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration |
                Where-Object DNSDomainSuffixSearchOrder |
                Select-Object -ExpandProperty DNSDomainSuffixSearchOrder |
                ForEach-Object { "$_." }
            Write-Verbose "Get-Dns: SearchList: Automatically retrieved and set to $SearchList"
        }
            # If the name is multi-label allow it to be sent without a suffix.
        if ($Name -match '[^.]+\.[^.]+') {
            # Add an empty (root) SearchList item
            $SearchList += ""
        }
    }
    # For consistent operation now the search list has been set.
    if (-not $Name.EndsWith('.')) {
        $Name = "$Name."
    }

    #
    # Advanced queries and queries requiring recursive calls.
    #

    #
    # Version requests
    #

    if ($Version) {
        # RFC 4892 (http://www.ietf.org/rfc/rfc4892.txt)
        $Name = "version.bind."
        $RecordType = [RecordType]::TXT
        $RecordClass = [RecordClass]::CH
    }

    #
    # Iterative searches
    #

    if ($Iterative) {
        # Pick a random(ish) server from Root Hints
        $HintRecordSet = Get-InternalDnsCacheRecord -RecordType A -ResourceType Hint
        $Server = $HintRecordSet[(Get-Random -Minimum 0 -Maximum ($HintRecordSet.Count - 1))] | Select-Object -ExpandProperty IPAddress

        $NoError = $true; $NoAnswer = $true
        while ($NoError -and $NoAnswer) {
            $DnsResponse = Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -NoRecursion -Server $Server @GlobalOptions

            if ($DnsResponse.Header.RCode -ne [RCode]::NoError)  {
                $NoError = $false
            } else {
                if ($DnsResponse.Header.ANCount -gt 0) {
                $NoAnswer = $false
                } elseif ($DnsResponse.Header.NSCount -gt 0) {
                    $Authority = $DnsResponse.Authority | Select-Object -First 1

                    # Attempt to match between Authority and Additional. No need to execute another lookup if we have the information.
                    $Server = $DnsResponse.Additional |
                        Where-Object { $_.Name -eq $Authority.Hostname -and $_.RecordType -eq [RecordType]::A } |
                        Select-Object -ExpandProperty IPAddress |
                        Select-Object -First 1
                    if ($Server) {
                        Write-Verbose "Get-Dns: Iterative query: Next name server IP: $Server"
                    } else {
                        $Server = $Authority[0].Hostname
                        Write-Verbose "Get-Dns: Iterative query: Next name server Name: $Server"
                    }
                }
            }

            # Return the response to the output pipeline
            $DnsResponse
        }
    }

    #
    # Name server searches
    #

    if ($NSSearch) {
        # Get the zone name from the SOA record
        Write-Verbose "Get-Dns: NSSearch: Finding start of authority."
        $DnsResponse = Get-Dns $Name -RecordType SOA -Server $Server -NoSearchList
        if ($DnsDebug) {
            $DnsResponse
        }
        if ($DnsResponse.Header.RCode -eq [RCode]::NoError -and $DnsResponse.Header.ANCount -gt 0) {
            $ZoneName = $DnsResponse.Answer | Where-Object RecordType -eq ([RecordType]::SOA) | Select-Object -ExpandProperty Name
        } elseif ($DnsResponse.Header.RCode -eq [RCode]::NoError -and $DnsResponse.Header.NSCount -gt 0) {
            $ZoneName = $DnsResponse.Authority | Where-Object RecordType -eq ([RecordType]::SOA) | Select-Object -ExpandProperty Name
        }

        # Get the name servers for the zone
        Write-Verbose "Get-Dns: NSSearch: Finding name servers for zone ($ZoneName)."
        $DnsResponse = Get-Dns $ZoneName -RecordType NS -Server $Server -NoSearchList
        if ($DnsDebug) {
            $DnsResponse
        }
        $AuthoritativeServerList = $DnsResponse.Answer | Where-Object RecordType -eq ([RecordType]::NS) | ForEach-Object {
            $NameServer = $_
            $NameServerIP = $DnsResponse.Additional |
                Where-Object {
                    $_.Name -eq $NameServer.Hostname -and 
                    ($_.RecordType -eq [RecordType]::A -or $_.RecordType -eq [RecordType]::AAAA)
                } |
                Select-Object -ExpandProperty IPAddress 
            if ($NameServerIP) {
                $NameServerIP.ToString()
            } else {
                $_.Hostname
            }
        }

        # Query each authoritative server
        Write-Verbose "Get-Dns: NSSearch: Testing responses from each authoritative servers"
        $AuthoritativeServerList | ForEach-Object {
            Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -Server $_ -NoSearchList @GlobalOptions
        }
    }

    #
    # Zone Transfer
    #

    if ($RecordType -eq [RecordType]::IXFR -and -not $SerialNumber) {
        # SerialNumber is required, throw an error and abandon this.
        $errorRecord = New-Object Management.Automation.ErrorRecord(
            (New-Object ArgumentException "A value for SerialNumber must be supplied to execute an IXFR."),
            "SerialNumberIsMandatoryForIXFR",
            [ErrorCategory]::InvalidArgument,
            $RecordType
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
    }
    if ($ZoneTransfer -and $psboundparameters.ContainsKey('SerialNumber')) {
        #
        # IXFR
        #

        $RecordType = [RecordType]::IXFR
        $DnsResponse = Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -NoSearchList

        if ($DnsResponse.Header.RCode -eq [RCode]::NoError) {
            if ($DnsResponse.Answer[0].Serial -le $SerialNumber) {
                # Complete, the zone is already up to date.
                Write-Verbose "Get-Dns: IXFR: Transfer complete, zone is up to date."
                $DnsResponse
            } else {
                if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [RecordType]::SOA) {
                    # The message was a UDP overflow response, restart using TCP
                    Write-Verbose "Get-Dns: IXFR: UDP overflow response. Attempting TCP."
                    Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -Tcp -NoSearchList
                }
            }
        } else {
            # Allow an error message return.
            $DnsResponse
        }
    } elseif ($ZoneTransfer) {
        #
        # AXFR
        #

        $RecordType = [RecordType]::AXFR
        $Tcp = $true

        # Clear the zone transfer parameter, allow normal message processing from here.
        $ZoneTransfer = $false
    }

    #
    # Execute a query
    #

    if (-not $Iterative -and -not $NSSearch -and -not $ZoneTransfer) {
        $SearchStatus = [RCode]::NXDomain
        $i = 0

        # SearchList loop
        do {

            $Suffix = $SearchList[$i]
            if ($Suffix) {
                $FullName = "$Name$Suffix"
            } else {
                $FullName = $Name
            }

            Write-Verbose "Get-Dns: Query: $FullName $RecordClass $RecordType :: Server: $Server Protocol: $(if ($Tcp) { 'TCP' } else { 'UDP' }) AddressFamily: $(if ($IPv6) { 'IPv6' } else { 'IPv4' })"

            # Construct a message
            if ($RecordType -eq [RecordType]::IXFR -and $SerialNumber) {
                $DnsQuery = NewDnsMessage -Name $FullName -RecordType $RecordType -RecordClass $RecordClass -SerialNumber $SerialNumber
            } else {
                $DnsQuery = NewDnsMessage -Name $FullName -RecordType $RecordType -RecordClass $RecordClass
            }
            if (-not $NoEDns -and -not ($RecordType -in ([RecordType]::AXFR), ([RecordType]::IXFR))) {
                $DnsQuery.SetEDnsBufferSize($EDnsBufferSize) 
            }
            if ($DnsSec -and -not ($RecordType -in ([RecordType]::AXFR), ([RecordType]::IXFR))) {
                $DnsQuery.SetAcceptDnsSec()
            }

            if ($NoRecursion) {
                # Recursion is set by default, toggle the flag.
                $DnsQuery.Header.Flags = [HeaderFlags]([UInt16]$DnsQuery.Header.Flags -bxor [UInt16][HeaderFlags]::RD)
            }

            $Start = Get-Date

            # Construct a socket and send the request.
            if ($Tcp -and $IPv6) {

                # Create an IPv6 TCP socket, connect and send the message using IPv6
                $Socket = New-Socket -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6
                try {
                    Connect-Socket $Socket -RemoteIPAddress $Server -RemotePort $Port
                } catch [SocketException] {
                    $errorRecord = New-Object Management.Automation.ErrorRecord(
                        (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
                        'TCPConnectionFailed',
                        [ErrorCategory]::ConnectionError,
                        $Socket
                    )
                    $pscmdlet.ThrowTerminatingError($errorRecord)
                }
                Send-Bytes $Socket -Data ($DnsQuery.ToByte([ProtocolType]::Tcp))

            } elseif ($Tcp) {

                # Create a TCP socket, connect and send the message.
                $Socket = New-Socket -SendTimeout $Timeout -ReceiveTimeout $Timeout
                try {
                    Connect-Socket $Socket -RemoteIPAddress $Server -RemotePort $Port
                } catch [Net.Sockets.SocketException] {
                    $ErrorRecord = New-Object ErrorRecord(
                        (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
                        "TCP connection to Server ($Server/$Port) failed",
                        [ErrorCategory]::ConnectionError,
                        $Socket
                    )
                    $pscmdlet.ThrowTerminatingError($ErrorRecord)
                }
                Send-Bytes $Socket -Data ($DnsQuery.ToByte([ProtocolType]::Tcp))

            } elseif ($IPv6) {

                # Create a UDP socket and send the message using IPv6.
                $Socket = New-Socket -ProtocolType Udp -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6
                Send-Bytes $Socket -RemoteIPAddress $Server -RemotePort $Port -Data ($DnsQuery.ToByte())

            } else {

                # Create a UDP socket and send the message.
                $Socket = New-Socket -ProtocolType Udp -SendTimeout $Timeout -ReceiveTimeout $Timeout
                Send-Bytes $Socket -RemoteIPAddress $Server -RemotePort $Port -Data ($DnsQuery.ToByte())

            }

            $MessageComplete = $false
            # A buffer used to reassemble responses using TCP
            $MessageBuffer = [Byte[]]@()
            # An SOA record counter used as exit criteria for AXFR responses and a place-holder for a serial number of IXFR
            $SOAResouceRecordCount = 0; $ActiveSerialNumber = $null

            # Support for multi-packet responses.
            do {
                try {
                    $DnsResponseData = Receive-Bytes $Socket -BufferSize 4096
                } catch [SocketException] {
                    $errorRecord = New-Object ErrorRecord(
                        (New-Object SocketException ($_.Exception.InnerException.NativeErrorCode)),
                        'Timeout',
                        [ErrorCategory]::ConnectionError,
                        $Socket
                    )
                    $pscmdlet.ThrowTerminatingError($errorRecord)
                }

                if ($Tcp) {
                    $MessageBuffer += $DnsResponseData.Data

                    if ($MessageBuffer.Count -ge 2) {
                        $MessageLength = [BitConverter]::ToUInt16(($MessageBuffer[1..0]), 0)

                        # If the message buffer holds more data than the recorded message length a response can be read off.
                        while ($MessageBuffer.Count -ge ($MessageLength + 2)) {
                            # Copy bytes from message buffer into the partial copy
                            $MessageBytes = New-Object Byte[] $MessageLength
                            [Array]::Copy($MessageBuffer, 2, $MessageBytes, 0, $MessageLength)
                            $DnsResponseData.Data = $MessageBytes

                            # Remove the bytes which have been read from the buffer and update the number of available bytes.
                            $TempMessageBuffer = New-Object Byte[] ($MessageBuffer.Count - 2 - $MessageLength)
                            [Array]::Copy($MessageBuffer, (2 + $MessageLength), $TempMessageBuffer, 0, $TempMessageBuffer.Count)
                            $MessageBuffer = $TempMessageBuffer
                            $TempMessageBuffer = $null

                            # Process the response message
                            $DnsResponse = ReadDnsMessage $DnsResponseData

                            # Anything other than NoError in a Header denotes message completion.
                            if ($DnsResponse.Header.RCode -ne [RCode]::NoError) {
                                $MessageComplete = $true
                            }

                            # IXFR completion tests
                            if ($RecordType -eq [RecordType]::IXFR -and -not $MessageComplete) {
                                if ($ActiveSerialNumber -eq $null) {
                                    # A truncated return.
                                    if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [RecordType]::SOA) {
                                        $MessageComplete = $true
                                        Write-Verbose "Get-Dns: IXFR: Terminated, no more answers available."
                                    }
                                    if ($DnsResponse.Header.ANCount -ge 2) {
                                        if ($DnsResponse.Answer[1].RecordType -ne [RecordType]::SOA) {
                                            # If a second record is present, and it is not an SOA record ,an AXFR response is being returned.
                                            # Change the RecordType value, subjecting the response to the tests for AXFR responses.
                                            $RecordType = [RecordType]::AXFR
                                            Write-Verbose "Get-Dns: IXFR: AXFR mode response detected."
                                        } else {
                                            $ActiveSerialNumber = $DnsResponse.Answer[0].Serial
                                            Write-Verbose "Get-Dns: IXFR: Latest serial number available is $ActiveSerialNumber"
                                        }
                                    }
                                }

                                if ($ActiveSerialNumber) {
                                    $SOAResouceRecordCount += $DnsResponse.Answer |
                                        Where-Object { $_.RecordType -eq [RecordType]::SOA -and $_.Serial -eq $ActiveSerialNumber } |
                                        Measure-Object |
                                        Select-Object -ExpandProperty Count

                                    if ($SOAResouceRecordCount -ge 3) {
                                        $MessageComplete = $true
                                        Write-Verbose "Get-Dns: IXFR: Transfer is complete."
                                    }
                                }
                            }

                            # AXFR completion tests
                            if ($RecordType -eq [RecordType]::AXFR -and -not $MessageComplete) {
                                $SOAResouceRecordCount += $DnsResponse.Answer |
                                    Where-Object RecordType -eq ([RecordType]::SOA) |
                                    Measure-Object |
                                    Select-Object -ExpandProperty Count

                                # An complete AXFR starts and ends with an SOA record.
                                if ($SOAResouceRecordCount -ge 2) {
                                    $MessageComplete = $true
                                    Write-Verbose "Get-Dns: AXFR: Transfer is complete."
                                }
                            } else {
                                # If this is not a zone transfer the process can be marked as complete.
                                $MessageComplete = $true
                                Write-Verbose "Get-Dns: Query: Complete."
                            }
                        }
                    }
                } else {
                    $DnsResponse = ReadDnsMessage $DnsResponseData
                    # If this is not TCP the response must be contained in a single packet.          
                    $MessageComplete = $true
                }

                # If a complete response is present (no TCP loop).
                if ($DnsResponse) {
                    $DnsResponse.TimeTaken = New-TimeSpan $Start (Get-Date)

                    # Update the SearchList loop exit criteria
                    $SearchStatus = $DnsResponse.Header.RCode

                    # Return the response
                    if ($SearchStatus -ne [RCode]::NXDomain -or $DnsDebug) {
                        if ($DnsCacheReverse.Contains($DnsResponse.Server)) {
                            $DnsResponse.Server = "$($DnsResponse.Server) ($($DnsCacheReverse[$DnsResponse.Server]))"
                        }

                        if ($DnsResponse.Header.Flags -band [HeaderFlags]::TC) {
                            if ($NoTcpFallback) {
                                $DnsResponse
                            } else {
                                # Make $DnsResponse null
                                $DnsResponse = $null
                                # Resend using TCP
                                Get-Dns @psboundparameters -Tcp
                            }
                        } else {
                            $DnsResponse
                        }
                    }
                }

                if ($SearchStatus -eq [RCode]::NXDomain -and $i -eq ($SearchList.Count - 1)) {
                    if ($RecordType -in [RecordType]::AXFR, [RecordType]::IXFR) {
                        Write-Warning "Get-Dns: Transfer refused. Server ($Server) is not authoritative for $Name."
                    } else {
                        Write-Warning "Get-Dns: Name ($Name) does not exist."
                    }
                }
            } until ($MessageComplete)

            if ($Tcp) {
                # Disconnect a TCP socket.
                Disconnect-Socket $Socket
            }
            # Close down the socket and free resources.
            Remove-Socket $Socket

            # Track the position in the suffixes search list
            $i++

        } while ($SearchStatus -eq [RCode]::NXDomain -and $i -lt $SearchList.Count)
    }
}