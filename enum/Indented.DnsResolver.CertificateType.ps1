New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.CertificateType" -Type "UInt16" -Members @{
  PKIX    = 1;      # X.509 as per PKIX
  SPKI    = 2;      # SPKI certificate
  PGP     = 3;      # OpenPGP packet
  IPKIX   = 4;      # The URL of an X.509 data object
  ISPKI   = 5;      # The URL of an SPKI certificate
  IPGP    = 6;      # The fingerprint and URL of an OpenPGP packet
  ACPKIX  = 7;      # Attribute Certificate
  IACPKIX = 8;      # The URL of an Attribute Certificate
  URI     = 253;    # URI private
  OID     = 254;    # OID private
}

