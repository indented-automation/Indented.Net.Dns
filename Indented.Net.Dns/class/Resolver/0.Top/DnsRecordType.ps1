class DnsRecordType {
    [String] $Name
    [UInt16] $TypeID

    DnsRecordType(
        [String] $value
    ) {
        if ($value -eq 'NSAPTR') {
            $this.Name = 'NSA-PTR'
        } else {
            $this.Name = $value
        }

        if ([RecordType].IsEnumDefined($value)) {
            $this.TypeID = [RecordType]$value
        } elseif ($value -match '^TYPE(\d+)$') {
            $this.TypeID = $matches[1]
        }
    }

    DnsRecordType(
        [Int32] $value
    ) {
        $this.TypeID = $value
        if ([RecordType].IsEnumDefined($value)) {
            if ($value -eq 23) {
                $this.Name = 'NSAP-PTR'
            } else {
                $this.Name = [RecordType]$value
            }
        } else {
            $this.Name = 'TYPE{0}' -f $value
        }
    }

    hidden static [UInt16] op_Implicit([DnsRecordType] $dnsRecordType) {
        return [Int32]$dnsRecordType.TypeID
    }

    [String] ToString() {
        return $this.Name
    }
}
