---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version:
schema: 2.0.0
---

# Add-InternalDnsCacheRecord

## SYNOPSIS
Add a new CacheRecord to the DNS cache object.

## SYNTAX

### CacheRecord (Default)
```
Add-InternalDnsCacheRecord -CacheRecord <DnsCacheRecord> [-ResourceType <CacheResourceType>] [-Permanent]
 [<CommonParameters>]
```

### ResourceRecord
```
Add-InternalDnsCacheRecord -ResourceRecord <DnsResourceRecord> [-ResourceType <CacheResourceType>] [-Permanent]
 [<CommonParameters>]
```

## DESCRIPTION
The DNS cache is used to reduce the effort required to resolve DNS server names used with the ComputerName parameter.

## EXAMPLES

### EXAMPLE 1
```
$CacheRecord | Add-InternalDnsCacheRecord
```

## PARAMETERS

### -CacheRecord
A record to add to the cache.

```yaml
Type: DnsCacheRecord
Parameter Sets: CacheRecord
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceRecord
A resource record to add to the cache.

```yaml
Type: DnsResourceRecord
Parameter Sets: ResourceRecord
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceType
The cache object type.

```yaml
Type: CacheResourceType
Parameter Sets: (All)
Aliases:
Accepted values: Hint, Address

Required: False
Position: Named
Default value: Address
Accept pipeline input: False
Accept wildcard characters: False
```

### -Permanent
A time property is used to age entries out of the cache.
If permanent is set the time is not, the value will not be purged based on the TTL.

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

### DnsCacheRecord
### DnsResourceRecord
## OUTPUTS

### DnsCacheRecord
## NOTES

## RELATED LINKS
