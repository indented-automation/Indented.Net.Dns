using namespace Indented
using namespace Indented.Net.Dns
using namespace System.Text

function NewDnsSOARecord {
    # .SYNOPSIS
    #   Create a new SOA record instance for use with IXFR queries.
    # .DESCRIPTION
    #   Modified / simplified SOA record structure for executing IXFR transfers. 
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      NAME                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      TYPE                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     CLASS                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      TTL                      |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   RDLENGTH                    |  
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     MNAME                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     RNAME                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    SERIAL                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    REFRESH                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     RETRY                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    EXPIRE                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    MINIMUM                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.  

    [OutputType('Indented.Net.Dns.SOARecord')]
    param(
        # Name is passed into this command as an optional aesthetic value. 
        #
        # All Name values (Name, NameServer and ResponsiblePerson) are referenced using a message compression flag with the offset set to 12, the name used in the Question.
        [String]$Name = '.',

        # A serial number to pass with the IXFR request.
        [Parameter(Mandatory = $true)]
        [UInt32]$SerialNumber
    )

    $resourceRecord = [PSCustomObject]@{
        Name              = $Name
        TTL               = 0
        RecordClass       = [RecordClass]::IN
        RecordType        = [RecordType]::SOA
        RecordDataLength  = 24
        NameServer        = $Name
        ResponsiblePerson = $Name
        Serial            = $SerialNumber
        Refresh           = 0
        Retry             = 0
        Expire            = 0
        MinimumTTL        = 0
    } | Add-Member -TypeName 'Indented.Net.Dns.ResourceRecord' -PassThru |
        Add-Member -TypeName 'Indented.Net.Dns.SOARecord' -PassThru

    # Property: RecordData
    $resourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $stringBuilder = New-Object StringBuilder
        $null = $stringBuilder.AppendLine('{0} {1} (')
        $null = $stringBuilder.AppendLine('    {2} ; serial')
        $null = $stringBuilder.AppendLine('    {3} ; refresh')
        $null = $stringBuilder.AppendLine('    {4} ; retry')
        $null = $stringBuilder.AppendLine('   {5} ; expire')
        $null = $stringBuilder.AppendLine('    {6} ; minimum ttl')
        $null = $stringBuilder.AppendLine(')')

        $stringBuilder.ToString() -f
            $this.NameServer,
            $this.ResponsiblePerson,
            $this.Serial.ToString().PadRight(10, ' '),
            $this.Refresh.ToString().PadRight(10, ' '),
            $this.Retry.ToString().PadRight(10, ' '),
            $this.Expire.ToString().PadRight(10, ' '),
            $this.MinimumTTL.ToString().PadRight(10, ' ')
    }

    # Method: ToByte
    $resourceRecord | Add-Member ToByte -MemberType ScriptMethod -Value {
        $Bytes = New-Object Byte[] 36

        # Property: Name
        $Bytes[0] = 0xC0; $Bytes[1] = 0x0C
        # Property: RecordType
        $Bytes[3] = 0x06;
        # Property: RecordClass
        $Bytes[5] = 0x01;
        # Property: RecordDataLength
        $Bytes[11] = 0x18;
        # Property: NameServer
        $Bytes[12] = 0xC0; $Bytes[13] = 0x0C
        # Property: ResponsiblePerson
        $Bytes[14] = 0xC0; $Bytes[15] = 0x0C
        # Property: SerialNumber
        $SerialBytes = [EndianBitConverter]::GetBytes($this.Serial, $true)
        [Array]::Copy($serialBytes, 0, $bytes, 16, 4)

        return ,$bytes
    }

    return $resourceRecord
}