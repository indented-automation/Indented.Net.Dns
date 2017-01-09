New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.EDnsDNSSECOK" -Type "UInt16" -SetFlagsAttribute -Members @{
  NONE = 0;
  DO   = 32768;    # DNSSEC answer OK    [RFC4035][RFC3225]
}

