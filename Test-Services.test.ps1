
<#
BeforeDiscovery{
    $Services = Get-Content -Path .\Services.txt
}


Describe "Check $(hostname) "{
    Context "Checking configuration of services" -Foreach $Services {
        It "<_> service should be installed"{
            $Name = Get-Service $_ | Select-Object Name -ExpandProperty Name
            $Name | Should -Be $_.Name
        }
}
}

#>

<#
$Services = [PSCustomObject]@{
    Services = @{Installed = "NMF.Service","NMF.Locker","SignioClientService","TabletInputService","wuauserv"},
    @{Running = "NMF.Service","NMF.Locker"},
    @{Disabled = "SignioClientService","wuauserv"}
}

Describe "Check $(hostname)"{
    Context "Services"{
        BeforeEach{
            $Installed = $($Services.Services.Installed)
            $Running = $($Services.Services.Running)
            $Disabled = $($Services.Services.Disabled) 
        }
            It "<_> is installed" -ForEach $Installed  {
                 (Get-Service $_ -ErrorAction SilentlyContinue).Status | Should -BeTrue -Because "Service does not exist"
        }
    }
}

#>



BeforeDiscovery{
    $Path = "C:\Users\rpawlowski\Documents\Power Shell\Xml\Services.xml"
    #$Path = 'C:\Users\user\Documents\Services.xml'
    $xml = New-Object -TypeName XML
    $xml.Load($Path)
}

BeforeDiscovery {
    $services           =  $xml.Player.Services.Service.Name
    $servicesStatusUp   = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name -ExpandProperty Name)
    $servicesStatusDown = ($xml.Player.Services.Service | Where-Object {$_.Status -eq "Stopped"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPAuto= ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Automatic"} | Select-Object Name -ExpandProperty Name)
    $servicesStartUPDis = ($xml.Player.Services.Service | Where-Object {$_.StartupType -eq "Disabled"} | Select-Object Name -ExpandProperty Name)

}

BeforeDiscovery{
    $disks      = $xml.Player.Disks.Disk
}

BeforeDiscovery{
    $volumes    = $xml.Player.Volumes.Volume
}

BeforeDiscovery{
    $tvInstaller = $xml.Player.TeamViewer.Installer
    $tvPath      = $xml.Player.TeamViewer.TeamViewerPath
}




Describe "Check player $(hostname)"{
    Context "Check Windows Licensing "{
        It "Operating system should be activated"{
            $status =  Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object Description, LicenseStatus
            $status.LicenseStatus | Should -Be "1"
        }
    }
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
    Context "Check Disk and Volumes" {
        It "Disk $($disks.Name) should be healthy" -foreach $disks {
            $status = $_.HealthStatus
            $status | Should -Be "Healthy"
            Start-Sleep 1
        }
        It "Volume should be healthy $($volumes.Name)" -Foreach $volumes {
            $status = $_.HealthStatus
            $status | Should -Be "Healthy"
            Start-Sleep 1
        }
    Context "Check TeamViewer" {
        It "TeamViewer installator must be on disk" {
            $tvPath.Path | Should -Not -BeNullOrEmpty
            Start-Sleep 1
        }
        It "TeamViewer service must be running" {
            $tvInstaller.Status | Should -Be "Running"
            Start-Sleep 1
        }
        It "TeamViewer Stat-up must be set to automatic"{
            $tvInstaller.StartUPType | Should -Be "Automatic"
            Start-Sleep 1
        }
    }
    }
    Context "Check internet and server connection" {
        It "Check weather loopback (127.0.0.1) is pingable " {
            $result = (Test-Connection "127.0.0.1" -Quiet -ErrorAction Stop)
            $result | Should -BeTrue
        }
        It "Check weather www.google.com is pingable " {
                $result = (Test-Connection "www.google.com" -Quiet)
                $result | Should -Be $true
        }
        It  "Check DNS resolution <_> (Ping global DNS)" -foreach "8.8.8.8","8.8.4.4" {    #If there is a problem websites do not load but are pingable
                $result = (Test-Connection $_ -Quiet)
                $result | Should -BeTrue
        }
        It  "Check DNS resolution <_> (Domain do IP resolution)" -foreach "studio.signio.pl","www.google.com" {    #If there is a problem websites do not load but are pingable
                $result = (Test-Connection $_ -Quiet)
                $result | Should -BeTrue -Because "There might be problem with the DNS."
        }
    }
}




<#

  Unlicensed        = 0
  Licensed          = 1
  OBBGrace          = 2
  OOTGrace          = 3
  NonGenuineGrace   = 4
  Notification      = 5

#>