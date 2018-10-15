enum DcPromoFlag {
    None          = 0    # No change to existing zone storage.
    ConvertDomain = 1    # Zone is to be stored in DNS domain partition. See DNS_ZONE_CREATE_FOR_DCPROMO (section 2.2.5.2.7.1).
    ConvertForest = 2    # Zone is to be stored in DNS forest partition. See DNS_ZONE_CREATE_FOR_DCPROMO_FOREST (section 2.2.5.2.7.1).
}