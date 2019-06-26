
        if ($Version) {
            # RFC 4892 (http://www.ietf.org/rfc/rfc4892.txt)
            $Name = "version.bind."
            $RecordType = [RecordType]::TXT
            $RecordClass = [RecordClass]::CH
        }