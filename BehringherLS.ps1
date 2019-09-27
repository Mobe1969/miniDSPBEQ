$InputDirectory = "D:\miniDSPBEQ"
$OutputDirectorySuffix = "Behringer LS"

$files = Get-Childitem $InputDirectory *.xml -Recurse| Where-Object { $_.FullName -inotmatch $OutputDirectorySuffix }
foreach ($file in $files){
    $xmldata = [xml](Get-Content $file.FullName); 
    $node = $xmldata.setting.filter | Where-Object { $_.name -eq "PEQ_3_10" }
    $node.freq = "10"
    $node.q = ".5"
    $node.boost = "4.4"
    $node.type = "SL"
    $node.dec = "1.0001661767013137,-1.998846932505161,0.9986813073310071,1.9988470421047522,-0.9988473744327293,"
    $node.hex = "3f800572,bfffda37,3f7fa994,3fffda38,bf7fb476,"
    $OutputDirectory = "$($file.DirectoryName)\$OutputDirectorySuffix"
    New-Item -ItemType Directory -Force -Path $OutputDirectory
    $outputFile = "$OutputDirectory\$($file.Name)"
    $xmldata.Save($outputFile)
}
