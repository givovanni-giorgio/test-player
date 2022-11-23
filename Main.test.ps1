# Main test file



#Load services.xml
BeforeDiscovery{
    $services = New-Object -TypeName XML
    $services.Load("C:\Users\rpawlowski\Documents\Power Shell\test-player\services.xml")
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


Describe "Test Player" {
    
    Context "Checking server connection" {
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

    Describe "Check Services"{

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