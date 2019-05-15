class DnsTXTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   TXT-DATA                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::TXT
    [String]     $Text

    DnsTXTRecord() : base() { }
    DnsTXTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Text = [String]::new([Char[]]$binaryReader.ReadBytes($this.RecordDataLength))
    }

    Hidden [String] RecordDataToString() {
        return $this.Text
    }
}



function ReadDnsTXTRecord {
    # .SYNOPSIS
    #   TXT record parser.
    # .DESCRIPTION

    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Text
    $ResourceRecord | Add-Member Text (ReadDnsCharacterString $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.Text
    }
}