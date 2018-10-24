---
external help file: Indented.Net.Dns-help.xml
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-Dns

## SYNOPSIS
Get a DNS resource record from a DNS server.

## SYNTAX

### RecursiveQuery (Default)
```
Get-Dns [[-Name] <String>] [[-RecordType] <RecordType>] [-RecordClass <RecordClass>] [-NoRecursion] [-DnsSec]
 [-NoEDns] [-EDnsBufferSize <UInt16>] [-NoTcpFallback] [-SearchList <String[]>] [-NoSearchList]
 [-SerialNumber <UInt32>] [-Server <String>] [-Tcp] [-Port <UInt16>] [-Timeout <Byte>] [-IPv6] [-DnsDebug]
```

### ZoneTransfer
```
Get-Dns [[-Name] <String>] [-ZoneTransfer] [-SerialNumber <UInt32>] [-Server <String>] [-Timeout <Byte>]
 [-IPv6] [-DnsDebug]
```

### NSSearch
```
Get-Dns [[-Name] <String>] [[-RecordType] <RecordType>] [-NSSearch] [-DnsSec] [-NoEDns]
 [-EDnsBufferSize <UInt16>] [-NoTcpFallback] [-Timeout <Byte>] [-DnsDebug]
```

### IterativeQuery
```
Get-Dns [[-Name] <String>] [[-RecordType] <RecordType>] [-Iterative] [-RecordClass <RecordClass>] [-DnsSec]
 [-NoEDns] [-EDnsBufferSize <UInt16>] [-NoTcpFallback] [-Timeout <Byte>] [-DnsDebug]
```

### Version
```
Get-Dns [-Version] [-Server <String>] [-Tcp] [-Port <UInt16>] [-Timeout <Byte>] [-IPv6] [-DnsDebug]
```

## DESCRIPTION
Get-Dns is a debugging resolver tool similar to dig and nslookup.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-Dns hostname
```

Attempt to resolve hostname using the system-configured search list.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-Dns www.domain.example
```

The system-configured search list will be appended to this query before it is executed.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-Dns www.domain.example.
```

The name is fully-qualified (or root terminated), no additional suffixes will be appended.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-Dns www.domain.example -NoSearchList
```

No additional suffixes will be appended.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-Dns www.domain.example -Iterative
```

Attempt to perform an iterative lookup of www.domain.example, starting from the root hints.

### -------------------------- EXAMPLE 6 --------------------------
```
Get-Dns www.domain.example CNAME -NSSearch
```

Attempt to return the CNAME record for www.domain.example from all authoritative servers for the parent zone.

### -------------------------- EXAMPLE 7 --------------------------
```
Get-Dns -Version -Server 10.0.0.1
```

Request a version string from the server 10.0.0.1.

### -------------------------- EXAMPLE 8 --------------------------
```
Get-Dns domain.example -ZoneTransfer -Server 10.0.0.1
```

Request a zone transfer, using AXFR, for domain.example from the server 10.0.0.1.

### -------------------------- EXAMPLE 9 --------------------------
```
Get-Dns domain.example -ZoneTransfer -SerialNumber 2 -Server 10.0.0.1
```

Request a zone transfer, using IXFR and the serial number 2, for domain.example from the server 10.0.0.1.

### -------------------------- EXAMPLE 10 --------------------------
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
Parameter Sets: RecursiveQuery, ZoneTransfer, NSSearch, IterativeQuery
Aliases: 

Required: False
Position: 2
Default value: .
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RecordType
Any resource record type, by default a query for ANY will be sent.

```yaml
Type: RecordType
Parameter Sets: RecursiveQuery, NSSearch, IterativeQuery
Aliases: Type
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, HIP, NINFO, RKEY, SPF, UINFO, UID, GID, UNSPEC, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, TA, DLV, WINS, WINSR

Required: False
Position: 3
Default value: ANY
Accept pipeline input: False
Accept wildcard characters: False
```

### -Iterative
Perform a full iterative search for a name starting with the root servers.
Intermediate queries are resolved using the locally configured name server to reduce the work-load as Get-Dns does not implement response caching.

```yaml
Type: SwitchParameter
Parameter Sets: IterativeQuery
Aliases: Trace

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NSSearch
Locate the authoritative servers for a zone (using Server as a starting point), then execute a the query against each authoritative server.
Aids the testing of replication failure between authoritative servers.

```yaml
Type: SwitchParameter
Parameter Sets: NSSearch
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Generates and sends a query for version.bind.
using TXT as the RecordType and CH (Chaos) as the RecordClass.

```yaml
Type: SwitchParameter
Parameter Sets: Version
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ZoneTransfer
Constructs and executes a zone transfer request.
If SerialNumber is also set an IXFR request will be generated using the algorithm discussed in draft-ietf-dnsind-ixfr-01.
If SerialNumber is not set an AXFR request will be sent.

The use of TCP or UDP for zone transfer requests is fixed, AXFR will always use TCP.
IXFR will attempt UDP and switch to TCP if a stub response is returned.

```yaml
Type: SwitchParameter
Parameter Sets: ZoneTransfer
Aliases: Transfer

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordClass
By default the class is IN.
CH (Chaos) may be used to query for name server information.
HS (Hesoid) may be used if the name server supports it.

```yaml
Type: RecordClass
Parameter Sets: RecursiveQuery, IterativeQuery
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
Parameter Sets: RecursiveQuery
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
Parameter Sets: RecursiveQuery, NSSearch, IterativeQuery
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoEDns
Disable EDNS support, suppresses OPT RR advertising client support in DNS question.

```yaml
Type: SwitchParameter
Parameter Sets: RecursiveQuery, NSSearch, IterativeQuery
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EDnsBufferSize
By default the EDns buffer size is set to 4096 bytes.
If NoEDns is used this value is ignored.

```yaml
Type: UInt16
Parameter Sets: RecursiveQuery, NSSearch, IterativeQuery
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
Parameter Sets: RecursiveQuery, NSSearch, IterativeQuery
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchList
If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries.
If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.

SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.

```yaml
Type: String[]
Parameter Sets: RecursiveQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoSearchList
The use of a SearchList can be explicitly suppressed using the NoSearchList parameter.

SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.

```yaml
Type: SwitchParameter
Parameter Sets: RecursiveQuery
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SerialNumber
The SerialNumber is used only if the RecordType is set to IXFR (either directly, or by using the ZoneTransfer parameter).

```yaml
Type: UInt32
Parameter Sets: RecursiveQuery, ZoneTransfer
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
A server name or IP address to execute a query against.
If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter).

If a name is used another lookup will be required to resolve the name to an IP.
Get-Dns caches responses for queries performed involving the Server parameter.
The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.

If no server name is defined, the Get-DnsServerList command is used to discover locally configured DNS servers.

```yaml
Type: String
Parameter Sets: RecursiveQuery, ZoneTransfer, Version
Aliases: ComputerName

Required: False
Position: Named
Default value: (Get-DnsServerList -IPv6:$IPv6 | Select-Object -First 1)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tcp
Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.

```yaml
Type: SwitchParameter
Parameter Sets: RecursiveQuery, Version
Aliases: 

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
Parameter Sets: RecursiveQuery, Version
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
Parameter Sets: RecursiveQuery, ZoneTransfer, Version
Aliases: 

Required: False
Position: Named
Default value: False
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

## INPUTS

## OUTPUTS

### Indented.DnsResolver.Message

## NOTES

## RELATED LINKS

[http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01](http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01)

