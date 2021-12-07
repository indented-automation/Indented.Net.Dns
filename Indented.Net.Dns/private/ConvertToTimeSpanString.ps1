function ConvertToTimeSpanString {
    <#
    .SYNOPSIS
        Converts a number of seconds to a string.
    .DESCRIPTION
        ConvertToTimeSpanString accepts values in seconds then uses integer division to represent that time as a string.

        ConvertToTimeSpanString accepts UInt32 values, overcoming the Int32 type limitation built into New-TimeSpan.

        The format below is used, omitting any values of 0:

        # weeks # days # hours # minutes # seconds
    .INPUTS
        System.UInt32
    .EXAMPLE
        ConvertToTimeSpanString 28800
    .EXAMPLE
        [UInt32]::MaxValue | ConvertToTimeSpanString
    .EXAMPLE
        86400, 700210 | ConvertToTimeSpanString
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        # A number of seconds as an unsigned 32-bit integer.
        [Parameter(Mandatory, ValueFromPipeline)]
        [UInt32]$Seconds
    )

    begin {
        # Time periods described in seconds
        $formats = [Ordered]@{
            week   = 604800
            day    = 86400
            hour   = 3600
            minute = 60
            second = 1
        }
    }

    process {
        $values = foreach ($key in $formats.Keys) {
            $remainder = $Seconds % $formats[$key]
            $value = ($Seconds - $Remainder) / $formats[$key]
            $Seconds = $remainder

            if ($value) {
                '{0} {1}{2}' -f @(
                    $value
                    $Key
                    ('', 's')[$value -gt 1]
                )
            }
        }
        return $values -join ' '
    }
}
