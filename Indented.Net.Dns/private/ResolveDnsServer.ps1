using namespace System.Management.Automation

function ResolveDnsServer {
    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # The name or IP address of a DNS server to use.
        [string]$ComputerName,

        # Whether or not IPv6 will be used.
        [switch]$IPv6
    )

    $ipAddress = [IPAddress]::Any
    if ([IPAddress]::TryParse($ComputerName, [ref]$ipAddress)) {
        return $ipAddress
    } else {
        if ($IPv6) {
            $serverRecordType = [RecordType]::AAAA
        } else {
            $serverRecordType = [RecordType]::A
        }

        if ($cachedServer = Get-InternalDnsCacheRecord -Name $ComputerName -RecordType $ServerRecordType) {
            Write-Debug ('Resolve-DnsServer: Cache: Using Server ({0}) from cache.' -f $ComputerName)

            return $cachedServer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress
        } else {
            $dnsResponse = Get-Dns -Name $ComputerName -RecordType $ServerRecordType

            if ($dnsResponse.Answer) {
                $ipAddress = $dnsResponse.Answer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress

                Write-Debug ('Resolve-DnsServer: Cache: Adding Server ({0}) to cache.' -f $ComputerName)
                $dnsResponse.Answer | Add-InternalDnsCacheRecord

                return $ipAddress
            }
        }
    }

    $errorRecord = [ErrorRecord]::new(
        [ArgumentException]::new('Unable to find an IP address for the specified name server ({0})' -f $ComputerName),
        'ArgumentException',
        [ErrorCategory]::InvalidArgument,
        $ComputerName
    )
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}
