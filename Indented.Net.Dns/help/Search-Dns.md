---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version:
schema: 2.0.0
---

# Search-Dns

## SYNOPSIS
Search all name servers for a specific record.

## SYNTAX

```
Search-Dns [-Name] <String> [-ZoneName] <String> [[-RecordType] <RecordType>] [-Tcp] [-Port <UInt16>] [-IPv6]
 [-ComputerName <String>] [<CommonParameters>]
```

## DESCRIPTION
Search-Dns may be used to retrieve a resource record from all name servers for a given domain.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
The name of the record to search for.
The name can either be fully-qualified or relative to the zone name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ZoneName
The zone name is used to ensure the correct zone is searched for records.
This avoids the need for tricks to discover the authority for record types such as CNAME.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RecordType
The record type to search for.

```yaml
Type: RecordType
Parameter Sets: (All)
Aliases:
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, TLSA, SMIMEA, HIP, NINFO, RKEY, TALINK, CDS, CDNSKEY, OPENPGPKEY, CSYNC, ZONEMD, SPF, UINFO, UID, GID, UNSPEC, NID, L32, L64, LP, EUI48, EUI64, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, URI, CAA, AVC, DOA, AMTRELAY, TA, DLV, WINS, WINSR, UNKNOWN

Required: False
Position: 4
Default value: ANY
Accept pipeline input: True (ByPropertyName)
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

### -IPv6
Force the use of IPv6 for queries, if this parameter is set and the ComputerName is set to a name (e.g.
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
