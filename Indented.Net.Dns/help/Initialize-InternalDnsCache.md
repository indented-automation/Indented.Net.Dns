---
external help file: Indented.Net.Dns-help.xml
Module Name: Indented.Net.Dns
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Initialize-InternalDnsCache

## SYNOPSIS
Initializes a basic DNS cache for use by Get-Dns.

## SYNTAX

```
Initialize-InternalDnsCache [<CommonParameters>]
```

## DESCRIPTION
Get-Dns maintains a limited DNS cache, capturing A and AAAA records, to assist name server resolution (for values passed using the Server parameter).

The cache may be manipulated using *-InternalDnsCacheRecord CmdLets.

## EXAMPLES

### EXAMPLE 1
```
Initialize-InternalDnsCache
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
