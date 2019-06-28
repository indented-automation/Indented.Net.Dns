using namespace System.IO

param (
    $Name,

    $RecordType
)

$Name = ('{0}.test.indented.co.uk.' -f $Name).TrimStart('.')

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

$dnsClient = [DnsClient]::new()
$dnsClient.SendQuestion($dnsMessage, '127.0.0.1', 1053)
$message = $dnsClient.ReceiveBytes()

$binaryReader = [EndianBinaryReader][MemoryStream]$message
$length = $message.Length

$header = [DnsHeader]$binaryReader
$header | Format-List | Out-String | Write-Host

$position = $binaryReader.BaseStream.Position
$bytes = $binaryReader.ReadBytes($length - $position)

Write-Host 'Hexadecimal'
Write-Host '==========='
Write-Host

($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join '' -split '(?<=\G.{60})' -replace '([0-9a-f]{2})', '$1 '

Write-Host
Write-Host 'Bytes'
Write-Host '====='
Write-Host

($bytes | ForEach-Object { $_.ToString().PadLeft(4) }) -join '' -split '(?<=\G.{88})'

Write-Host

$null = $binaryReader.BaseStream.Seek($position, 'Begin')

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
    }

    Write-Host 'Answer ToString'
    Write-Host '==============='
    Write-Host
    Write-Host $answer.RecordDataToString()
    Write-Host
}

if ($header.AuthorityCount -gt 0) {
    Write-Host 'Authority'
    Write-Host '========='

    for ($i = 0; $i -lt $header.AuthorityCount; $i++) {
        [DnsResourceRecord]::Parse($binaryReader) | Format-List | Out-String | Write-Host
    }
}

if ($header.AdditionalCount -gt 0) {
    Write-Host 'Additional'
    Write-Host '=========='

    for ($i = 0; $i -lt $header.AdditionalCount; $i++) {
        [DnsResourceRecord]::Parse($binaryReader) | Format-List | Out-String | Write-Host
    }
}

Write-Host 'Dig Answer'
Write-Host '=========='
Write-Host

$response = dig $RecordType $Name --% +short -p 1053 @127.0.0.1

Write-Host $response