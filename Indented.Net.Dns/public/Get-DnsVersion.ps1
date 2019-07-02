function Get-DnsVersion {
    <#
    .SYNOPSIS
        Get the DNS server version.
    .DESCRIPTION
        Attempt to get the DNS server version by sending a request for version.bind. using the CH class.

        DNS servers often refuse queries for the version number.
    .EXAMPLE
        Get-DnsVersion

        Get the version of the default DNS server.
    .EXAMPLE
        Get-DnsVersion -ComputerName 127.0.0.1

        Get the version of the DNS server running on 127.0.0.1.
    #>

    [CmdletBinding()]
    param (
        # Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
        [Alias('vc')]
        [Switch]$Tcp,

        # By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
        [UInt16]$Port = 53,


        # Force the use of IPv6 for queries, if this parameter is set and the Server is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
        [Switch]$IPv6,

        # A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).
        #
        # If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
        #
        # If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.
        [Alias('Server')]
        [String]$ComputerName
    )

    $params = @{
        Name        = 'version.bind.'
        RecordType  = 'TXT'
        RecordClass = 'CH'
    }
    Get-Dns @params @psboundparameters
}