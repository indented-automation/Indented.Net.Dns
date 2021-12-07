using namespace System.Collections.Generic
using namespace System.IO

class DnsResourceRecord : IEquatable[Object] {
    <#
                                      1  1  1  1  1  1
        0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                      NAME                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      TYPE                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                     CLASS                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      TTL                      |
       |                                               |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                   RDLENGTH                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
       /                     RDATA                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [string]        $Name
    [UInt32]        $TTL
    [RecordClass]   $RecordClass      = [RecordClass]::IN
    [DnsRecordType] $RecordType       = 'EMPTY'
    [string]        $RecordData
    [ushort]        $RecordDataLength

    hidden [bool] $IsTruncated

    DnsResourceRecord() {
        $thisTypeName = $this.GetType().Name
        if ($thisTypeName -ne 'DnsResourceRecord') {
            $this.RecordType = $thisTypeName -replace '^Dns|Record$'
        }
    }

    DnsResourceRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Name = $dnsResourceRecord.Name
        $this.RecordType = $dnsResourceRecord.RecordType

        $this.RecordClass = $binaryReader.ReadUInt16($true)
        $this.TTL = $binaryReader.ReadUInt32($true)
        $this.RecordDataLength = $binaryReader.ReadUInt16($true)

        if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + $this.RecordDataLength)) {
            $this.ReadRecordData($binaryReader)
        }
        $this.RecordData = $this.RecordDataToString()
    }

    static [DnsResourceRecord] Parse(
        [byte[]] $bytes
    ) {
        $binaryReader = [EndianBinaryReader][MemoryStream]$bytes

        return [DnsResourceRecord]::Parse($binaryReader)
    }

    static [DnsResourceRecord] Parse(
        [EndianBinaryReader] $binaryReader
    ) {
        $resourceRecord = [DnsResourceRecord]::new()
        $resourceRecord.Name = $binaryReader.ReadDnsDomainName()

        if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + 10)) {
            $resourceRecord.RecordType = [int]$binaryReader.ReadUInt16($true)
            $typeName = 'Dns{0}Record' -f $resourceRecord.RecordType

            if ($typeName -as [Type]) {
                return ($typeName -as [Type])::new(
                    $resourceRecord,
                    $binaryReader
                )
            } else {
                # Avoids a race condition when loading classes.
                return ('DnsUNKNOWNRecord' -as [Type])::new(
                    $resourceRecord,
                    $binaryReader
                )
            }
        } else {
            $resourceRecord.IsTruncated = $true
        }

        return $resourceRecord
    }

    # Child classes must override this method
    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $binaryReader.ReadBytes($this.RecordDataLength)
    }

    # Child classes must override this method
    hidden [string] RecordDataToString() {
        return ''
    }

    # Child classes should override this method if appropriate
    hidden [byte[]] RecordDataToByteArray(
        [bool] $useCompressedNames
    ) {
        return [byte[]]::new($this.RecordDataLength)
    }

    [byte[]] ToByteArray() {
        return $this.ToByteArray($true)
    }

    [byte[]] ToByteArray(
        [bool] $useCompressedNames
    ) {
        $bytes = [List[byte]]::new()

        if ($useCompressedNames) {
            $bytes.AddRange([byte[]](0xC0, 0x0C))
        } else {
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.Name))
        }

        $bytes.AddRange([EndianBitConverter]::GetBytes([ushort]$this.RecordType, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([ushort]$this.RecordClass, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt32]$this.TTL, $true))

        $recordDataBytes = $this.RecordDataToByteArray($useCompressedNames)

        $bytes.AddRange([EndianBitConverter]::GetBytes([ushort]$recordDataBytes.Count, $true))
        $bytes.AddRange($recordDataBytes)

        return $bytes.ToArray()
    }

    [bool] Equals(
        [Object] $object
    ) {
        return $this.ToString() -eq $object.ToString()
    }

    [string] ToString() {
        return '{0,-29} {1,-10} {2,-5} {3,-10} {4}' -f @(
            $this.Name
            $this.TTL
            $this.RecordClass
            $this.RecordType
            $this.RecordData
        )
    }
}
