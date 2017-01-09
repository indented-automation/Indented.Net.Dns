#
# Module loader for Indented.DnsResolver
#
# Author: Chris Dent
#

# Static enumerations
[Array]$Enum = 'Indented.DnsResolver.AFSDBSubType',
               'Indented.DnsResolver.ATMAFormat',
               'Indented.DnsResolver.CertificateType',
               'Indented.DnsResolver.DigestType',
               'Indented.DnsResolver.EDnsOptionCode',
               'Indented.DnsResolver.EDnsSECOK',
               'Indented.DnsResolver.EncryptionAlgorithm',
               'Indented.DnsResolver.Flags',
               'Indented.DnsResolver.IanaAddressFamily',
               'Indented.DnsResolver.IPSECAlgorithm',
               'Indented.DnsResolver.IPSECGatewayType',
               'Indented.DnsResolver.KEYAC',
               'Indented.DnsResolver.KEYNameType',
               'Indented.DnsResolver.KEYProtocol',
               'Indented.DnsResolver.LLQErrorCode',
               'Indented.DnsResolver.LLQOpCode',
               'Indented.DnsResolver.MessageCompression',
               'Indented.DnsResolver.MSDNSOption',
               'Indented.DnsResolver.NSEC3Flags',
               'Indented.DnsResolver.NSEC3HashAlgorithm',
               'Indented.DnsResolver.QR',
               'Indented.DnsResolver.RCode',
               'Indented.DnsResolver.RecordClass',
               'Indented.DnsResolver.RecordType',
               'Indented.DnsResolver.SSHAlgorithm',
               'Indented.DnsResolver.SSHFPType',
               'Indented.DnsResolver.TKEYMode',
               'Indented.DnsResolver.WINSMappingFlag'

if ($Enum.Count -ge 1) {
  New-Variable DnsResolverModuleBuilder -Value (New-DynamicModuleBuilder Indented.DnsResolver -UseGlobalVariable $false) -Scope Script
  $Enum | ForEach-Object {
    Import-Module "$psscriptroot\enum\$_.ps1"
  }
}

# Private functions
[Array]$Private = 'ConvertFromDnsDomainName',
                  'ConvertToDnsDomainName',
                  'NewDnsMessage',
                  'NewDnsMessageHeader',
                  'NewDnsMessageQuestion',
                  'NewDnsOPTRecord',
                  'NewDnsSOARecord',
                  'ReadDnsA6Record',
                  'ReadDnsAAAARecord',
                  'ReadDnsAFSDBRecord',
                  'ReadDnsAPLRecord',
                  'ReadDnsARecord',
                  'ReadDnsATMARecord',
                  'ReadDnsCERTRecord',
                  'ReadDnsCharacterString',
                  'ReadDnsCNAMERecord',
                  'ReadDnsDHCIDRecord',
                  'ReadDnsDLVRecord',
                  'ReadDnsDNAMERecord',
                  'ReadDnsDNSKEYRecord',
                  'ReadDnsDSRecord',
                  'ReadDnsEIDRecord',
                  'ReadDnsGPOSRecord',
                  'ReadDnsHINFORecord',
                  'ReadDnsHIPRecord',
                  'ReadDnsIPSECKEYRecord',
                  'ReadDnsISDNRecord',
                  'ReadDnsKEYRecord',
                  'ReadDnsKXRecord',
                  'ReadDnsLOCRecord',
                  'ReadDnsMBRecord',
                  'ReadDnsMDRecord',
                  'ReadDnsMessage',
                  'ReadDnsMessageHeader',
                  'ReadDnsMessageQuestion',
                  'ReadDnsMFRecord',
                  'ReadDnsMGRecord',
                  'ReadDnsMINFORecord',
                  'ReadDnsMRRecord',
                  'ReadDnsMXRecord',
                  'ReadDnsNAPTRRecord',
                  'ReadDnsNINFORecord',
                  'ReadDnsNSAPRecord',
                  'ReadDnsNSEC3PARAMRecord',
                  'ReadDnsNSEC3Record',
                  'ReadDnsNSECRecord',
                  'ReadDnsNSRecord',
                  'ReadDnsNULLRecord',
                  'ReadDnsNXTRecord',
                  'ReadDnsOPTRecord',
                  'ReadDnsPTRRecord',
                  'ReadDnsPXRecord',
                  'ReadDnsResourceRecord',
                  'ReadDnsRKEYRecord',
                  'ReadDnsRPRecord',
                  'ReadDnsRRSIGRecord',
                  'ReadDnsRTRecord',
                  'ReadDnsSIGRecord',
                  'ReadDnsSINKRecord',
                  'ReadDnsSOARecord',
                  'ReadDnsSPFRecord',
                  'ReadDnsSRVRecord',
                  'ReadDnsSSHFPPRecord',
                  'ReadDnsTARecord',
                  'ReadDnsTKEYRecord',
                  'ReadDnsTSIGRecord',
                  'ReadDnsTXTRecord',
                  'ReadDnsUnknownRecord',
                  'ReadDnsWINSRecord',
                  'ReadDnsWINSRRecord',
                  'ReadDnsWKSRecord',
                  'ReadDnsX25Record'

if ($Private.Count -ge 1) {
  $Private | ForEach-Object {
    Import-Module "$psscriptroot\func-priv\$_.ps1"
  }
}

# Public functions
[Array]$Public = 'Add-InternalDnsCacheRecord',
                 'Get-Dns',
                 'Get-DnsServerList',
                 'Get-InternalDnsCacheRecord',
                 'Initialize-InternalDnsCache',
                 'Remove-InternalDnsCacheRecord',
                 'Update-InternalRootHints'

if ($Public.Count -ge 1) {
  $Public | ForEach-Object {
    Import-Module "$psscriptroot\func\$_.ps1"
  }
}

# Resolver (Message): Initialize the DNS cache for Get-Dns
Initialize-InternalDnsCache

# Resolver (Message): Set a variable to store TC state.
New-Variable DnsTCEndFound -Scope Script -Value $false

