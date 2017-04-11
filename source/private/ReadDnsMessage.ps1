function ReadDnsMessage {
    # .SYNOPSIS
    #   Read a DNS message from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    HEADER                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   QUESTION                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    ANSWER                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   AUTHORITY                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  ADDITIONAL                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .PARAMETER Message
    #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS message.
    #
    #   If a binary reader is not passed as an argument an empty DNS message is returned.
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass
    #     14/01/2015 - Chris Dent - Refactored to fit in Indented.DnsResolver.

    [OutputType('Indented.Net.Dns.Message')]
    param(
        [Parameter(Mandatory = $true)]
        [PSTypeName('Indented.Net.Sockets.Response')]
        $Message
    )

    $stream = New-Object MemoryStream($Message.Data)
    $binaryReader = New-Object EndianBinaryReader($stream)

    $dnsMessage = NewDnsMessage
    $dnsMessage.Question = @()
    $dnsMessage.Size = $Message.Data.Length
    $dnsMessage.Server = $Message.RemoteEndPoint.Address

    $dnsMessage.Header = ReadDnsMessageHeader $binaryReader

    for ($i = 0; $i -lt $dnsMessage.Header.QDCount; $i++) {
        $dnsMessage.Question += ReadDnsMessageQuestion $binaryReader
    }
    for ($i = 0; $i -lt $dnsMessage.Header.ANCount; $i++) {
        $dnsMessage.Answer += ReadDnsResourceRecord $binaryReader
    }
    for ($i = 0; $i -lt $dnsMessage.Header.NSCount; $i++) {
        $dnsMessage.Authority += ReadDnsResourceRecord $binaryReader
    }
    for ($i = 0; $i -lt $dnsMessage.Header.ARCount; $i++) {
        $dnsMessage.Additional += ReadDnsResourceRecord $binaryReader
    }

    return $dnsMessage
}