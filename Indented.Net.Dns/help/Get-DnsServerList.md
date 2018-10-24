---
external help file: Indented.Net.Dns-help.xml
online version: http://www.ietf.org/rfc/rfc1034.txt
http://www.ietf.org/rfc/rfc1035.txt
http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01
schema: 2.0.0
---

# Get-DnsServerList

## SYNOPSIS
Gets a list of network interfaces and attempts to return a list of DNS server IP addresses.

## SYNTAX

```
Get-DnsServerList [-IPv6]
```

## DESCRIPTION
Get-DnsServerList uses System.Net.NetworkInformation to return a list of operational ethernet or wireless interfaces.
IP properties are returned, and an attempt to return a list of DNS server addresses is made.
If successful, the DNS server list is returned.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-DnsServerList
```

### -------------------------- EXAMPLE 2 --------------------------
```
Get-DnsServerList -IPv6
```

## PARAMETERS

### -IPv6
{{Fill IPv6 Description}}

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

## OUTPUTS

### System.Net.IPAddress

## NOTES

## RELATED LINKS

