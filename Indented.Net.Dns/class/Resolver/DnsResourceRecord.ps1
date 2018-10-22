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
    [Object]      $RecordType       = [RecordType]::Empty
    [UInt16]      $RecordDataLength

    Hidden [Boolean] $IsTruncated

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
                $resourceRecord.RecordType = 'UNKNOWN ({0})' -f $type
            }

            if ($resourceRecord.RecordType -eq [RecordType]::OPT) {
                $resourceRecord.RecordClass = $binaryReader.ReadUInt16($true)
            } else {
                $resourceRecord.RecordClass = [RecordClass]$binaryReader.ReadUInt16($true)
            }

            $resourceRecord.TTL = $binaryReader.ReadUInt32($true)
            $resourceRecord.RecordDataLength = $binaryReader.ReadUInt16($true)

            if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + $resourceRecord.RecordDataLength)) {
                if ($resourceRecord.RecordType -is [RecordType] -and $resourceRecord.RecordType.ToString() -as [Type]) {
                    $resourceRecord = $resourceRecord -as ($resourceRecord.RecordType.ToString() -as [Type])
                }
            } else {
                $resourceRecord.IsTruncated = $true
            }
        } else {
            $resourceRecord.IsTruncated = $true
        }

        $resourceRecord.ReadRecordData($binaryReader)
        return $resourceRecord
    }

    # Child classes should override this method
    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $binaryReader.ReadBytes($this.RecordDataLength)
    }

    # Child classes should override this method
    [String] RecordDataToString() {
        return ''
    }

    # Overrides ToString
    [String] ToString() {
        return '{0} {1} {2} {3} {4}' -f $this.Name.PadRight(29, ' '),
                                        $this.TTL.ToString().PadRight(10, ' '),
                                        $this.RecordClass.ToString().PadRight(5, ' '),
                                        $this.RecordType.ToString().PadRight(5, ' '),
                                        $this.RecordDataToString()
    }
}