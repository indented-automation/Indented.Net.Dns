#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

Describe Search-Dns -Tag Integration {
    BeforeAll {
        $defaultParams = @{
            Name       = 'www.indented.co.uk.'
            ZoneName   = 'indented.co.uk.'
            RecordType = 'CNAME'
        }
    }

    It 'Returns results from each name server' {
        $nsRecords = Get-Dns -Name $defaultParams.ZoneName -RecordType NS

        @(Search-Dns @defaultParams -Timeout 10).Count | Should -Be $nsRecords.Header.AnswerCount
    }
}