Push-Location 'Indented.Net.Dns\test\2.integration'

if (-not (Test-Path 'bin\named.exe')) {
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

$params = @{
    FilePath     = 'bin\named.exe'
    ArgumentList = @(
        '-c'
        '"{0}"' -f (Join-Path $pwd 'data\named.conf')
        '-f'
    )
    PassThru     = $true
}
Start-Process @params

Pop-Location