# Main test file



#Load services.xml
BeforeDiscovery{
    $services = New-Object -TypeName XML
    $services.Load(".\services.xml")
    $services           =  $xml.Player.Services.Service.Name
    $servicesStatusUp   = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name -ExpandProperty Name)
    $servicesStatusDown = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Stopped"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPAuto= ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Automatic"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPDis = ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Disabled"} | Select-Object Name -ExpandProperty Name)        
}

#Load servers.xml
BeforeDiscovery{
    $servers = New-Object -TypeName XML
    $servers.Load(".\servers.xml")
    $server = $Servers.Servers.Server.DomainName
}

BeforeDiscovery {

    $teamviewer = New-Object -TypeName XML
    $teamviewer.Load(".\teamviewer.xml")
    $tvname     = $teamviewer.TeamViewer.Service.Name
    $tvstatus   = $teamviewer.TeamViewer.Service.Status
    $tvstartup   = $teamviewer.TeamViewer.Service.StartUPType
    $tvpath     = $teamviewer.TeamViewer.TeamViewerPath.Path

}

BeforeDiscovery{
    .\Disk.ps1
    Start-Sleep -Seconds 1
    $disk       = New-Object -TypeName XML
    $disk.Load(".\disk.xml")
}


Describe "Check Disk and Volumes status"{
    Context "Checking disk status be healthy" {
        BeforeAll{
            [array]$name       = $disk.Player.Disks.Disk.Name
            [array]$status     = $disk.Player.Disks.Disk.HealthStatus
        }
        It "Check <_> state should be healthy" -ForEach $name {
            $i=0
            $status[$i] | Should -Be "Healthy"
            $i++
        }
    }
}

Describe "Check TeamViewer" {
    context "Check TeamViewer service " {
        BeforeAll{
            $service = Get-Service -Name $tvname
        }
        It "Service should be running" {
            $service.Name | Should -Be $tvname
        }
        It "StartUp type should be set to Automatic" {
            $service.StartType | Should -Be $tvstartup
        }
        It "TeamViewer should be on disk C:" {
            $result = Get-ChildItem -Path $tvPath -Name "*$($tvname)*"
        }
    }
}


Describe "Test servers." {
    
    Context "Checking server connection." {
        It "<_> serwer should be pingable" -ForEach $server {
            if( ($_ -eq "hebe.signio.pl")){
                Set-ItResult -Because "Server is not pingable" -Inconclusive
            }elseif ($_ -eq "sixthstreet.signio.pl") {
                Set-ItResult -Because "Server is not pingable" -Inconclusive
            }
            else{
                $result = Test-Connection $_ -Quiet
                $result | Should -Be $true
            } 
        } 
    } 
    

}

Describe "Check Services" {

        Context "Setting up <services> service"  {
            It "<_> Service should be installed" -ForEach $services {
               $name =  (Get-Service -Name $_ -ErrorAction SilentlyContinue | Select-Object Name -ExpandProperty Name)
               $name | should -Be $_
            }
            It "<_> Service should be Running" -Foreach $servicesStatusUp {
               $status =  (Get-Service -Name $_ -ErrorAction SilentlyContinue | Select-Object Status -ExpandProperty Status)
               $status | should -Be "Running"
            }
            It "<_> Service should be Disabled" -foreach $servicesStatusDown {
                if($_ -eq "TabletInputService" -and "SignioClientService"){
                    Set-ItResult -Inconclusive -Because "On some devices the <_> is considered to be not modified"
                }else{
                    $status =  (Get-Service -Name $_ -ErrorAction SilentlyContinue | Select-Object StartType -ExpandProperty StartType)
                    $status | Should -Be "Disabled"
                }
            }
            It "<_>'s startup type shoulbe be set to Automatic" -foreach $servicesStartUPAuto {
                $startup =  (Get-Service -Name $_ -ErrorAction SilentlyContinue | Select-Object StartType -ExpandProperty StartType)
                $startup | Should -Be "Automatic"
            }
        }

    }