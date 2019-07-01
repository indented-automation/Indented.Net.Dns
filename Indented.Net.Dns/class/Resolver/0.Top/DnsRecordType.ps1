class DnsRecordType {
    [String] $Name
    [UInt16] $TypeID

    hidden [Hashtable] $validValues = @{}

    DnsRecordType(
        [String] $value
    ) {
        $this.Initialize()

        $this.Name = $value
        $this.TypeID = $this.validValues[$value]
    }

    DnsRecordType(
        [Int32] $value
    ) {
        $this.Initialize()

        $this.TypeID = $value
        $this.Name = $this.validValues.Keys.Where{ $this.validValues[$_] -eq $value }
        if (-not $this.Name) {
            $this.Name = 'TYPE{0}' -f $value
        }
    }

    [Void] Initialize() {
        foreach ($value in [RecordType].GetEnumValues()) {
            if ($value -eq 23) {
                $this.validValues.Add('NSAP-PTR', $value)
            } else {
                $this.validValues.Add([String]$value, $value)
            }
        }
    }

    hidden static [UInt16] op_Implicit([DnsRecordType] $dnsRecordType) {
        return [Int32]$dnsRecordType.TypeID
    }

    [String] ToString() {
        return $this.Name
    }
}
