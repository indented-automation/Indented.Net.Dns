New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.LLQErrorCode" -Type "UInt16" -Members @{
  NoError    = 0;
  ServFull   = 1;
  Static     = 2;
  FormatErr  = 3;
  NoSuchLLQ  = 4;
  BadVers    = 5;
  UnknownErr = 6;
}

