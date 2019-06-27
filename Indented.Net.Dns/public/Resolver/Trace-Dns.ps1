function Trace-Dns {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
        [CmdletBinding()]
        param ( )

        # Iterative searches
        #

        # if ($Iterative) {
        #     # Pick a random(ish) server from Root Hints
        #     $HintRecordSet = Get-InternalDnsCacheRecord -RecordType A -ResourceType Hint
        #     $Server = $HintRecordSet[(Get-Random -Minimum 0 -Maximum ($HintRecordSet.Count - 1))] | Select-Object -ExpandProperty IPAddress

        #     $NoError = $true; $NoAnswer = $true
        #     while ($NoError -and $NoAnswer) {
        #         $DnsResponse = Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -NoRecursion -Server $Server @GlobalOptions

        #         if ($DnsResponse.Header.RCode -ne [RCode]::NoError)  {
        #             $NoError = $false
        #         } else {
        #             if ($DnsResponse.Header.ANCount -gt 0) {
        #                 $NoAnswer = $false
        #             } elseif ($DnsResponse.Header.NSCount -gt 0) {
        #                 $Authority = $DnsResponse.Authority | Select-Object -First 1

        #                 # Attempt to match between Authority and Additional. No need to execute another lookup if we have the information.
        #                 $Server = $DnsResponse.Additional |
        #                     Where-Object { $_.Name -eq $Authority.Hostname -and $_.RecordType -eq [RecordType]::A } |
        #                     Select-Object -ExpandProperty IPAddress |
        #                     Select-Object -First 1
        #                 if ($Server) {
        #                     Write-Verbose "Get-Dns: Iterative query: Next name server IP: $Server"
        #                 } else {
        #                     $Server = $Authority[0].Hostname
        #                     Write-Verbose "Get-Dns: Iterative query: Next name server Name: $Server"
        #                 }
        #             }
        #         }

        #         # Return the response to the output pipeline
        #         $DnsResponse
        #     }
        # }
}