function Search-Dns {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding()]
    param ( )

        #
        # Name server searches
        #

    # if ($NSSearch) {
    #     # Get the zone name from the SOA record
    #     Write-Verbose "Get-Dns: NSSearch: Finding start of authority."
    #     $DnsResponse = Get-Dns $Name -RecordType SOA -Server $Server -NoSearchList
    #     if ($DnsDebug) {
    #         $DnsResponse
    #     }
    #     if ($DnsResponse.Header.RCode -eq [RCode]::NoError -and $DnsResponse.Header.ANCount -gt 0) {
    #         $ZoneName = $DnsResponse.Answer | Where-Object RecordType -eq ([RecordType]::SOA) | Select-Object -ExpandProperty Name
    #     } elseif ($DnsResponse.Header.RCode -eq [RCode]::NoError -and $DnsResponse.Header.NSCount -gt 0) {
    #         $ZoneName = $DnsResponse.Authority | Where-Object RecordType -eq ([RecordType]::SOA) | Select-Object -ExpandProperty Name
    #     }

    #     # Get the name servers for the zone
    #     Write-Verbose "Get-Dns: NSSearch: Finding name servers for zone ($ZoneName)."
    #     $DnsResponse = Get-Dns $ZoneName -RecordType NS -Server $Server -NoSearchList
    #     if ($DnsDebug) {
    #         $DnsResponse
    #     }
    #     $AuthoritativeServerList = $DnsResponse.Answer | Where-Object RecordType -eq ([RecordType]::NS) | ForEach-Object {
    #         $NameServer = $_
    #         $NameServerIP = $DnsResponse.Additional |
    #             Where-Object {
    #                 $_.Name -eq $NameServer.Hostname -and
    #                 ($_.RecordType -eq [RecordType]::A -or $_.RecordType -eq [RecordType]::AAAA)
    #             } |
    #             Select-Object -ExpandProperty IPAddress
    #         if ($NameServerIP) {
    #             $NameServerIP.ToString()
    #         } else {
    #             $_.Hostname
    #         }
    #     }

    #     # Query each authoritative server
    #     Write-Verbose "Get-Dns: NSSearch: Testing responses from each authoritative servers"
    #     foreach ($authoritativeServer in $AuthoritativeServerList) {
    #         Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -Server $authoritativeServer -NoSearchList @GlobalOptions
    #     }
    # }
}