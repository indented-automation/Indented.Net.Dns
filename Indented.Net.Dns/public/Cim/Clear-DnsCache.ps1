function Clear-DnsCache {
    <#
    .SYNOPSIS
        Clear the DNS Cache on the specified server.
    .DESCRIPTION
        Clear-DnsCache uses the WMI class MicrosoftDNS_Cache to clear the DNS Cache on the specified server.
    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ComputerName')]
    param (
        # Clear the DNS cache on the specified server. By default cache on the current server DNS cache is cleared.
        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ComputerName')]
        [String[]]$ComputerName,

        # Clear the DNS Cache a DNS server using the specified CIM sessions.
        [Parameter(Mandatory, ParameterSetName = 'CimSession')]
        [CimSession[]]$CimSession
    )

    process {
        $params = @{
            MethodName = 'ClearCache'
            ClassName  = 'MicrosoftDNS_Cache'
            Namespace  = 'root/MicrosoftDNS'
        }
        if ($pscmdlet.ContainsKey($pscmdlet.ParameterSetName)) {
            $params.Add(
                $pscmdlet.ParameterSetName,
                $psboundparameters[$pscmdlet.ParameterSetName]
            )
        }
        if ($pscmdlet.ShouldProcess('Clearing DNS server cache')) {
            Invoke-CimMethod @params
        }
    }
}
