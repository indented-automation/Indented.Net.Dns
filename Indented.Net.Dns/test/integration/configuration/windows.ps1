Install-Module xDnsServer

configuration msdns {
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xDnsServer

    node localhost {
        WindowsFeature 'DNS' {
            Ensure               = 'Present'
            Name                 = 'DNS'
            IncludeAllSubFeature = $true
        }

        WindowsFeature 'WINS' {
            Ensure               = 'Present'
            Name                 = 'WINS'
            IncludeAllSubFeature = $true
        }

        $zones = @(
        )
        File wins.example.dns {
            SourcePath      = 'c:\staging'
            DestinationPath = 'C:\Windows\System32\DNS'
            Recurse         = $true
            DependsOn       = "[WindowsFeature]DNS"
        }

        xDnsServerPrimaryZone wins.example.dns {
            Ensure    = 'Present'
            Name      = 'wins.example'
            ZoneFile  = 'wins.example.dns'
            DependsOn = "[File]wins.example.dns"
        }

    }
}

msdns -Path .

Start-DscConfiguration -Path .\msdns -Wait -Verbose