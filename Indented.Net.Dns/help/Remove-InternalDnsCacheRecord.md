---
external help file: Indented.Net.Dns-help.xml
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
Remove-InternalDnsCacheRecord -CacheRecord <Object> [-WhatIf] [-Confirm]
```

### AllExpired
```
Remove-InternalDnsCacheRecord [-AllExpired] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Remove-InternalDnsCacheRecord allows the removal of individual records from the cache, or removal of all records which expired.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-InternalDnsCacheRecord a.root-servers.net | Remove-InternalDnsCacheRecord
```

### -------------------------- EXAMPLE 2 --------------------------
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

## INPUTS

### Indented.DnsResolver.RecordType

## OUTPUTS

## NOTES

## RELATED LINKS

