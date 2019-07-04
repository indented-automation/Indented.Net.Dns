function Search-Dns {
    <#
    .SYNOPSIS
        Search all name servers for a specific record.
    .DESCRIPTION
        Search-Dns may be used to retrieve a resource record from all name servers for a given domain.
    #>

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

    process {
        $psboundparameters.Remove('Name')
        $psboundparameters.Remove('ZoneName')
        $psboundparameters.Remove('RecordType')

        $params = @{
            Name       = $ZoneName
            RecordType = 'NS'
        }
        $dnsResponse = Get-Dns @params @psboundparameters

        foreach ($nameServer in $dnsResponse.Answer) {
            $nameServer = $answer.HostName

            $params = @{
                Name         = $Name
                RecordType   = $RecordType
                ComputerName = $nameServer
            }
            Get-Dns @params @psboundparameters
        }
    }
}