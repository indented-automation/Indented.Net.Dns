enum EDnsOptionCode {
    LLQ                  = 1    # On-hold      [http://files.dns-sd.org/draft-sekar-dns-llq.txt]
    UL                   = 2    # On-hold      [http://files.dns-sd.org/draft-sekar-dns-ul.txt]
    NSID                 = 3    # Standard     [RFC5001]
    DAU                  = 5    # Standard     [RFC6975]
    DHU                  = 6    # Standard     [RFC6975]
    N3U                  = 7    # Standard     [RFC6975]
    EDNSClientSubnet     = 8    # Optional     [draft-vandergaast-edns-client-subnet][Wilmer_van_der_Gaast]
}
