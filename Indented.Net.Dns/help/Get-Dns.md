---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-Dns

## SYNOPSIS
Get a DNS resource record from a DNS server.

## SYNTAX

```
Get-Dns [[-Name] <String>] [[-RecordType] <RecordType>] [-RecordClass <RecordClass>] [-NoRecursion] [-DnsSec]
 [-EDns] [-EDnsBufferSize <UInt16>] [-NoTcpFallback] [-SearchList <String[]>] [-Tcp] [-Port <UInt16>]
 [-Timeout <Byte>] [-IPv6] [-ComputerName <String>] [-DnsDebug] [<CommonParameters>]
```

## DESCRIPTION
Get-Dns is a debugging resolver tool similar to dig and nslookup.

## EXAMPLES

### EXAMPLE 1
```
Get-Dns hostname
```

Attempt to resolve hostname using the system-configured search list.

### EXAMPLE 2
```
Get-Dns www.domain.example
```

The system-configured search list will be appended to this query before it is executed.

### EXAMPLE 3
```
Get-Dns www.domain.example.
```

The name is fully-qualified (or root terminated), no additional suffixes will be appended.

### EXAMPLE 4
```
Get-Dns example. -DnsSec
```

Request ANY record for the co.uk domain, advertising DNSSEC support.

## PARAMETERS

### -Name
A resource name to query, by default Get-Dns will use '.' as the name.
IP addresses (IPv4 and IPv6) are automatically converted into an appropriate format to aid PTR queries.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: .
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RecordType
Any resource record type, by default a query for ANY will be sent.

```yaml
Type: RecordType
Parameter Sets: (All)
Aliases: Type
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, TLSA, SMIMEA, HIP, NINFO, RKEY, TALINK, CDS, CDNSKEY, OPENPGPKEY, CSYNC, ZONEMD, SPF, UINFO, UID, GID, UNSPEC, NID, L32, L64, LP, EUI48, EUI64, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, URI, CAA, AVC, DOA, AMTRELAY, TA, DLV, WINS, WINSR, UNKNOWN

Required: False
Position: 3
Default value: ANY
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RecordClass
By default the class is IN.
CH (Chaos) may be used to query for name server information.
HS (Hesoid) may be used if the name server supports it.

```yaml
Type: RecordClass
Parameter Sets: (All)
Aliases:
Accepted values: IN, CH, HS, NONE, ANY

Required: False
Position: Named
Default value: IN
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRecursion
Remove the Recursion Desired (RD) flag from a query.
Recursion is requested by default.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: NoRecurse

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DnsSec
Advertise support for DNSSEC when executing a query.

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

### -EDns
Enable EDNS support, suppresses OPT RR advertising client support in DNS question.

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

### -EDnsBufferSize
By default the EDns buffer size is set to 4096 bytes.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 4096
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoTcpFallback
Disable the use of TCP if a truncated response (TC flag) is seen when using UDP.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Ignore

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchList
If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries.
If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.

An empty search list by be specified by providing an empty array for this parameter.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (GetDnsSuffixSearchList)
Accept pipeline input: False
Accept wildcard characters: False
```

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
Position: Named
Default value: 53
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
By default, queries will timeout after 5 seconds.
The value may be set between 1 and 30 seconds.

```yaml
Type: Byte
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5
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
Position: Named
Default value: (Get-DnsServerList -IPv6:$IPv6 | Select-Object -First 1)
Accept pipeline input: False
Accept wildcard characters: False
```

### -DnsDebug
Forces Get-Dns to output intermediate requests which would normally be hidden, such as NXDomain replies when using a SearchList.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### DnsMessage
## NOTES

## RELATED LINKS

[http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01](http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01)

