New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.ATMAFormat" -Type "UInt16" -Members @{
  AESA = 0;    # ATM End System Address
  E164 = 1;    # E.164 address format
  NSAP = 2;    # Network Service Access Protocol (NSAP) address model 
}

