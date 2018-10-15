using namespace System.Collections.Generic

function Get-DnsRecord {
    <#
    .SYNOPSIS
    .DESCRIPTION

    #>

    [CmdletBinding(DefaultParameterSetName = 'FromZone')]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('RecordName', 'OwnerName')]
        [String]$Name = '.*',

        [Parameter(Position = 1)]
        [Alias('Type')]
        [RecordType[]]$RecordType =  ([RecordType[]][List[Int]][Enum]::GetValues([CimRecordClass])),

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'FromZone')]
        [Alias('ContainerName')]
        [String]$ZoneName,

        [Parameter(Mandatory, ParameterSetName = 'FromCache')]
        [Switch]$Cache,

        [Parameter(Mandatory, ParameterSetName = 'FromRootHints')]
        [Switch]$RootHints,

        [Parameter(ParameterSetName = 'UsingSQL')]
        [String]$Filter = "NOT ContainerName LIKE '..%'",

        # Search for records on the specified server. By default cache on the current server DNS cache is cleared.
        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]]$ComputerName,

        # Search for records using the specified CIM sessions.
        [Parameter(Mandatory)]
        [CimSession[]]$CimSession
    )
    
    begin {
        $cimClasses = [CimRecordClass[]][List[Int]]$RecordType
    }

    process {
        $Filter = switch ($null) {
            { $Cache }     { 'ContainerName="..Cache"'; break }
            { $RootHints } { 'ContainerName="..RootHint"'; break }
            { $ZoneName }  { 'ContainerName="{0}"' -f $ZoneName; break }
            default        { $Filter }
        }

        foreach ($cimClass in $cimClasses) {
            $params = @{
                ClassName = $cimClass
                Namespace = 'root/MicrosoftDNS'
                Filter    = $Filter
            }
            if ($psboundparameters.ContainsKey('CimSession')) {
                $params.Add('CimSession', $CimSession)
            } elseif ($psboundparameters.ContainsKey('ComputerName')) {
                $params.Add('ComputerName', $ComputerName)
            }

            Get-CimInstance @params
        }
        # Regex NameRegEx = new Regex(Name, RegexOptions.IgnoreCase);
    }
}