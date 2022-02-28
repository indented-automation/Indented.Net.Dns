# Indented.Net.Dns

[![Build status](https://ci.appveyor.com/api/projects/status/9ux21qj5ehh3ihti?svg=true)](https://ci.appveyor.com/project/indented-automation/indented-net-dns)

PowerShell based DNS client providing similar functionality to `Resolve-DnsName`, `nslookup`, and `dig`.

Supports all known record types.

## Installation

Indented.Net.Dns can be installed from the PowerShell gallery.

```powershell
Install-Module Indented.Net.Dns
```

Indented.Net.Dns is compatible with PowerShell 5, 6 and 7 and has been tested on Windows and CentOS.

## Commands

Indented.Net.Dns provides a number of commands to execute DNS queries against name servers.

### Get-Dns

```plain
Get-Dns [[-Name] <String>]
        [[-RecordType] <RecordType>]
        [-RecordClass <RecordClass>]
        [-NoRecursion]
        [-DnsSec]
        [-EDns]
        [-EDnsBufferSize <UInt16>]
        [-NoTcpFallback]
        [-SearchList <String[]>]
        [-Tcp]
        [-Port <UInt16>]
        [-Timeout <Byte>]
        [-IPv6]
        [-ComputerName <String>]
        [-DnsDebug]
```

### Get-DnsVersion

Short-cut to execute a query for bind.version.

```plain
Get-DnsVersion [-Tcp]
               [[-Port] <UInt16>]
               [-IPv6]
               [[-ComputerName] <String>]
```

Equivalent to:

```powershell
Get-Dns -Name bind.version. -RecordType TXT -RecordClass CH
```

### Get-DnsZoneTransfer

```plain
```

### Search-Dns

Uses Get-Dns to search the authoritative name servers of a zone for a specific record.

```plain
Search-Dns [-Name] <String>
           [-ZoneName] <String>
           [[-RecordType] <RecordType>]
           [-Tcp]
           [-Port <UInt16>]
           [-IPv6]
           [-ComputerName <String>]
```

### Trace-Dns

Performs an iterative search for a record from either root hints of a specified DNS server.

```plain
Trace-Dns [-Name] <String>
          [-ZoneName] <String>
          [[-RecordType] <RecordType>]
          [-Tcp]
          [-Port <UInt16>]
          [-IPv6]
          [-ComputerName <String>]
```

## Classes

The classes within this module are accessible by using the module.

```powershell
using module Indented.Net.Dns
```

This module contains a large number of classes. Notable classes are shown below.

### DnsMessage

Describes a DNS message to send or receive.

#### Constructors

```plain
DnsMessage new()
DnsMessage new(String name, RecordType recordType)
DnsMessage new(String name, RecordType recordType, RecordClass recordClass)
DnsMessage new(String name, RecordType recordType, RecordClass recordClass)
DnsMessage new(String name, RecordType recordType, RecordClass recordClass, UInt32 serial)
DnsMessage new(Byte[] bytes)
```

#### Methods

```plain
void SetEDnsBufferSize()
void SetEDnsBufferSize(UInt16 size)
void SetAcceptDnsSec()
void DisableRecursion()
```

### DnsClient

The DnsClient class uses TCP and UDP sockets to communicate with a remote DNS server.

#### Constructors

```plain
DnsClient new()
DnsClient new(Boolean useTcp, Boolean useIPv6)
DnsClient new(Boolean useTcp, Boolean useIPv6, Int32 receiveTimeout, Int32 sendTimeout)
```

#### Methods

```plain
void SendQuestion(DnsMessage message, IPAddress ipAddress)
void SendQuestion(DnsMessage message, IPAddress ipAddress, UInt16 port)
DnsMessage ReceiveAnswer()
Byte[] ReceiveBytes()
void Close()
```
