$enumeration = @(
    'AD\DcPromoFlag'
    'AD\Rank'
    'AD\ZonePropertyID'
    'Resolver\AFSDBSubType'
    'Resolver\ATMAFormat'
    'Resolver\CertificateType'
    'Resolver\DigestType'
    'Resolver\DistanceType'
    'Resolver\EDnsDNSSECOK'
    'Resolver\EDnsOptionCode'
    'Resolver\EncryptionAlgorithm'
    'Resolver\HeaderFlags'
    'Resolver\IanaAddressFamily'
    'Resolver\IPSECAlgorithm'
    'Resolver\IPSECGatewayType'
    'Resolver\KEYAC'
    'Resolver\KEYNameType'
    'Resolver\KEYProtocol'
    'Resolver\LLQErrorCode'
    'Resolver\LLQOpCode'
    'Resolver\MessageCompression'
    'Resolver\MSDNSOption'
    'Resolver\NSEC3Flags'
    'Resolver\NSEC3HashAlgorithm'
    'Resolver\OpCode'
    'Resolver\QR'
    'Resolver\RCode'
    'Resolver\RecordClass'
    'Resolver\RecordType'
    'Resolver\SSHAlgorithm'
    'Resolver\SSHFPType'
    'Resolver\TKEYMode'
    'Resolver\WINSMappingFlag'
)

foreach ($file in $enumeration) {
    . ("{0}\enum\{1}.ps1" -f $psscriptroot, $file)
}

$class = @(
    'Network\EndianBinaryReader'
    'Network\EndianBitConverter'
    'Resolver\0.Miscelleneous\AngularDistance'
    'Resolver\1.MessageParts\DnsHeader'
    'Resolver\1.MessageParts\DnsQuestion'
    'Resolver\1.MessageParts\DnsResourceRecord'
    'Resolver\2.RecordTypes\DnsA6Record'
    'Resolver\2.RecordTypes\DnsAAAARecord'
    'Resolver\2.RecordTypes\DnsAFSDBRecord'
    'Resolver\2.RecordTypes\DnsAPLRecord'
    'Resolver\2.RecordTypes\DnsARecord'
    'Resolver\2.RecordTypes\DnsATMARecord'
    'Resolver\2.RecordTypes\DnsCERTRecord'
    'Resolver\2.RecordTypes\DnsCNAMERecord'
    'Resolver\2.RecordTypes\DnsDHCIDRecord'
    'Resolver\2.RecordTypes\DnsDLVRecord'
    'Resolver\2.RecordTypes\DnsDNAMERecord'
    'Resolver\2.RecordTypes\DnsDNSKEYRecord'
    'Resolver\2.RecordTypes\DnsDSRecord'
    'Resolver\2.RecordTypes\DnsEIDRecord'
    'Resolver\2.RecordTypes\DnsGPOSRecord'
    'Resolver\2.RecordTypes\DnsHINFORecord'
    'Resolver\2.RecordTypes\DnsHIPRecord'
    'Resolver\2.RecordTypes\DnsIPSECKEYRecord'
    'Resolver\2.RecordTypes\DnsISDNRecord'
    'Resolver\2.RecordTypes\DnsKEYRecord'
    'Resolver\2.RecordTypes\DnsKXRecord'
    'Resolver\2.RecordTypes\DnsLOCRecord'
    'Resolver\2.RecordTypes\DnsMBRecord'
    'Resolver\2.RecordTypes\DnsMDRecord'
    'Resolver\2.RecordTypes\DnsMFRecord'
    'Resolver\2.RecordTypes\DnsMGRecord'
    'Resolver\2.RecordTypes\DnsMINFORecord'
    'Resolver\2.RecordTypes\DnsMRRecord'
    'Resolver\2.RecordTypes\DnsMXRecord'
    'Resolver\2.RecordTypes\DnsNAPTRRecord'
    'Resolver\2.RecordTypes\DnsNIMLOCRecord'
    'Resolver\2.RecordTypes\DnsNINFORecord'
    'Resolver\2.RecordTypes\DnsNSAPPTRRecord'
    'Resolver\2.RecordTypes\DnsNSAPRecord'
    'Resolver\2.RecordTypes\DnsNSEC3PARAMRecord'
    'Resolver\2.RecordTypes\DnsNSEC3Record'
    'Resolver\2.RecordTypes\DnsNSECRecord'
    'Resolver\2.RecordTypes\DnsNSRecord'
    'Resolver\2.RecordTypes\DnsNULLRecord'
    'Resolver\2.RecordTypes\DnsNXTRecord'
    'Resolver\2.RecordTypes\DnsOPTRecord'
    'Resolver\2.RecordTypes\DnsPTRRecord'
    'Resolver\2.RecordTypes\DnsPXRecord'
    'Resolver\2.RecordTypes\DnsRKEYRecord'
    'Resolver\2.RecordTypes\DnsRPRecord'
    'Resolver\2.RecordTypes\DnsRRSIGRecord'
    'Resolver\2.RecordTypes\DnsRTRecord'
    'Resolver\2.RecordTypes\DnsSIGRecord'
    'Resolver\2.RecordTypes\DnsSINKRecord'
    'Resolver\2.RecordTypes\DnsSOARecord'
    'Resolver\2.RecordTypes\DnsSPFRecord'
    'Resolver\2.RecordTypes\DnsSRVRecord'
    'Resolver\2.RecordTypes\DnsSSHFPPRecord'
    'Resolver\2.RecordTypes\DnsTARecord'
    'Resolver\2.RecordTypes\DnsTKEYRecord'
    'Resolver\2.RecordTypes\DnsTSIGRecord'
    'Resolver\2.RecordTypes\DnsTXTRecord'
    'Resolver\2.RecordTypes\DnsUNKNOWNRecord'
    'Resolver\2.RecordTypes\DnsWINSRecord'
    'Resolver\2.RecordTypes\DnsWINSRRecord'
    'Resolver\2.RecordTypes\DnsWKSRecord'
    'Resolver\2.RecordTypes\DnsX25Record'
    'Resolver\3.Message\DnsMessage'
    'Resolver\4.Client\DnsClient'
    'ValidateDnsName'
)

foreach ($file in $class) {
    . ("{0}\class\{1}.ps1" -f $psscriptroot, $file)
}

$private = @(
    'Resolver\GetDnsSuffixSearchList'
    'Resolver\ResolveDnsServer'
    'Utility\ConvertTo-TimeSpanString'
)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Resolver\Add-InternalDnsCacheRecord'
    'Resolver\Get-Dns'
    'Resolver\Get-DnsServerList'
    'Resolver\Get-DnsVersion'
    'Resolver\Get-DnsZoneTransfer'
    'Resolver\Get-InternalDnsCacheRecord'
    'Resolver\Initialize-InternalDnsCache'
    'Resolver\Remove-InternalDnsCacheRecord'
    'Resolver\Search-Dns'
    'Resolver\Trace-Dns'
    'Resolver\Update-InternalRootHint'
)

foreach ($file in $public) {
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Add-InternalDnsCacheRecord'
    'Get-Dns'
    'Get-DnsServerList'
    'Get-DnsVersion'
    'Get-DnsZoneTransfer'
    'Get-InternalDnsCacheRecord'
    'Initialize-InternalDnsCache'
    'Remove-InternalDnsCacheRecord'
    'Search-Dns'
    'Trace-Dns'
    'Update-InternalRootHint'
)
Export-ModuleMember -Function $functionsToExport

. ("{0}\InitializeModule.ps1" -f $psscriptroot)
InitializeModule

