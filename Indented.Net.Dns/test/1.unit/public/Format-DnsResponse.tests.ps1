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

InModuleScope Indented.Net.Dns {
    Describe Format-DnsResponse {
        It 'Truncates messages to match the buffer width' {
            $message = [DnsMessage]::new()
            $message.Header = [DnsHeader]::new()
            $message.Header.AnswerCount = 1
            $message.Answer = @(
                [DnsSOARecord]@{
                    Name              = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.'
                    Nameserver        = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.'
                    ResponsiblePerson = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.'
                }
            )
            $message.Answer[0].RecordData = $message.Answer[0].RecordDataToString()

            (Format-DnsResponse $message -Section Answer).Length | Should -BeLessThan $host.UI.RawUI.BufferSize.Width
            (Format-DnsResponse $message -Section Answer).Length | Should -BeLessThan $message.Answer[0].ToString().Length
        }
    }
}