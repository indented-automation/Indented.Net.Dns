---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Update-InternalRootHint

## SYNOPSIS
Updates the root hints file from InterNIC then re-initializes the internal cache.

## SYNTAX

```
Update-InternalRootHint [[-Source] <Uri>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The root hints file is used as the basis of an internal DNS cache.
The content of the root hints file is used during iterative name resolution.

## EXAMPLES

### EXAMPLE 1
```
Update-InternalRootHints
```

## PARAMETERS

### -Source
Update-InternalRootHints attempts to download a named.root file from InterNIC by default.
An alternative root hints source may be specified here.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Http://www.internic.net/domain/named.root
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
