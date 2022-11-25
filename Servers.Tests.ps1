Describe "Test servers." {
    BeforeDiscovery{
        $servers = New-Object -TypeName XML
        $servers.Load(".\servers.xml")
        $server = $Servers.Servers.Server.DomainName
    }
    

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