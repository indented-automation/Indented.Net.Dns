enum Rank {
    CacheBit          = 1     # The record came from the cache.
    RootHint          = 8     # The record is a preconfigured root hint.
    OutsideGlue       = 32    # This value is not used.
    CacheNAAdditional = 49    # The record was cached from the additional section of a nonauthoritative response.
    CacheNAAuthority  = 65    # The record was cached from the authority section of a nonauthoritative response.
    CacheAAdditional  = 81    # The record was cached from the additional section of an authoritative response.
    CacheNAAnswer     = 97    # The record was cached from the answer section of a nonauthoritative response.
    CacheAAuthority   = 113   # The record was cached from the authority section of an authoritative response.
    Glue              = 128   # The record is a glue record in an authoritative zone.
    NSGlue            = 130   # The record is a delegation (type NS) record in an authoritative zone.
    CacheAAnswer      = 193   # The record was cached from the answer section of an authoritative response.
    Zone              = 240   # The record comes from an authoritative zone.
}