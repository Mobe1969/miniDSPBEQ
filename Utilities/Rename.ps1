$signals = "D:\Video\Temp\BEQ\Complete"
$done = "D:\BEQ\Mobe1969_miniDSPBEQ\Movie BEQs"

$files = Get-ChildItem $signals
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
Add-Content -Path "D:\BEQ\Errors.txt" -Value "Not Done:"
foreach ($file in $files) {
    if ($file.Name -like '*TrueHD Atmos*') {
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) to $($file.Name.Replace("TrueHD Atmos", "Atmos"))"
        #Rename-Item -Path $file.FullName -NewName $file.FullName.Replace("TrueHD Atmos", "Atmos")
    }
    if ($file.Name -like '*DTS-X MA*') {
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) to $($file.Name.Replace("DTS-X MA", "DTS-X"))"
        #Rename-Item -Path $file.FullName -NewName $file.Name.Replace("DTS-X MA", "DTS-X")
    }
    if ($file.Name -like '*DTS-HD HRA*') {
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) to $($file.Name.Replace("DTS-HD HRA", "DTS-HD HR"))"
        #Rename-Item -Path $file.FullName -NewName $file.FullName.Replace("TrueHD Atmos", "Atmos")
    }
}