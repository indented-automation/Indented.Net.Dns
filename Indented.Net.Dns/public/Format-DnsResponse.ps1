function Format-DnsResponse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [DnsMessage]$DnsMessage,

        [Parameter(Mandatory)]
        [String]$Section
    )

    $maximumLength = $host.UI.RawUI.BufferSize.Width - 15

    $recordStrings = if ($DnsMessage.$Section.Count -gt 0) {
        foreach ($resourceRecord in $DnsMessage.$Section) {
            $string = $resourceRecord.ToString()
            if ($string.Length -gt $maximumLength) {
                '{0}...' -f $string.Substring(0, $maximumLength - 4)
            } else {
                $string
            }
        }
    }

    $recordStrings -join "`n"
}