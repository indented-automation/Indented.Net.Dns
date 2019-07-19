---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version:
schema: 2.0.0
---

# Get-InternalDnsCacheRecord

## SYNOPSIS
Get the content of the internal DNS cache used by Get-Dns.

## SYNTAX

```
Get-InternalDnsCacheRecord [[-Name] <String>] [[-RecordType] <String>] [-ResourceType <String>]
 [<CommonParameters>]
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
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourceType
The resource type to retrieve.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Indented.Net.Dns.CacheRecord
## OUTPUTS

### DnsCacheRecord
## NOTES

## RELATED LINKS
