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
        [Parameter(Position = 1, ValueFromPipeline, ParameterSetName = 'RecursiveQuery')]
        [Parameter(Position = 1, ValueFromPipeline, ParameterSetName = 'IterativeQuery')]
        [Parameter(Position = 1, ValueFromPipeline, ParameterSetName = 'NSSearch')]
        [Parameter(Position = 1, ValueFromPipeline, ParameterSetName = 'ZoneTransfer')]
        [ValidateDnsName()]
        [String]$Name = ".",

        # Any resource record type, by default a query for ANY will be sent.
        [Parameter(Position = 2, ParameterSetname = 'RecursiveQuery')]
        [Parameter(Position = 2, ParameterSetname = 'IterativeQuery')]
        [Parameter(Position = 2, ParameterSetName = 'NSSearch')]
        [Alias('Type')]
        [RecordType]$RecordType = [RecordType]::ANY,

        # Perform a full iterative search for a name starting with the root servers. Intermediate queries are resolved using the locally configured name server to reduce the work-load as Get-Dns does not implement response caching.
        [Parameter(Mandatory, ParameterSetName = 'IterativeQuery')]
        [Alias('Trace')]
        [Switch]$Iterative,

        # Locate the authoritative servers for a zone (using Server as a starting point), then execute a the query against each authoritative server. Aids the testing of replication failure between authoritative servers.
        [Parameter(Mandatory, ParameterSetName = 'NSSearch')]
        [Switch]$NSSearch,

        # Generates and sends a query for version.bind. using TXT as the RecordType and CH (Chaos) as the RecordClass.
        [Parameter(Mandatory, ParameterSetName = 'Version')]
        [Switch]$Version,

        # Constructs and executes a zone transfer request. If SerialNumber is also set an IXFR request will be generated using the algorithm discussed in draft-ietf-dnsind-ixfr-01. If SerialNumber is not set an AXFR request will be sent.
        #
        # The use of TCP or UDP for zone transfer requests is fixed, AXFR will always use TCP. IXFR will attempt UDP and switch to TCP if a stub response is returned.
        [Parameter(Mandatory, ParameterSetName = 'ZoneTransfer')]
        [Alias('Transfer')]
        [Switch]$ZoneTransfer,

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

        # The SerialNumber is used only if the RecordType is set to IXFR (either directly, or by using the ZoneTransfer parameter).
        [Parameter(ParameterSetName = 'RecursiveQuery')]
        [Parameter(ParameterSetName = 'ZoneTransfer')]
        [UInt32]$SerialNumber,

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

        if ($IPv6) {
            $serverRecordType = [RecordType]::AAAA
        } else {
            $serverRecordType = [RecordType]::A
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
                $SearchList = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Property DNSDomainSuffixSearchOrder |
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
            $Name = '{0}.' -f $Name
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
            foreach ($authoritativeServer in $AuthoritativeServerList) {
                Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -Server $authoritativeServer -NoSearchList @GlobalOptions
            }
        }

        #
        # Zone Transfer
        #

        if ($RecordType -eq [RecordType]::IXFR -and -not $SerialNumber) {
            # SerialNumber is required, throw an error and abandon this.
            $errorRecord = [ErrorRecord]::new(
                [ArgumentException]::new('A value for SerialNumber must be supplied to execute an IXFR.'),
                'SerialNumberIsMandatoryForIXFR',
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

                Write-Debug ("Get-Dns: Query: {0} {1} {2} :: Server: {3} Protocol: {4} AddressFamily: {5}" -f @(
                    $FullName
                    $RecordClass
                    $RecordType
                    $Server
                    ('UDP', 'TCP')[$Tcp.ToBool()]
                    ('IPv4', 'IPv6')[$IPv6.ToBool()]
                ))

                if ($RecordType -eq [RecordType]::IXFR -and $SerialNumber) {
                    $DnsQuery = [DnsMessage]::new(
                        $FullName,
                        $RecordType,
                        $RecordClass,
                        $SerialNumber
                    )
                } else {
                    $DnsQuery = [DnsMessage]::new(
                        $FullName,
                        $RecordType,
                        $RecordClass
                    )
                }
                if ($EDns -and $RecordType -notin ([RecordType]::AXFR), ([RecordType]::IXFR)) {
                    $DnsQuery.SetEDnsBufferSize($EDnsBufferSize)
                }
                if ($DnsSec -and $RecordType -notin ([RecordType]::AXFR), ([RecordType]::IXFR)) {
                    $DnsQuery.SetAcceptDnsSec()
                }

                if ($NoRecursion) {
                    $DnsQuery.Header.Flags = [HeaderFlags]([UInt16]$DnsQuery.Header.Flags -bxor [UInt16][HeaderFlags]::RD)
                }

                $Start = Get-Date

                if ($Tcp) {
                    $Socket = New-Socket -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6:$IPv6
                    try {
                        Connect-Socket $Socket -RemoteIPAddress $Server -RemotePort $Port
                    } catch [SocketException] {
                        $errorRecord = [ErrorRecord]::new(
                            [SocketException]::new($_.Exception.InnerException.NativeErrorCode),
                            'TCPConnectionFailed',
                            [ErrorCategory]::ConnectionError,
                            $Socket
                        )
                        $pscmdlet.ThrowTerminatingError($errorRecord)
                    }
                    Send-Byte $Socket -Data $DnsQuery.ToByteArray($true, $true)
                } else {
                    $Socket = New-Socket -ProtocolType Udp -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6:$IPv6
                    Send-Byte $Socket -RemoteIPAddress $Server -RemotePort $Port -Data $DnsQuery.ToByteArray()
                }

                $MessageComplete = $false
                # A buffer used to reassemble responses using TCP
                $MessageBuffer = [Byte[]]@()
                # An SOA record counter used as exit criteria for AXFR responses and a place-holder for a serial number of IXFR
                $SOAResouceRecordCount = 0
                $ActiveSerialNumber = $null

                # Support for multi-packet responses.
                do {
                    try {
                        $DnsResponseData = Receive-Byte $Socket -BufferSize 4096
                    } catch [SocketException] {
                        $errorRecord = [ErrorRecord]::new(
                            [SocketException]::new($_.Exception.InnerException.NativeErrorCode),
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
                                $MessageBytes = [Byte[]]::new($MessageLength)
                                [Array]::Copy($MessageBuffer, 2, $MessageBytes, 0, $MessageLength)
                                $DnsResponseData.Data = $MessageBytes

                                # Remove the bytes which have been read from the buffer and update the number of available bytes.
                                $TempMessageBuffer = [Byte[]]::new($MessageBuffer.Count - 2 - $MessageLength)
                                [Array]::Copy($MessageBuffer, (2 + $MessageLength), $TempMessageBuffer, 0, $TempMessageBuffer.Count)
                                $MessageBuffer = $TempMessageBuffer
                                $TempMessageBuffer = $null

                                # Process the response message
                                $DnsResponse = [DnsMessage]::new($DnsResponseData.Data)

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
                        $DnsResponse = [DnsMessage]::new($DnsResponseData.Data)
                        # If this is not TCP the response must be contained in a single packet.
                        $MessageComplete = $true
                    }

                    # If a complete response is present (no TCP loop).
                    if ($DnsResponse) {
                        $DnsResponse.TimeTaken = (New-TimeSpan $Start (Get-Date)).TotalMilliseconds
                        $DnsResponse.Server = $DnsResponseData.RemoteEndpoint

                        # Update the SearchList loop exit criteria
                        $SearchStatus = $DnsResponse.Header.RCode

                        if ($Server -ne $serverIPAddress) {
                            $DnsResponse.Server = '{0} ({1})' -f $Server, $DnsResponse.Server
                        }

                        # Return the response
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
                        }
                    }

                    if ($SearchStatus -eq [RCode]::NXDomain -and $i -eq ($SearchList.Count - 1)) {
                        if ($RecordType -in [RecordType]::AXFR, [RecordType]::IXFR) {
                            Write-Warning ('Get-Dns: Transfer refused. Server ({0}) is not authoritative for {1}.' -f $Server, $Name)
                        } else {
                            Write-Warning ('Get-Dns: Name ({0}) does not exist.' -f $Name)
                        }
                    }
                } until ($MessageComplete)

                if ($Tcp) {
                    Disconnect-Socket $Socket
                }
                Remove-Socket $Socket

                # Track the position in the suffixes search list
                $i++
            } while ($SearchStatus -eq [RCode]::NXDomain -and $i -lt $SearchList.Count)
        }
    }
}