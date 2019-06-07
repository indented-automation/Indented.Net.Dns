function New-DnsPrimaryZone {
    [CmdletBinding()]
    param (
        [String]$Name,

        [String]$ResponsiblePerson,

        [Parameter(ParameterSetName = 'FileBasedZone')]
        [String]$FileName = ('{0}.dns' -f $Name),

        [Parameter(ParameterSetName = 'FileBasedZone')]
        [String]$LoadExisting

        [Parameter(ParameterSetName = 'ADIntegrated')]
    )
}