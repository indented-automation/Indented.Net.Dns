using namespace System.Management.Automation

function Resolve-DnsServer {
    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # The name or IP address of a DNS server to use.
        [String]$Server,

        # Whether or not IPv6 will be used.
        [Switch]$IPv6
    )

    $ipAddress = [IPAddress]::Any
    if ([IPAddress]::TryParse($Server, [Ref]$ipAddress)) {
        return $ipAddress
    } else {
        if ($IPv6) {
            $serverRecordType = [RecordType]::AAAA
        } else {
            $serverRecordType = [RecordType]::A
        }

        if ($cachedServer = Get-InternalDnsCacheRecord -Name $Server -RecordType $ServerRecordType) {
            Write-Debug ('Resolve-DnsServer: Cache: Using Server ({0}) from cache.' -f $Server)

            return $cachedServer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress
        } else {
            $dnsResponse = Get-Dns -Name $Server -RecordType $ServerRecordType

            if ($dnsResponse.Answer) {
                $ipAddress = $dnsResponse.Answer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress

                Write-Debug ('Resolve-DnsServer: Cache: Adding Server ({0}) to cache.' -f $Server)
                $dnsResponse.Answer | Add-InternalDnsCacheRecord

                return $ipAddress
            }
        }
    }

    $errorRecord = [ErrorRecord]::new(
        [ArgumentException]::new('Unable to find an IP address for the specified name server ({0})' -f $Server),
        'ArgumentException',
        [ErrorCategory]::InvalidArgument,
        $Server
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
}