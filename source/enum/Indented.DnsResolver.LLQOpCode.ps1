New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.LLQOpCode" -Type "UInt16" -Members @{
  LLQSetup   = 1;
  LLQRefresh = 2;
  LLQEvent   = 3;
}

