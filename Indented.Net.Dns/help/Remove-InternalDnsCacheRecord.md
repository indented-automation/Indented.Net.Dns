---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version:
schema: 2.0.0
---

# Remove-InternalDnsCacheRecord

## SYNOPSIS
Remove a single entry from the internal DNS cache.

## SYNTAX

```
Remove-InternalDnsCacheRecord [[-Name] <String>] [[-RecordType] <RecordType>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove a single entry from the internal DNS cache.

## EXAMPLES

### EXAMPLE 1
```
Remove-InternalDnsCacheRecord someName -RecordType A
```

## PARAMETERS

### -Name
The name of the record to retrieve.

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
The record type to retrieve.

```yaml
Type: RecordType
Parameter Sets: (All)
Aliases:
Accepted values: EMPTY, A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NULL, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, NSAP, NSAPPTR, SIG, KEY, PX, GPOS, AAAA, LOC, NXT, EID, NIMLOC, SRV, ATMA, NAPTR, KX, CERT, A6, DNAME, SINK, OPT, APL, DS, SSHFP, IPSECKEY, RRSIG, NSEC, DNSKEY, DHCID, NSEC3, NSEC3PARAM, TLSA, SMIMEA, HIP, NINFO, RKEY, TALINK, CDS, CDNSKEY, OPENPGPKEY, CSYNC, ZONEMD, SPF, UINFO, UID, GID, UNSPEC, NID, L32, L64, LP, EUI48, EUI64, TKEY, TSIG, IXFR, AXFR, MAILB, MAILA, ANY, URI, CAA, AVC, DOA, AMTRELAY, TA, DLV, WINS, WINSR, UNKNOWN

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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
