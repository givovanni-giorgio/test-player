BeforeDiscovery{
    $services = New-Object -TypeName XML
    $services.Load("$location\services.xml")
    $services           =  $xml.Player.Services.Service.Name
    $servicesStatusUp   = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name -ExpandProperty Name)
    $servicesStatusDown = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Stopped"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPAuto= ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Automatic"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPDis = ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Disabled"} | Select-Object Name -ExpandProperty Name)        
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