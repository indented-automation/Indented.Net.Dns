using namespace Indented.IO
using namespace Indented.Net.Dns

class DnsSIGRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 TYPE COVERED                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |         LABELS        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 ORIGINAL TTL                  |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |             SIGNATURE EXPIRATION              |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |              SIGNATURE INCEPTION              |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    KEY TAG                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                 SIGNER'S NAME                 /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   SIGNATURE                   /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2535.txt
        http://www.ietf.org/rfc/rfc2931.txt
    #>

    [RecordType]          $RecordType = [RecordType]::SIG
    [DnsRecordType]       $TypeCovered
    [EncryptionAlgorithm] $Algorithm
    [Byte]                $Labels
    [UInt32]              $OriginalTTL
    [DateTime]            $SignatureExpiration
    [DateTime]            $SignatureInception
    [UInt16]              $KeyTag
    [String]              $SignersName
    [String]              $Signature

    DnsSIGRecord() : base() { }
    DnsSIGRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.TypeCovered = $binaryReader.ReadUInt16($true)
        $this.Algorithm = $binaryReader.ReadByte()
        $this.Labels = $binaryReader.ReadByte()
        $this.OriginalTTL = $binaryReader.ReadUInt32($true)
        $this.SignatureExpiration = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt32($true))
        $this.SignatureInception = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt32($true))
        $this.KeyTag = $binaryReader.ReadUInt16($true)

        $length = 0
        $this.SignersName = $binaryReader.ReadDnsDomainName([Ref]$length)
        $this.Signature = [Convert]::ToBase64String($binaryReader.ReadBytes($this.RecordDataLength - 18 - $length))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3} {4} {5} {6} {7} {8}' -f @(
            $this.TypeCovered
            [Byte]$this.Algorithm
            $this.Labels
            $this.OriginalTTL
            $this.SignatureExpiration.ToString('yyyyMMddHHmmss')
            $this.SignatureInception.ToString('yyyyMMddHHmmss')
            $this.KeyTag
            $this.SignersName
            $this.Signature -split '(?<=\G.{56})' -join ' '
         )
    }

    [String] ToLongString() {
        return (@(
            '{0} {1} {3} ( ; type-cov={0}, alg={2}, labels={3}'
            '    {4,-16} ; OriginalTTL'
            '    {5,-16} ; Signature expiration ({6})'
            '    {7,-16} ; Signature inception ({8})'
            '    {9,-16} ; Key identifier'
            '    {10,-16} ; Signer'
            '    {11,-16} ; Signature'
            ')'
         ) -join "`n") -f @(
            $this.TypeCovered
            [Byte]$this.Algorithm
            $this.Algorithm
            $this.Labels
            $this.OriginalTTL
            $this.SignatureExpiration.ToString('yyyyMMddHHmmss')
            $this.SignatureExpiration
            $this.SignatureInception.ToString('yyyyMMddHHmmss')
            $this.SignatureInception
            $this.KeyTag
            $this.SignersName
            $this.Signature -split '(?<=\G.{56})' -join ' '
         )
    }
}