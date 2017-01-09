New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.SSHAlgorithm" -Type "Byte" -Members @{
  RSA = 1;    # [RFC4255]
  DSS = 2;    # [RFC4255]
}

