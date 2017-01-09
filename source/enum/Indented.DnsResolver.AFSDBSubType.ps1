New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.AFSDBSubType" -Type "UInt16" -Members @{
  AFSv3Loc   = 1;    # Andrews File Service v3.0 Location Service  [RFC1183]
  DCENCARoot = 2;    # DCE/NCA root cell directory node            [RFC1183]
}

