New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.KEYProtocol" -Type "Byte" -Members @{
  Reserved = 0;
  TLS      = 1;
  EMmail   = 2;
  DNSSEC   = 3;
  IPSEC    = 4;
  All      = 255;
}

