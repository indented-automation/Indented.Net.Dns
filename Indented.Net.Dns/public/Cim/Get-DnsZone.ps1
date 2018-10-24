function Get-DnsZone {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("ZoneName", "ContainerName")]
        [String]$Name,

        [ZoneType]$ZoneType,

        [String]$Filter,

        [Parameter(ParameterSetName = 'ForwardOnly')]
        [Switch]$Forward,

        [Parameter(ParameterSetName = 'ReverseOnly')]
        [Switch]$Reverse,

        [String[]]$ComputerName,

        [CimSession[]]$CimSession
    )

    process {
        $wqlFilter = switch ($null) {
            { $psboundparameters.ContainsKey('Name') }     { 'ContainerName LIKE "{0}"' -f ($Name.Replace('*', '%')) }
            { $psboundparameters.ContainsKey('ZoneType') } { 'ZoneType={0}' -f [UInt32]$ZoneType }
            { $psboundparameters.ContainsKey('Filter') }   { $Filter }
            { $Forward }                                   { 'Reverse=FALSE' }
            { $Reverse }                                   { 'Reverse=TRUE' }
        }
        $wqlFilter = $wqlFilter -join ' AND '

        $params = @{
            ClassName = 'MicrosoftDNS_Zone'
            Namespace = 'root/MicrosoftDNS'
            Filter    = $wqlFilter
        }
        if ($psboundparameters.ContainsKey('CimSession')) {
            $params.Add('CimSession', $CimSession)
        } elseif ($psboundparameters.ContainsKey('ComputerName')) {
            $params.Add('ComputerName', $ComputerName)
        }

        Get-CimInstance @params
    }
}
