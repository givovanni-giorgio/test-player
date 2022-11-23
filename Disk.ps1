$Path = "C:\Users\rpawlowski\Documents\Power Shell\test-player\disk.xml"

#Use XMLTextWriter to create the XML File 

$xmlWriter = New-Object System.Xml.XmlTextWriter($Path,$null)

#Formating 
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Formatting = 1
$xmlWriter.indentChar = "`t"

#Write the header

$xmlWriter.WriteStartDocument()
$XmlWriter.WriteProcessingInstruction("xml-stylesheet","type='text/xls' href='style.xls'")

#Create Root element
$xmlWriter.WriteStartElement("Player")
   
#Disk and Volumes
$xmlWriter.WriteStartElement("Disks")
$disks = Get-Disk 
foreach ($disk in $disks){
        $xmlWriter.WriteStartElement("Disk")
        $xmlWriter.WriteAttributeString("Label","$($disk.FriendlyName)")
            $xmlWriter.WriteElementString("Name","$($disk.FriendlyName)")
            $xmlWriter.WriteElementString("HealthStatus",$($disk.HealthStatus))
        $xmlWriter.WriteEndElement()
}
$xmlWriter.WriteEndElement()



$xmlWriter.WriteStartElement("Volumes")
$volumes = Get-Volume
foreach ($volume in $volumes){
    if(!($volume.DriveLetter -eq "")){
        $xmlWriter.WriteStartElement("Volume")
        $xmlWriter.WriteAttributeString("Label",$volume.DriveLetter)
            $xmlWriter.WriteElementString("Name",$volume.DriveLetter)
            $xmlWriter.WriteElementString("HealthStatus",$volume.HealthStatus)
        $xmlWriter.WriteEndElement()
    }
}
$xmlWriter.WriteEndElement()

#TeamViewer installator

$xmlWriter.WriteEndElement()

$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()

