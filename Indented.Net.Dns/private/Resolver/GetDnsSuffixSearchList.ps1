        # Suffix search list

        # Used if:
        #
        # 1. The name does not end with '.' (root terminated).
        # 2. A search list has not been defined.
        #
        # Skipped if:
        #
        # 1. An Iterative query is being performed.
        # 2. A zone transfer is not being performed (AXFR or IXFR).
        # 3. NoSearchList has been set.
        #
        # Applies to both single-label and multi-label names.
        if ($NoSearchList -or $NSSearch -or $Iterative -or $ZoneTransfer -or $Name.EndsWith('.')) {
            $SearchList = ""
        } else {
            if (-not $SearchList) {
                # If a search list has not been passed using the SearchList parameter attempt to discover one.
                $SearchList = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Property DNSDomainSuffixSearchOrder |
                    Where-Object DNSDomainSuffixSearchOrder |
                    Select-Object -ExpandProperty DNSDomainSuffixSearchOrder |
                    ForEach-Object { "$_." }
                Write-Verbose "Get-Dns: SearchList: Automatically retrieved and set to $SearchList"
            }
                # If the name is multi-label allow it to be sent without a suffix.
            if ($Name -match '[^.]+\.[^.]+') {
                # Add an empty (root) SearchList item
                $SearchList += ""
            }
        }
        # For consistent operation now the search list has been set.
        if (-not $Name.EndsWith('.')) {
            $Name = '{0}.' -f $Name
        }