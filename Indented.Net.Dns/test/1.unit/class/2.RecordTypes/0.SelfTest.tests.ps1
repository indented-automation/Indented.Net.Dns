New-Module PesterEx -ScriptBlock {
    function BeforeDiscovery ([ScriptBlock] $ScriptBlock) {
        . $ScriptBlock
    }
} -PassThru | Import-Module -Force

Describe 'Record parser test suite self test' {
    BeforeDiscovery {
        $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
        $dnsRecordTypes = Get-ChildItem $moduleBase\class\*RecordTypes\Dns*Record.ps1 | ForEach-Object {
            @{
                ClassName  = $_.BaseName
                RecordType = $_.BaseName -replace '^Dns|Record$'
            }
        }

        $dnsRecordTypeTests = Get-ChildItem $psscriptroot -Filter Dns*.tests.ps1 | ForEach-Object {
            @{
                Name      = $_.Name
                ClassName = $_.BaseName -replace '\.tests$'
                Path      = $_.FullName
            }
        }
    }

    Context 'Test files' {
        It 'The class <ClassName> has a test suite' -TestCases $dnsRecordTypes {
            param (
                [String]$ClassName
            )

            Join-Path $psscriptroot ('{0}.tests.ps1' -f $ClassName) | Should -Exist
        }
    }

    Context 'Test file content' {
        It 'The test file <Name> has content' -TestCases $dnsRecordTypeTests {
            param (
                [String]$Name,

                [String]$Path
            )

            [System.Management.Automation.Language.Parser]::ParseFile(
                $Path,
                [Ref]$null,
                [Ref]$null
            ) | Should -Not -BeNullOrEmpty
        }

        It 'The test file <Name> has describe named <ClassName>' -TestCases $dnsRecordTypeTests {
            param (
                [String]$Name,

                [String]$ClassName,

                [String]$Path
            )

            try {
                [System.Management.Automation.Language.Parser]::ParseFile(
                    $Path,
                    [Ref]$null,
                    [Ref]$null
                ).Find(
                    {
                        param ( $ast )

                        $ast -is [System.Management.Automation.Language.CommandAst] -and
                        $ast.GetCommandName() -eq 'Describe'
                    },
                    $true
                ).CommandElements[1].Value | Should -Be $ClassName
            } catch {
                $false | Should -Be $ClassName
            }
        }

        It 'The test file <Name> includes Parser tests' -TestCases $dnsRecordTypeTests {
            param (
                [String]$Name,

                [String]$ClassName,

                [String]$Path
            )

            [System.Management.Automation.Language.Parser]::ParseFile(
                $Path,
                [Ref]$null,
                [Ref]$null
            ).Find(
                {
                    param ( $ast )

                    $ast -is [System.Management.Automation.Language.CommandAst] -and
                    $ast.GetCommandName() -eq 'It' -and
                    $ast.CommandElements[1].Value.StartsWith('Parses')
                },
                $true
            ) | Should -Not -BeNullOrEmpty
        }

        It 'The test file <Name> tests the parser for <ClassName>' -TestCases $dnsRecordTypeTests {
            param (
                [String]$Name,

                [String]$ClassName,

                [String]$Path
            )

            try {
                [System.Management.Automation.Language.Parser]::ParseFile(
                    $Path,
                    [Ref]$null,
                    [Ref]$null
                ).Find(
                    {
                        param ( $ast )

                        $ast -is [System.Management.Automation.Language.CommandAst] -and
                        $ast.GetCommandName() -eq 'It' -and
                        $ast.CommandElements[1].Value.StartsWith('Parses')
                    },
                    $true
                ).Find(
                    {
                        param ( $ast )

                        $ast -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                        $ast.Left.VariablePath.UserPath -eq 'resourceRecord'
                    },
                    $true
                ).Right.Expression.Expression.TypeName.Name | Should -Be $ClassName
            } catch {
                $false | Should -Be $ClassName
           }
        }
    }

    Context 'RecordType' {
        It 'The RecordType <RecordType> is valid' -TestCases $dnsRecordTypes {
            param (
                [String]$RecordType
            )

            InModuleScope -ModuleName Indented.Net.Dns -Parameters @{ RecordType = $RecordType } {
                param (
                    $RecordType
                )
                $value = [RecordType]::Unknown
                [RecordType]::TryParse($RecordType.ToUpper(), [Ref]$value)
            } | Should -BeTrue
        }

        It 'The class <ClassName> has RecordType set to <RecordType>' -TestCases $dnsRecordTypes {
            param (
                [String]$ClassName,

                [String]$RecordType
            )

            $instance = InModuleScope -ModuleName Indented.Net.Dns -Parameters @{ ClassName = $ClassName } {
                param (
                    $ClassName
                )

                ($ClassName -as [Type])::new()
            }

            if ($ClassName -eq 'DnsNSAPPTRRecord') {
                $instance.RecordType.ToString() | Should -Be 'NSAP-PTR'
            } else {
                $instance.RecordType.ToString() | Should -Be $RecordType
            }
        }
    }
}
