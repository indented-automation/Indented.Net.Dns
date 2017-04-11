using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsResourceRecord {
    # .SYNOPSIS
    #   Read common DNS resource record fields from a byte stream.
    # .DESCRIPTION
    #   Reads a byte array in the following format:
    #
    #                                   1  1  1  1  1  1
    #     0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                      NAME                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      TYPE                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     CLASS                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      TTL                      |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   RDLENGTH                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
    #    /                     RDATA                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [CmdletBinding()]
    [OutputType('Indented.Net.Dns.ResourceRecord')]
    param(
        # A binary reader.
        [Parameter(Mandatory = $true)]
        [EndianBinaryReader]$BinaryReader
    )

    # Need a better control for this one.
    if ($Script:IndentedDnsTCEndFound) {
        # Return $null, cannot read past the end of a truncated packet.
        return 
    }

    $resourceRecord = [PSCustomObject]@{
        Name             = ''
        TTL              = [UInt32]0
        RecordClass      = [RecordClass]::IN
        RecordType       = [RecordType]::Empty
        RecordDataLength = 0
        RecordData       = ''
    } | Add-Member -TypeName 'Indented.Net.Dns.ResourceRecord' -PassThru

    # Property: Name
    $resourceRecord.Name = ConvertToDnsDomainName $BinaryReader

    # Test whether or not the response is complete enough to read basic fields.
    if ($BinaryReader.BaseStream.Capacity -lt ($BinaryReader.BaseStream.Position + 10)) {
        # Set a variable to globally track the state of the packet read.
        $Script:IndentedDnsTCEndFound = $true
        
        # Return what we know.
        return $resourceRecord    
    }

    # Property: RecordType
    $resourceRecord.RecordType = $BinaryReader.ReadUInt16($true)
    if ([Enum]::IsDefined([RecordType], $ResourceRecord.RecordType)) {
        $resourceRecord.RecordType = [RecordType]$ResourceRecord.RecordType
    } else {
        $resourceRecord.RecordType = 'UNKNOWN ({0})' -f $resourceRecord.RecordType
    }

    # Property: RecordClass
    if ($resourceRecord.RecordType -eq [RecordType]::OPT) {
        $resourceRecord.RecordClass = $BinaryReader.ReadUInt16($true)
    } else {
        $resourceRecord.RecordClass = [RecordClass]$BinaryReader.ReadUInt16($true)
    }

    # Property: TTL
    $resourceRecord.TTL = $BinaryReader.ReadUInt32($true)
    # Property: RecordDataLength
    $resourceRecord.RecordDataLength = $BinaryReader.ReadUInt16($true)

    # Method: ToString
    $ResourceRecord | Add-Member ToString -MemberType ScriptMethod -Force -Value {
        return '{0} {1} {2} {3} {4}' -f $this.Name.PadRight(29, ' '),
                                        $this.TTL.ToString().PadRight(10, ' '),
                                        $this.RecordClass.ToString().PadRight(5, ' '),
                                        $this.RecordType.ToString().PadRight(5, ' '),
                                        $this.RecordData
    }

    # Mark the beginning of the RecordData
    $BinaryReader.SetMarker()

    $params = @{
        BinaryReader = $BinaryReader
        ResourceRecord = $resourceRecord
    }

    # Test whether or not the stream is complete enough to return the resource record.
    if ($BinaryReader.BaseStream.Capacity -lt ($BinaryReader.BaseStream.Position + $resourceRecord.RecordDataLength)) {
        $Script:DnsTCEndFound = $true

        return $resourceRecord
    }

    # Create appropriate properties for each record type
    if ($resourceRecord.RecordType -like 'UNKNOWN*') {
        ReadDnsUnknownRecord @params
    } else {
        $resourceRecord | Add-Member -TypeName ('Indented.Net.Dns.{0}Record' -f $resourceRecord.RecordType)

        $recordParser = 'ReadDns{0}Record' -f $resourceRecord.RecordType
        & $recordParser @params
    }

    return $resourceRecord
}