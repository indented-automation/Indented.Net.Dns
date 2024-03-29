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

    [UInt16]              $Flags
    [KEYProtocol]         $Protocol
    [EncryptionAlgorithm] $Algorithm
    [string]              $PublicKey

    DnsRKEYRecord() : base() { }
    DnsRKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Flags = $binaryReader.ReadUInt16($true)
        $this.Protocol = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $keyLength = $this.RecordDataLength - 4
        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($keyLength))
    }

    hidden [string] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.Flags
            $this.Protocol
            $this.Algorithm
            $this.PublicKey -split '(?<=\G.{56})' -join ' '
        )
    }
}
