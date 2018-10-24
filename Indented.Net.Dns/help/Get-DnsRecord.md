---
external help file: Indented.Net.Dns-help.xml
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-DnsRecord

## SYNOPSIS

## SYNTAX

### FromZone (Default)
```
Get-DnsRecord [[-Name] <String>] [[-RecordType] <RecordType[]>] [-ZoneName <String>]
 [[-ComputerName] <String[]>] -CimSession <CimSession[]>
```

### FromCache
```
Get-DnsRecord [[-Name] <String>] [[-RecordType] <RecordType[]>] [-Cache] [[-ComputerName] <String[]>]
 -CimSession <CimSession[]>
```

### FromRootHints
```
Get-DnsRecord [[-Name] <String>] [[-RecordType] <RecordType[]>] [-RootHints] [[-ComputerName] <String[]>]
 -CimSession <CimSession[]>
```

### UsingSQL
```
Get-DnsRecord [[-Name] <String>] [[-RecordType] <RecordType[]>] [-Filter <String>] [[-ComputerName] <String[]>]
 -CimSession <CimSession[]>
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: RecordName, OwnerName

Required: False
Position: 1
Default value: .*
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RecordType
{{Fill RecordType Description}}

```yaml
Type: RecordType[]
Parameter Sets: (All)
Aliases: Type
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, HIP, NINFO, RKEY, SPF, UINFO, UID, GID, UNSPEC, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, TA, DLV, WINS, WINSR

Required: False
Position: 2
Default value: ([RecordType[]][List[Int]][Enum]::GetValues([CimRecordClass]))
Accept pipeline input: False
Accept wildcard characters: False
```

### -ZoneName
{{Fill ZoneName Description}}

```yaml
Type: String
Parameter Sets: FromZone
Aliases: ContainerName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Cache
{{Fill Cache Description}}

```yaml
Type: SwitchParameter
Parameter Sets: FromCache
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootHints
{{Fill RootHints Description}}

```yaml
Type: SwitchParameter
Parameter Sets: FromRootHints
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
{{Fill Filter Description}}

```yaml
Type: String
Parameter Sets: UsingSQL
Aliases: 

Required: False
Position: Named
Default value: NOT ContainerName LIKE '..%'
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
Search for records on the specified server.
By default cache on the current server DNS cache is cleared.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -CimSession
Search for records using the specified CIM sessions.

```yaml
Type: CimSession[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

