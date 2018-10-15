enum DnsSecMode {
    None = 0    # No DNSSEC records are included in the response unless the query requested a resource record set of the DNSSEC record type.
    All  = 1    # DNSSEC records are included in the response according to RFC 2535.
    Opt  = 2    # DNSSEC records are included in a response only if the original client query contained the OPT resource record according to RFC 2671
}