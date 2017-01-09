New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.DigestType" -Type "Byte" -Members @{
  SHA1   = 1;    # MANDATORY    [RFC3658]
  SHA256 = 2;    # MANDATORY    [RFC4059]
  GOST   = 3;    # OPTIONAL     [RFC5933]
  SHA384 = 4;    # OPTIONAL     [RFC6605]
}

