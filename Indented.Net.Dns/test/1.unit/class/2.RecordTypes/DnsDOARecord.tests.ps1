InModuleScope Indented.Net.Dns {
    Describe DnsDOARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'SZYC0kmWAtIBCWltYWdlL2dpZkdJRjg5YSgAGQDjAgBmZmYAZpn///8zmczM//+ZzP8zZplmzP+ZzMzMzMwAmf////////////////////8h+QQBCgAPACwAAAAAKAAZAAAEx/CBSSuVNmuN9+xeaIEZKZ6Aia5cuz6wisofHNx4AIc09+TA227Tu/yCSB2xojomk8VU6UlVli6jatVFcmqTUtcHdzgMboNC4Zwrm3FYbMcrEJzreAE6b78x5Rc5dQMDg4VnhQIEaXp+f1IYXgGDBXVAeEhXKRhBhnUHggKgQS07kpN9BHl3faRLAGyhsYx6g0hNEqeosTeDdQSZm3O5SIZrAYnIdWsDwI5GNUmUfGyVq89/NkhqiAUEBUHeCLFE2l/nHrrnTxEAOw=='
                RecordData = '1234567890 1234567890 1 "image/gif" R0lGODlhKAAZAOMCAGZmZgBmmf///zOZzMz//5nM/zNmmWbM/5nMzMzMzACZ/////////////////////yH5BAEKAA8ALAAAAAAoABkAAATH8IFJK5U2a4337F5ogRkpnoCJrly7PrCKyh8c3HgAhzT35MDbbtO7/IJIHbGiOiaTxVTpSVWWLqNq1UVyapNS1wd3OAxug0LhnCubcVhsxysQnOt4ATpvvzHlFzl1AwODhWeFAgRpen5/UhheAYMFdUB4SFcpGEGGdQeCAqBBLTuSk30EeXd9pEsAbKGxjHqDSE0Sp6ixN4N1BJmbc7lIhmsBich1awPAjkY1SZR8bJWrz382SGqIBQQFQd4IsUTaX+ceuudPEQA7'
            }
            @{
                Message    = 'AAAAAAAAAAECAGh0dHBzOi8vd3d3LmlzYy5vcmcv'
                RecordData = '0 1 2 "" aHR0cHM6Ly93d3cuaXNjLm9yZy8='
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsDOARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
