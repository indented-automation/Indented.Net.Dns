---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-InternalDnsCacheRecord

## SYNOPSIS
Get the content of the internal DNS cache used by Get-Dns.

## SYNTAX

```
Get-InternalDnsCacheRecord [[-Name] <String>] [[-RecordType] <RecordType>] [-IPAddress <IPAddress>]
 [-ResourceType <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-InternalDnsCacheRecord displays records held in the cache.

## EXAMPLES

### EXAMPLE 1
```
Get-InternalDnsCacheRecord
```

### EXAMPLE 2
```
Get-InternalDnsCacheRecord a.root-servers.net A
```

## PARAMETERS

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RecordType
{{Fill RecordType Description}}

```yaml
Type: RecordType
Parameter Sets: (All)
Aliases:
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, HIP, NINFO, RKEY, SPF, UINFO, UID, GID, UNSPEC, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, TA, DLV, WINS, WINSR

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IPAddress
{{Fill IPAddress Description}}

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourceType
{{Fill ResourceType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Indented.Net.Dns.CacheRecord
### Indented.Net.Dns.ResourceRecord
## OUTPUTS

### Indented.Net.Dns.CacheRecord
## NOTES

## RELATED LINKS
