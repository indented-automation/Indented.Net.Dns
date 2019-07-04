using namespace System.Collections.Generic
using namespace System.IO

class DnsResourceRecord {
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

    [String]      $Name
    [UInt32]      $TTL
    [RecordClass] $RecordClass      = [RecordClass]::IN
    [RecordType]  $RecordType       = [RecordType]::Empty
    [UInt16]      $RecordDataLength

    hidden [Boolean] $IsTruncated

    DnsResourceRecord() { }

    DnsResourceRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Name = $dnsResourceRecord.Name
        $this.RecordClass = [RecordClass]$binaryReader.ReadUInt16($true)
        $this.TTL = $binaryReader.ReadUInt32($true)
        $this.RecordDataLength = $binaryReader.ReadUInt16($true)

        if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + $this.RecordDataLength)) {
            $this.ReadRecordData($binaryReader)
        }
    }

    static [DnsResourceRecord] Parse(
        [Byte[]]$bytes
    ) {
        $binaryReader = [EndianBinaryReader][MemoryStream]$bytes

        return [DnsResourceRecord]::Parse($binaryReader)
    }

    static [DnsResourceRecord] Parse(
        [EndianBinaryReader]$binaryReader
    ) {
        $resourceRecord = [DnsResourceRecord]::new()
        $resourceRecord.Name = $binaryReader.ReadDnsDomainName()

        if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + 10)) {
            [Int32]$type = $binaryReader.ReadUInt16($true)
            if ([Enum]::IsDefined([RecordType], $type)) {
                $resourceRecord.RecordType = [RecordType]$type
            } else {
                $resourceRecord.RecordType = [RecordType]::Unknown
            }
            $typeName = 'Dns{0}Record' -f $resourceRecord.RecordType

            return ($typeName -as [Type])::new(
                $resourceRecord,
                $binaryReader
            )
        } else {
            $resourceRecord.IsTruncated = $true
        }

        return $resourceRecord
    }

    # Child classes should override this method
    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $binaryReader.ReadBytes($this.RecordDataLength)
    }

    # Child classes should override this method
    hidden [String] RecordDataToString() {
        return ''
    }

    # Child classes shoudl override this method if appropriate
    hidden [Byte[]] RecordDataToByteArray(
        [Boolean] $useCompressedNames
    ) {
        return [Byte[]]::new($this.RecordDataLength)
    }

    [Byte[]] ToByteArray() {
        return $this.ToByteArray($true)
    }

    [Byte[]] ToByteArray(
        [Boolean] $useCompressedNames
    ) {
        $bytes = [List[Byte]]::new()

        if ($useCompressedNames) {
            $bytes.AddRange([Byte[]](0xC0, 0x0C))
        } else {
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.Name))
        }

        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordType, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordClass, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt32]$this.TTL, $true))

        $recordDataBytes = $this.RecordDataToByteArray($useCompressedNames)

        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$recordDataBytes.Count, $true))
        $bytes.AddRange($recordDataBytes)

        return $bytes.ToArray()
    }

    [String] ToString() {
        return '{0} {1} {2} {3} {4}' -f @(
            $this.Name.PadRight(29, ' ')
            $this.TTL.ToString().PadRight(10, ' ')
            $this.RecordClass.ToString().PadRight(5, ' ')
            $this.RecordType.ToString().PadRight(10, ' ')
            $this.RecordDataToString()
        )
    }
}