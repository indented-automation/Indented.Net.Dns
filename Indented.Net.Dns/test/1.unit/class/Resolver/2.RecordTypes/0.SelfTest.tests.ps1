#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

$moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
if (-not $UseExisting) {
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

Describe 'Record parser test suite self test' {
    Context 'Test files' {
        BeforeAll {
            $testCases = Get-ChildItem $moduleBase\class\Resolver\*RecordTypes\Dns*Record.ps1 | ForEach-Object {
                @{ ClassName = $_.BaseName }
            }
        }

        It 'The class <ClassName> has a test suite' -TestCases $testCases {
            param (
                [String]$ClassName
            )

            Join-Path $psscriptroot ('{0}.tests.ps1' -f $ClassName) | Should -Exist
        }
    }

    Context 'Test file content' {
        BeforeAll {
            $testCases = Get-ChildItem $psscriptroot -Filter Dns*.tests.ps1 | ForEach-Object {
                @{ Name = $_.Name; ClassName = $_.BaseName -replace '\.tests$'; Path = $_.FullName }
            }
        }

        It 'The test file <Name> has content' -TestCases $testCases {
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

        It 'The test file <Name> has describe named <ClassName>' -TestCases $testCases {
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

        It 'The test file <Name> includes Parser tests' -TestCases $testCases {
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

        It 'The test file <Name> tests the parser for <ClassName>' -TestCases $testCases {
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

    InModuleScope Indented.Net.Dns {
        Context 'RecordType' {
            BeforeAll {
                $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
                $testCases = Get-ChildItem $moduleBase\class\Resolver\*RecordTypes\Dns*Record.ps1 | ForEach-Object {
                    @{ ClassName = $_.BaseName; RecordType = $_.BaseName -replace '^Dns|Record$' }
                }
            }

            It 'The RecordType <RecordType> is valid' -TestCases $testCases {
                param (
                    [String]$RecordType
                )

                $value = [RecordType]::Unknown
                [RecordType]::TryParse($RecordType.ToUpper(), [Ref]$value) | Should -BeTrue
            }

            It 'The class <ClassName> has RecordType set to <RecordType>' -TestCases $testCases {
                param (
                    [String]$ClassName,

                    [String]$RecordType
                )

                $instance = ($ClassName -as [Type])::new()
                $instance.RecordType.ToString() | Should -Be $RecordType
            }
        }
    }
}