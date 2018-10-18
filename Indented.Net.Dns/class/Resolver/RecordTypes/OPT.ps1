class OPT : DnsResourceRecord {
    <#
      OPT records make the following changes to standard resource record fields:
    
      Field Name   Field Type     Description
      ----------   ----------     -----------
      NAME         domain name    empty (root domain)
      TYPE         u_int16_t      OPT
      CLASS        u_int16_t      sender's UDP payload size
      TTL          u_int32_t      extended RCODE and flags
      RDLEN        u_int16_t      describes RDATA
      RDATA        octet stream   {attribute,value} pairs
    
      The Extended RCODE (stored in the TTL) is formatted as follows:
     
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |    EXTENDED-RCODE     |        VERSION        |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                       Z                       |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    
      RR data structure:
    
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  OPTION-CODE                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                 OPTION-LENGTH                 |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                  OPTION-DATA                  /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    
      Processing for each option assigned by IANA has been added as described below.
    
      LLQ
      ---
    
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  OPTION-CODE                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                 OPTION-LENGTH                 |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    VERSION                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  LLQ-OPCODE                   |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  ERROR-CODE                   |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
       |                    LLQ-ID                     |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
       |                  LEASE-LIFE                   |
       |                                               |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    
      NSID
      ----
    
      Option data is returned as a byte array (NSIDBytes) and an ASCII string (NSIDString).
    
      DUA, DHU and N3U
      ----------------
    
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  OPTION-CODE                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  LIST-LENGTH                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |        ALG-CODE       |          ...          /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    
      EDNS-client-subnet
      ------------------
    
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                  OPTION-CODE                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                 OPTION-LENGTH                 |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                 ADDRESSFAMILY                 |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |    SOURCE NETMASK     |     SCOPE NETMASK     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
       /                    ADDRESS                    /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
     
      http://www.ietf.org/rfc/rfc2671.txt
      http://files.dns-sd.org/draft-sekar-dns-llq.txt
      http://files.dns-sd.org/draft-sekar-dns-ul.txt
      http://www.ietf.org/rfc/rfc5001.txt
      http://www.ietf.org/rfc/rfc6975.txt
      http://www.ietf.org/id/draft-vandergaast-edns-client-subnet-02.txt
    #>

    [UInt16]       $MaximumPayloadSize
    [UInt16]       $ExtendedRCode
    [UInt32]       $Version
    [EDnsDNSSECOK] $Z

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.MaximumPayloadSize = $this.RecordClass
        $this.ExtendedRCode = [RCode][UInt16]($this.TTL -shr 24)
        $this.Version = $this.TTL -band 0x00FF0000
        $this.DNSSECOK = [EDnsDNSSECOK]($this.TTL -band 0x00008000)
    }

    
}