enum ServerDynamicUpdate {
    NoRestriction  = 0    # No Restrictions
    NoSOAUpdate    = 1    # Does not allow dynamic updates of SOA records
    NoRootNSUpdate = 2    # Does not allow dynamic updates of NS records at the zone root
    NoNSUpdate     = 4    # Does not allow dynamic updates of NS records not at the zone root (delegation NS records)
}