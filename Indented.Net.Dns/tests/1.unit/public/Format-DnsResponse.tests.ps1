Describe Format-DnsResponse {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Truncates messages to match the buffer width' {
        $message = InModuleScope @module {
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
            $message
        }

        (Format-DnsResponse $message -Section Answer).Length | Should -BeLessThan $host.UI.RawUI.BufferSize.Width
        (Format-DnsResponse $message -Section Answer).Length | Should -BeLessThan $message.Answer[0].ToString().Length
    }
}
