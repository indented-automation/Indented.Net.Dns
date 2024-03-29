class DnsRecordType : IComparable, IEquatable[Object] {
    [string] $Name
    [UInt16] $TypeID

    DnsRecordType(
        [RecordType] $value
    ) {
        if ($value -eq 'NSAPPTR') {
            $this.Name = 'NSAP-PTR'
        } else {
            $this.Name = $value
        }

        $this.TypeId = $value
    }

    DnsRecordType(
        [string] $value
    ) {
        if ($value -eq 'NSAPPTR') {
            $this.Name = 'NSAP-PTR'
        } else {
            $this.Name = $value
        }

        $value = $value.ToUpper().Trim()
        if ($value -eq 'NSAP-PTR') {
            $this.TypeID = 23
        } elseif ([RecordType].IsEnumDefined($value)) {
            $this.TypeID = [RecordType]$value
        } elseif ($value -match '^TYPE(\d+)$') {
            $this.TypeID = $matches[1]
        } else {
            throw 'Unable to parse record type to a type ID'
        }
    }

    DnsRecordType(
        [int] $value
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
        return [int]$dnsRecordType.TypeID
    }

    # Hack to support more than one cast
    hidden static [RecordType] op_Implicit([Object] $dnsRecordType) {
        return [RecordType]$dnsRecordType.TypeID
    }

    [int] CompareTo(
        [Object] $object
    ) {
        [UInt16]$uint16 = 0
        if ($object -is [DnsRecordType]) {
            return $this.TypeID.CompareTo($object.TypeID)
        } elseif ($object -is [RecordType]) {
            return $this.TypeID.CompareTo([UInt16]$object)
        } elseif ([int]::TryParse($object, [ref]$uint16)) {
            return $this.TypeID.CompareTo($uint16)
        } elseif ($object -is [string]) {
            try {
                return $this.TypeID.CompareTo(([DnsRecordType]$object).TypeID)
            } catch {
                throw 'Invalid record type'
            }
        } else {
            throw 'Invalid comparison'
        }
    }

    [bool] Equals(
        [Object] $object
    ) {
        return $this.CompareTo($object) -eq 0
    }

    [string] ToString() {
        return $this.Name
    }
}
