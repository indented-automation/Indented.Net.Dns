using namespace System.Collections.Generic

class DnsRKEYRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     FLAGS                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        PROTOCOL       |       ALGORITHM       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  PUBLIC KEY                   /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/html/draft-reid-dnsext-rkey-00
    #>

    [RecordType]          $RecordType = [RecordType]::RKEY
    [UInt16]              $Flags
    [KEYProtocol]         $Protocol
    [EncryptionAlgorithm] $Algorithm
    [String]              $PublicKey

    DnsRKEYRecord() : base() { }
    DnsRKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Flags = $binaryReader.ReadUInt16($true)
        $this.Protocol = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $keyLength = $this.RecordDataLength - 4
        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($keyLength))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} ( {3} )' -f @(
            $this.Flags
            [Byte]$this.Protocol
            [Byte]$this.Algorithm
            $this.PublicKey
        )
    }
}