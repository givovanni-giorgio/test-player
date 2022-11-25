BeforeDiscovery {

    $teamviewer = New-Object -TypeName XML
    $teamviewer.Load(".\teamviewer.xml")
    $tvname     = $teamviewer.TeamViewer.Service.Name
    $tvstatus   = $teamviewer.TeamViewer.Service.Status
    $tvstartup   = $teamviewer.TeamViewer.Service.StartUPType
    $tvpath     = $teamviewer.TeamViewer.TeamViewerPath.Path

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
