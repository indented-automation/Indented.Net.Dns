if (Get-Process named -ErrorAction SilentlyContinue) {
    Write-Verbose 'Name server is already running.'
}

Split-Path $psscriptroot -Parent | Push-Location

if (-not (Test-Path 'bin\named.exe')) {
    if (-not (Test-Path bin)) {
        New-Item bin -ItemType Directory
    }

    $params = @{
        Uri     = 'https://downloads.isc.org/isc/bind9/9.14.3/BIND9.14.3.x64.zip'
        OutFile = 'bin\BIND9.zip'
    }
    Invoke-WebRequest @params
    $params = @{
        Path            = $params.OutFile
        DestinationPath = 'bin'
    }
    Expand-Archive @params
}

$argumentList = @(
    '-K', 'data'
    '-a', 'RSASHA512'
    '-b', '2048'
    '-3'
    '-f', 'KSK'
    'signed.indented.co.uk'
)
& 'bin\dnssec-keygen.exe' @argumentList 2>$null

$argumentList = @(
    '-K', 'data'
    '-a', 'RSASHA512'
    '-b', '2048'
    '-3'
    'signed.indented.co.uk'
)
& 'bin\dnssec-keygen.exe' @argumentList 2>$null

$params = @{
    FilePath     = 'bin\named.exe'
    ArgumentList = @(
        '-c'
        '"{0}"' -f (Join-Path $pwd -ChildPath 'data\named.conf')
        '-f'
    )
    WindowStyle  = 'Hidden'
}
Start-Process @params
Start-Sleep -Seconds 5

$argumentList = @(
    'signing'
    '-nsec3param', '1', '0', '10'
    '5053851B'
    'signed.indented.co.uk.'
)
& 'bin\rndc' @argumentList

Pop-Location