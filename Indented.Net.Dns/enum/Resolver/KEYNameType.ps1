enum KEYNameType {
    UserKey  = 0    # Indicates that this is a key associated with a "user" or "account" at an end entity usually a host.
    ZoneKey  = 1    # Indicates that this is a zone key for the zone whose name is the KEY RR owner name.
    NonZone  = 2    # Indicates that this is a key associated with the non-zone "entity" whose name is the RR owner name.
    Reserved = 3    # Reserved
}