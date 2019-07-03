using namespace System.IO

param (
    [String]$Name,

    [String]$RecordType = 'ANY',

    [Switch]$Tcp,

    [Switch]$Full
)

if (-not $Name.EndsWith('.')) {
    $Name = ('{0}.test.indented.co.uk.' -f $Name).TrimStart('.')
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