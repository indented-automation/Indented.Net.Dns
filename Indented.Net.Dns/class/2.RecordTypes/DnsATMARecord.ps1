using namespace System.Text

class DnsATMARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |         FORMAT        |                       |
        +--+--+--+--+--+--+--+--+                       |
        /                   ATMADDRESS                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [ATMAFormat] $Format
    [string]     $ATMAAddress

    DnsATMARecord() : base() { }
    DnsATMARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }


    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Format = [ATMAFormat]$binaryReader.ReadByte()

        $length = $this.RecordDataLength - 1

        $this.ATMAAddress = switch ($this.Format) {
            'E164' {
                '+{0}' -f [string]::new($binaryReader.ReadChars($length))
                break
            }
            default {
                [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($length)).ToLower()
                break
            }
        }
    }

    hidden [string] RecordDataToString() {
        return $this.ATMAAddress
    }
}
