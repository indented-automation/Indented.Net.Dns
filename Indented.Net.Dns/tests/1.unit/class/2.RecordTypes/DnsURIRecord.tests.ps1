Describe DnsURIRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'AAoAFGh0dHBzOi8vd3d3LmlzYy5vcmcv'
            RecordData = '10 20 "https://www.isc.org/"'
        }
        @{
            Message    = 'AB4AKGh0dHBzOi8vd3d3LmlzYy5vcmcvSG9seUNvd1RoaXNTdXJlSXNBVmVyeUxvbmdVUklSZWNvcmRJRG9udEV2ZW5Lbm93V2hhdFNvbWVvbmVXb3VsZEV2ZXJXYW50V2l0aFN1Y2hBVGhpbmdCdXRUaGVTcGVjaWZpY2F0aW9uUmVxdWlyZXNUaGF0V2VzdXBwb3J0SXRTb0hlcmVXZUdvVGVzdGluZ0l0TGFMYUxhTGFMYUxhTGFTZXJpb3VzbHlUaG91Z2hXaHlXb3VsZFlvdUV2ZW5Db25zaWRlclVzaW5nQVVSSVRoaXNMb25nSXRTZWVtc0xpa2VBU2lsbHlJZGVhQnV0RW5oV2hhdEFyZVlvdUdvbm5hRG8v'
            RecordData = '30 40 "https://www.isc.org/HolyCowThisSureIsAVeryLongURIRecordIDontEvenKnowWhatSomeoneWouldEverWantWithSuchAThingButTheSpecificationRequiresThatWesupportItSoHereWeGoTestingItLaLaLaLaLaLaLaSeriouslyThoughWhyWouldYouEvenConsiderUsingAURIThisLongItSeemsLikeASillyIdeaButEnhWhatAreYouGonnaDo/"'
        }
        @{
            Message    = 'AB4AKA=='
            RecordData = '30 40 ""'
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsURIRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
