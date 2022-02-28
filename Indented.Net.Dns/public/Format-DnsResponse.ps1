function Format-DnsResponse {
    <#
    .SYNOPSIS
        Format a DNS message section for display.

    .DESCRIPTION
        Format a DNS message section for display.
    #>

    [CmdletBinding()]
    param (
        # The DnsMessage to format.
        [Parameter(Mandatory)]
        [DnsMessage]$DnsMessage,

        # The section to format and return as a string.
        [Parameter(Mandatory)]
        [string]$Section
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
