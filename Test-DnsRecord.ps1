using namespace System.IO

param (
    [String]$Name,

    [String]$RecordType = 'ANY',

    [Switch]$Tcp,

    [Switch]$Full
)

& (Join-Path $psscriptroot 'indented.net.dns\test\2.integration\script\Start-NameServer.ps1')

if (-not $Name.EndsWith('.')) {
    $Name = ('{0}.default.indented.co.uk.' -f $Name).TrimStart('.')
}

$path = Join-Path $psscriptroot 'Indented.Net.Dns'
'enum', 'class' | ForEach-Object {
    Get-ChildItem (Join-Path $path $_) -Filter *.ps1 -Recurse -File | ForEach-Object {
        . $_.FullName
    }
}

$dnsMessage = [DnsMessage]::new(
    $Name,
    $RecordType,
    'IN'
)
$dnsMessage.SetEDnsBufferSize()
$dnsMessage.SetAcceptDnsSec()

$dnsClient = [DnsClient]::new($Tcp.IsPresent, $false)
$dnsClient.SendQuestion($dnsMessage, '127.0.0.1', 1053)
$message = $dnsClient.ReceiveBytes()

Write-Host 'Message Hexadecimal'
Write-Host '==================='
Write-Host

($message | ForEach-Object { '{0:X2}' -f $_ }) -join '' -split '(?<=\G.{60})' -replace '([0-9a-f]{2})', '$1 ' | Write-Host

Write-Host
Write-Host 'Message Bytes'
Write-Host '============='
Write-Host

($message | ForEach-Object { $_.ToString().PadLeft(4) }) -join '' -split '(?<=\G.{88})' | Write-Host

$binaryReader = [EndianBinaryReader][MemoryStream]$message

$header = [DnsHeader]$binaryReader
$header | Format-List | Out-String | Write-Host

if ($header.QuestionCount -gt 0) {
    Write-Host 'Question'
    Write-Host '========'

    for ($i = 0; $i -lt $header.QuestionCount; $i++) {
        [DnsQuestion]$binaryReader | Format-List | Out-String | Write-Host
    }
}

if ($header.AnswerCount -gt 0) {
    Write-Host 'Answer'
    Write-Host '======'

    for ($i = 0; $i -lt $header.AnswerCount; $i++) {
        $answer = [DnsResourceRecord]::Parse($binaryReader)
        $answer | Format-List | Out-String | Write-Host

        $null = $binaryReader.BaseStream.Seek(-$answer.RecordDataLength, 'Current')
        $bytes = $binaryReader.ReadBytes($answer.RecordDataLength)

        Write-Host 'Answer Hexadecimal'
        Write-Host '=================='
        Write-Host

        ($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join '' -split '(?<=\G.{60})' -replace '([0-9a-f]{2})', '$1 ' | Write-Host

        Write-Host
        Write-Host 'Answer Bytes'
        Write-Host '============'
        Write-Host

        ($bytes | ForEach-Object { $_.ToString().PadLeft(4) }) -join '' -split '(?<=\G.{88})' | Write-Host

        Write-Host
        Write-Host 'Answer Base64'
        Write-Host '============='
        Write-Host
        [Convert]::ToBase64String($bytes) | Write-Host

        Write-Host
        Write-Host 'Answer ToString'
        Write-Host '==============='
        Write-Host
        Write-Host $answer.RecordDataToString()
        Write-Host
    }
}

if ($header.AuthorityCount -gt 0) {
    Write-Host 'Authority'
    Write-Host '========='

    for ($i = 0; $i -lt $header.AuthorityCount; $i++) {
        $authority = [DnsResourceRecord]::Parse($binaryReader)
        $authority | Format-List | Out-String | Write-Host

        $null = $binaryReader.BaseStream.Seek(-$authority.RecordDataLength, 'Current')
        $bytes = $binaryReader.ReadBytes($authority.RecordDataLength)

        Write-Host 'Authority Hexadecimal'
        Write-Host '====================='
        Write-Host

        ($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join '' -split '(?<=\G.{60})' -replace '([0-9a-f]{2})', '$1 ' | Write-Host

        Write-Host
        Write-Host 'Authority Bytes'
        Write-Host '==============='
        Write-Host

        ($bytes | ForEach-Object { $_.ToString().PadLeft(4) }) -join '' -split '(?<=\G.{88})' | Write-Host

        Write-Host
        Write-Host 'Authority Base64'
        Write-Host '================'
        Write-Host
        [Convert]::ToBase64String($bytes) | Write-Host

        Write-Host
        Write-Host 'Authority ToString'
        Write-Host '=================='
        Write-Host
        Write-Host $authority.RecordDataToString()
        Write-Host
    }
}

if ($header.AdditionalCount -gt 0) {
    Write-Host 'Additional'
    Write-Host '=========='

    for ($i = 0; $i -lt $header.AdditionalCount; $i++) {
        $additional = [DnsResourceRecord]::Parse($binaryReader)
        $additional | Format-List | Out-String | Write-Host

        $null = $binaryReader.BaseStream.Seek(-$additional.RecordDataLength, 'Current')
        $bytes = $binaryReader.ReadBytes($additional.RecordDataLength)

        Write-Host 'Additional Hexadecimal'
        Write-Host '======================'
        Write-Host

        ($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join '' -split '(?<=\G.{60})' -replace '([0-9a-f]{2})', '$1 ' | Write-Host

        Write-Host
        Write-Host 'Additional Bytes'
        Write-Host '================'
        Write-Host

        ($bytes | ForEach-Object { $_.ToString().PadLeft(4) }) -join '' -split '(?<=\G.{88})' | Write-Host

        Write-Host
        Write-Host 'Additional Base64'
        Write-Host '================='
        Write-Host
        [Convert]::ToBase64String($bytes) | Write-Host

        Write-Host
        Write-Host 'Additional ToString'
        Write-Host '==================='
        Write-Host
        Write-Host $additional.RecordDataToString()
        Write-Host
    }
}

Write-Host 'Dig Answer'
Write-Host '=========='
Write-Host

$response = & (Join-Path $psscriptroot 'Indented.Net.Dns\test\2.integration\bin\dig.exe') @(
    $Name
    $RecordType
    @('+short', $null)[$Full.IsPresent]
    '+dnssec'
    '-p' , 1053
    '@127.0.0.1'
) | Out-String

Write-Host $response