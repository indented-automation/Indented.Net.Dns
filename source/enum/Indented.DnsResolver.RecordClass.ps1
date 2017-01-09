New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.RecordClass" -Type "UInt16" -Members @{
  IN   = 1;      # [RFC1035]
  CH   = 3;      # [Moon1981]
  HS   = 4;      # [Dyer1987]
  NONE = 254;    # [RFC2136] 
  ANY  = 255;    # [RFC1035]
}

