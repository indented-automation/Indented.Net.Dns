---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-DnsVersion

## SYNOPSIS
Get the DNS server version.

## SYNTAX

```
Get-DnsVersion [-Tcp] [[-Port] <UInt16>] [-IPv6] [[-ComputerName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Attempt to get the DNS server version by sending a request for version.bind.
using the CH class.

DNS servers often refuse queries for the version number.

## EXAMPLES

### EXAMPLE 1
```
Get-DnsVersion
```

Get the version of the default DNS server.

### EXAMPLE 2
```
Get-DnsVersion -ComputerName 127.0.0.1
```

Get the version of the DNS server running on 127.0.0.1.

## PARAMETERS

### -Tcp
Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: vc

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
By default, DNS uses TCP or UDP port 53.
The port used to send queries may be changed if a server is listening on a different port.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 53
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPv6
Force the use of IPv6 for queries, if this parameter is set and the Server is set to a name (e.g.
ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
A server name or IP address to execute a query against.
If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).

If a name is used another lookup will be required to resolve the name to an IP.
Get-Dns caches responses for queries performed involving the Server parameter.
The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.

If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Server

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
