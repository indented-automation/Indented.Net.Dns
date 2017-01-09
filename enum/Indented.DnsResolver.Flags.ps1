New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.Flags" -Type "UInt16" -SetFlagsAttribute -Members @{
  None = 0;
  AA   = 1024;    # Authoritative Answer  [RFC1035]
  TC   = 512;     # Truncated Response    [RFC1035]
  RD   = 256;     # Recursion Desired     [RFC1035]
  RA   = 128;     # Recursion Allowed     [RFC1035]
  AD   = 32;      # Authenticated Data    [RFC4035]
  CD   = 16;      # Checking Disabled     [RFC4035]
}

