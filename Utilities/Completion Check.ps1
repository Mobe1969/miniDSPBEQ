$signals = "D:\Video\Temp\BEQ\Complete"
$done = "D:\BEQ\Mobe1969_miniDSPBEQ\Movie BEQs"

$files = Get-ChildItem $signals -Filter *signal
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
Add-Content -Path "D:\BEQ\Errors.txt" -Value "Not Done:"
foreach ($file in $files) {
    if ($file.Name.Substring(0, 4).Equals("Flat", 3)) {
        continue
    }
    $signalName = [io.path]::GetFileNameWithoutExtension($file.Name)
    $filter = Get-ChildItem $done -Filter "$signalName.xml"
    if ($null -eq $filter) {
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name)"
    }
}