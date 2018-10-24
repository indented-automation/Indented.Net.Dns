---
external help file: Indented.Net.Dns-help.xml
online version: 
schema: 2.0.0
---

# Add-InternalDnsCacheRecord

## SYNOPSIS
Add a new CacheRecord to the DNS cache object.

## SYNTAX

### CacheRecord (Default)
```
Add-InternalDnsCacheRecord -CacheRecord <Object> [-ResourceType <String>] [-Permanent]
```

### ResourceRecord
```
Add-InternalDnsCacheRecord -ResourceRecord <Object> [-ResourceType <String>] [-Permanent]
```

## DESCRIPTION
Cache records must expose the following property members:

  - Name
  - TTL
  - RecordType
  - IPAddress

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$CacheRecord | Add-InternalDnsCacheRecord
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

### -ResourceRecord
A resource record to add to the cache.

```yaml
Type: Object
Parameter Sets: ResourceRecord
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceType
The cache object type.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

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

## INPUTS

### Indented.Net.Dns.CacheRecord

## OUTPUTS

### Indented.Net.Dns.CacheRecord

## NOTES

## RELATED LINKS

