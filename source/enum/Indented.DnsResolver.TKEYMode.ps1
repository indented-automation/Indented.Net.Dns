New-Enum -ModuleBuilder $DnsResolverModuleBuilder -Name "Indented.DnsResolver.TKEYMode" -Type "UInt16" -Members @{
  ServerAssignment   = 1;    # Server assignment          [RFC2930]
  DH                 = 2;    # Diffie-Hellman Exchange    [RFC2930]
  GSSAPI             = 3;    # GSS-API negotiation        [RFC2930]
  ResolverAssignment = 4;    # Resolver assignment        [RFC2930]
  KeyDeletion        = 5;    # Key deletion               [RFC2930]
}

