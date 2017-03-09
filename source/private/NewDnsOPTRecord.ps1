using namespace Indented
using namespace Indented.Net.Dns

function NewDnsOPTRecord {
    # .SYNOPSIS
    #   Creates a new OPT record instance for advertising DNSSEC support.
    # .DESCRIPTION
    #   Modified / simplified OPT record structure for advertising DNSSEC support. 
    #  
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+
    #    |         NAME          |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      TYPE                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |              MAXIMUM PAYLOAD SIZE             |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |    EXTENDED-RCODE     |        VERSION        |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                       Z                       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   RDLENGTH                    |  
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .OUTPUTS
    #   Indented.Net.Dns.OPTRecord
    # .LINK
    #   http://www.ietf.org/rfc/rfc2671.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([PSObject])]
    param( )
    
    $resourceRecord = [PSCustomObject]@{
        Name               = '.'
        RecordType         = [RecordType]::OPT
        MaximumPayloadSize = [UInt16]4096
        ExtendedRCode      = 0
        Version            = 0
        Z                  = [EDnsDNSSECOK]::DO
        RecordDataLength   = 0
    } | Add-Member -TypeName 'Indented.Net.Dns.ResourceRecord' -PassThru |
        Add-Member -TypeName 'Indented.Net.Dns.OPTRecord' -PassThru

    # Method: ToByte
    $ResourceRecord | Add-Member ToByte -MemberType ScriptMethod -Value {
        $bytes = New-Object Byte[] 11

        # Property: RecordType
        $bytes[2] = 0x29
        
        # Property: MaximumPayloadSize
        $maximumPayloadSizeBytes = [EndianBitConverter]::ToBytes($this.MaximumPayloadSize, $true)
        [Array]::Copy($maximumPayloadSizeBytes, 0, $bytes, 3, 2)
        
        # Property: Z - DO bit
        $bytes[7] = 0x80

        return ,$bytes
    }

    return $resourceRecord
}