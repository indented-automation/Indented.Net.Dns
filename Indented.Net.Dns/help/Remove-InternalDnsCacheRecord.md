---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Remove-InternalDnsCacheRecord

## SYNOPSIS
Remove an entry from the DNS cache object.

## SYNTAX

### CacheRecord (Default)
```
Remove-InternalDnsCacheRecord -CacheRecord <Object> [<CommonParameters>]
```

### AllExpired
```
Remove-InternalDnsCacheRecord [-AllExpired] [<CommonParameters>]
```

## DESCRIPTION
Remove-InternalDnsCacheRecord allows the removal of individual records from the cache, or removal of all records which expired.

## EXAMPLES

### EXAMPLE 1
```
Get-InternalDnsCacheRecord a.root-servers.net | Remove-InternalDnsCacheRecord
```

### EXAMPLE 2
```
Remove-InternalDnsCacheRecord -AllExpired
```

## PARAMETERS

### -CacheRecord
A record to add to the cache.

```yaml
Type: Object
Parameter Sets: CacheRecord
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AllExpired
A time property is used to age entries out of the cache.
If permanent is set the time is not, the value will not be purged based on the TTL.

```yaml
Type: SwitchParameter
Parameter Sets: AllExpired
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Indented.DnsResolver.RecordType
## OUTPUTS

## NOTES

## RELATED LINKS