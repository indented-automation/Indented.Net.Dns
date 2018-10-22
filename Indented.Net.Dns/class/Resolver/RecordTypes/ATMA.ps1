using namespace System.Text

class ATMA : DnsResourceRecord {
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
    [String]     $ATMAAddress

    ATMA() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Format = [ATMAFormat]$binaryReader.ReadByte()
        
        $length = $this.RecordDataLength - 1

        $address = [StringBuilder]::new()
        switch ($this.Format) {
            'AESA' { 
                $address.Append($binaryReader.ReadChars($length))
                break
            }
            'E164' {
                for ($i = 0; $i -lt $length; $i++) {
                    if ($i -in 3, 6) {
                        $null = $address.Append('.')
                    }
                    $null = $address.Append($binaryReader.ReadChar())
                }
                break
            }
            'NSAP' {
                for ($i = 0; $i -lt $length; $i++) {
                    if ($i -in 1, 3, 13, 19) {
                        $null = $address.Append('.')
                    }
                    $null = $address.AppendFormat('{0:X2}', $binaryReader.ReadByte())
                }
                break
            }
        }
        $this.ATMAAddress = $address.ToString()
    }

    [String] RecordDataToString() {
        return $this.ATMAAddress
    }
}