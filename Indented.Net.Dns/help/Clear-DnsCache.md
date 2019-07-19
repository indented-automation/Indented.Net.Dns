---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version:
schema: 2.0.0
---

# Clear-DnsCache

## SYNOPSIS
Clear the DNS Cache on the specified server.

## SYNTAX

### ComputerName (Default)
```
Clear-DnsCache [[-ComputerName] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### CimSession
```
Clear-DnsCache -CimSession <CimSession[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Clear-DnsCache uses the WMI class MicrosoftDNS_Cache to clear the DNS Cache on the specified server.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ComputerName
Clear the DNS cache on the specified server.
By default cache on the current server DNS cache is cleared.

```yaml
Type: String[]
Parameter Sets: ComputerName
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -CimSession
Clear the DNS Cache a DNS server using the specified CIM sessions.

```yaml
Type: CimSession[]
Parameter Sets: CimSession
Aliases:

Required: True
Position: Named
Default value: None
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
