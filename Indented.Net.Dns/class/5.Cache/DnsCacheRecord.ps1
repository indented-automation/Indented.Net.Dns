class DnsCacheRecord {
    [String]            $Name
    [UInt32]            $TTL
    [DnsRecordType]     $RecordType
    [IPAddress]         $IPAddress
    [CacheResourceType] $ResourceType = 'Address'
    [DateTime]          $TimeAdded = (Get-Date)
    [Boolean]           $IsPermanent

    DnsCacheRecord() { }

    DnsCacheRecord(
        [DnsARecord] $dnsRecord
    ) {
        $this.Initialize($dnsRecord)
    }

    DnsCacheRecord(
        [DnsAAAARecord] $dnsRecord
    ) {
        $this.Initialize($dnsRecord)
    }

    hidden Initialize(
        $dnsRecord
    ) {
        $this.Name = $dnsRecord.Name
        $this.TTL = $dnsRecord.TTL
        $this.RecordType = $dnsRecord.RecordType
        $this.IPAddress = $dnsRecord.IPAddress
    }

    static [DnsCacheRecord] Parse(
        [String] $recordData
    ) {
        if ($recordData -match '(?<Name>\S+)\s+(?<TTL>\d+)\s+(IN)?\s*(?<RecordType>A|AAAA)\s+(?<IPAddress>\S+)') {
            $matches.Remove(0)
            return [DnsCacheRecord]$matches
        } else {
            throw 'Invalid record data format'
        }
    }

    [Boolean] HasExpired() {
        if ($this.IsPermanent) {
            return $false
        }

        return $this.TimeAdded.AddSeconds($this.TTL) -lt (Get-Date)
    }
}