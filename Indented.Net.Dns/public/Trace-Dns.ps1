function Trace-Dns {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding()]
    param (
        # The name of the record to search for. The name can either be fully-qualified or relative to the zone name.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Name,

        # The zone name is used to ensure the correct zone is searched for records. This avoids the need for tricks to discover the authority for record types such as CNAME.
        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [String]$ZoneName,

        # The record type to search for.
        [Parameter(Position = 3, ValueFromPipelineByPropertyName)]
        [RecordType]$RecordType = 'ANY',

        # Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
        [Alias('vc')]
        [Switch]$Tcp,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [UInt16]$Port = 53,

        # Force the use of IPv6 for queries, if this parameter is set and the ComputerName is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
        [Switch]$IPv6,

        # A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).
        #
        # If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
        #
        # If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.
        [Alias('Server')]
        [String]$ComputerName
    )

    if (-not $ComputerName) {
        $rootHints = Get-InternalDnsCacheRecord -RecordType A -ResourceType Hint
        $ComputerName = $rootHints[(Get-Random -Minimum 0 -Maximum $rootHints.Count)] | Select-Object -ExpandProperty IPAddress
    }



        # Iterative searches
        #

        # if ($Iterative) {
        #     # Pick a random(ish) server from Root Hints


        #     $NoError = $true; $NoAnswer = $true
        #     while ($NoError -and $NoAnswer) {
        #         $DnsResponse = Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -NoRecursion -Server $Server @GlobalOptions

        #         if ($DnsResponse.Header.RCode -ne [RCode]::NoError)  {
        #             $NoError = $false
        #         } else {
        #             if ($DnsResponse.Header.ANCount -gt 0) {
        #                 $NoAnswer = $false
        #             } elseif ($DnsResponse.Header.NSCount -gt 0) {
        #                 $Authority = $DnsResponse.Authority | Select-Object -First 1

        #                 # Attempt to match between Authority and Additional. No need to execute another lookup if we have the information.
        #                 $Server = $DnsResponse.Additional |
        #                     Where-Object { $_.Name -eq $Authority.Hostname -and $_.RecordType -eq [RecordType]::A } |
        #                     Select-Object -ExpandProperty IPAddress |
        #                     Select-Object -First 1
        #                 if ($Server) {
        #                     Write-Verbose "Get-Dns: Iterative query: Next name server IP: $Server"
        #                 } else {
        #                     $Server = $Authority[0].Hostname
        #                     Write-Verbose "Get-Dns: Iterative query: Next name server Name: $Server"
        #                 }
        #             }
        #         }

        #         # Return the response to the output pipeline
        #         $DnsResponse
        #     }
        # }
}