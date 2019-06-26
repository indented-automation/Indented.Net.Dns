function Get-DnsZoneTransfer {
        # Constructs and executes a zone transfer request. If SerialNumber is also set an IXFR request will be generated using the algorithm discussed in draft-ietf-dnsind-ixfr-01. If SerialNumber is not set an AXFR request will be sent.
        #
        # The use of TCP or UDP for zone transfer requests is fixed, AXFR will always use TCP. IXFR will attempt UDP and switch to TCP if a stub response is returned.


    [CmdletBinding(DefaultParameterSetName = 'AXFR')]
    param (
        [ValidateDnsName()]
        [String]$Name = ".",

        # The SerialNumber is used only if the RecordType is set to IXFR (either directly, or by using the ZoneTransfer parameter).
        [Parameter(ParameterSetName = 'IXFR')]
        [UInt32]$SerialNumber
    )

    process {
    #     if ($pscmdlet.ParameterSetName -eq 'IXFR') {
    #         #
    #         # IXFR
    #         #

    #         $RecordType = [RecordType]::IXFR
    #         $DnsResponse = Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -NoSearchList

    #         if ($DnsResponse.Header.RCode -eq [RCode]::NoError) {
    #             if ($DnsResponse.Answer[0].Serial -le $SerialNumber) {
    #                 # Complete, the zone is already up to date.
    #                 Write-Verbose "Get-Dns: IXFR: Transfer complete, zone is up to date."
    #                 $DnsResponse
    #             } else {
    #                 if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [RecordType]::SOA) {
    #                     # The message was a UDP overflow response, restart using TCP
    #                     Write-Verbose "Get-Dns: IXFR: UDP overflow response. Attempting TCP."
    #                     Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -Tcp -NoSearchList
    #                 }
    #             }
    #         } else {
    #             # Allow an error message return.
    #             $DnsResponse
    #         }
    #     } else {
    #         $RecordType = [RecordType]::AXFR
    #         $Tcp = $true

    #         # Clear the zone transfer parameter, allow normal message processing from here.
    #         $ZoneTransfer = $false
    #     }
    # }

    #             # An SOA record counter used as exit criteria for AXFR responses and a place-holder for a serial number of IXFR
    #             $SOAResouceRecordCount = 0
    #             $ActiveSerialNumber = $null

    #             $DnsQuery = [DnsMessage]::new(
    #                 $FullName,
    #                 $RecordType,
    #                 $RecordClass,
    #                 $SerialNumber
    #             )

    #                             # IXFR completion tests
    #                             if ($RecordType -eq [RecordType]::IXFR -and -not $MessageComplete) {
    #                                 if ($ActiveSerialNumber -eq $null) {
    #                                     # A truncated return.
    #                                     if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [RecordType]::SOA) {
    #                                         $MessageComplete = $true
    #                                         Write-Verbose "Get-Dns: IXFR: Terminated, no more answers available."
    #                                     }
    #                                     if ($DnsResponse.Header.ANCount -ge 2) {
    #                                         if ($DnsResponse.Answer[1].RecordType -ne [RecordType]::SOA) {
    #                                             # If a second record is present, and it is not an SOA record ,an AXFR response is being returned.
    #                                             # Change the RecordType value, subjecting the response to the tests for AXFR responses.
    #                                             $RecordType = [RecordType]::AXFR
    #                                             Write-Verbose "Get-Dns: IXFR: AXFR mode response detected."
    #                                         } else {
    #                                             $ActiveSerialNumber = $DnsResponse.Answer[0].Serial
    #                                             Write-Verbose "Get-Dns: IXFR: Latest serial number available is $ActiveSerialNumber"
    #                                         }
    #                                     }
    #                                 }

    #                                 if ($ActiveSerialNumber) {
    #                                     $SOAResouceRecordCount += $DnsResponse.Answer |
    #                                         Where-Object { $_.RecordType -eq [RecordType]::SOA -and $_.Serial -eq $ActiveSerialNumber } |
    #                                         Measure-Object |
    #                                         Select-Object -ExpandProperty Count

    #                                     if ($SOAResouceRecordCount -ge 3) {
    #                                         $MessageComplete = $true
    #                                         Write-Verbose "Get-Dns: IXFR: Transfer is complete."
    #                                     }
    #                                 }
    #                             }

    #                             # AXFR completion tests
    #                             if ($RecordType -eq [RecordType]::AXFR -and -not $MessageComplete) {
    #                                 $SOAResouceRecordCount += $DnsResponse.Answer |
    #                                     Where-Object RecordType -eq ([RecordType]::SOA) |
    #                                     Measure-Object |
    #                                     Select-Object -ExpandProperty Count

    #                                 # An complete AXFR starts and ends with an SOA record.
    #                                 if ($SOAResouceRecordCount -ge 2) {
    #                                     $MessageComplete = $true
    #                                     Write-Verbose "Get-Dns: AXFR: Transfer is complete."
    #                                 }
    #                             } else {
    #                                 # If this is not a zone transfer the process can be marked as complete.
    #                                 $MessageComplete = $true
    #                                 Write-Verbose "Get-Dns: Query: Complete."
    #                             }
    }

}