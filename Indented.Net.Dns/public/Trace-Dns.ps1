function Trace-Dns {
    <#
    .SYNOPSIS
        Iteratively trace resolution of a name from a root or specified name server.
    .DESCRIPTION
        Trace-Dns attempts to resolve a name from a root or specified name server by following authority records.
    .EXAMPLE
        Trace-Dns www.google.com.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding()]
    param (
        # The name of the record to search for. The name can either be fully-qualified or relative to the zone name.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateDnsName()]
        [String]$Name,

        # The record type to search for.
        [Parameter(Position = 3, ValueFromPipelineByPropertyName)]
        [RecordType]$RecordType = 'ANY',

        # Advertise support for DNSSEC when executing a query.
        [Switch]$DnsSec,

        # Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
        [Alias('vc')]
        [Switch]$Tcp,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [UInt16]$Port = 53,

        # By default, queries will timeout after 5 seconds. The value may be set between 1 and 30 seconds.
        [ValidateRange(1, 30)]
        [Byte]$Timeout = 5,

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

    begin {
        if (-not $ComputerName) {
            $nameServerRecordType = 'A'
            if ($IPv6) {
                $nameServerRecordType = 'AAAA'
            }

            $rootHints = Get-InternalDnsCacheRecord -RecordType $nameServerRecordType -ResourceType Hint
            $ComputerName = $rootHints.Name | Sort-Object { Get-Random } | Select-Object -First 1
        }
    }

    process {
        do {
            $dnsResponse = Get-Dns @psboundparameters -NoRecursion -ComputerName $ComputerName

            if ($dnsResponse.Header.AuthorityCount -gt 0) {
                $ComputerName = $dnsResponse.Authority[0].Hostname
            }

            $dnsResponse
        } until ($dnsResponse.Header.AnswerCount -gt 0 -or $dnsResponse.Header.RCode -ne 'NOERROR')
    }
}