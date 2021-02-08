function Set-Rating {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$Code
	)
    if ([string]::isnullorwhitespace($beqmetadata.beq_rating)) {
        $releases = $result.release_dates.results | Where-Object { $_.iso_3166_1 -eq $Code }
        if ($null -ne $releases -and $null -ne $releases.release_dates) {
            $releases.release_dates | Select-Object -Property certification  | ForEach-Object {
                if ([string]::IsNullOrWhitespace($beqMetadata.beq_rating) -and ![string]::IsNullOrWhitespace($_.certification)) {
                    $beqMetadata.beq_rating = $_.certification
                    $save = $true
                }
            }
        }
    }
}



$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ" -Filter *.xml -Recurse
if ([System.IO.File]::Exists("D:\BEQ\TitleCheck.txt")) {
    Clear-Content -Path "D:\BEQ\TitleCheck.txt"
}
Clear
foreach ($file in $files) {
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    if ($null -ne $content.setting.beq_metadata) {
        $beqMetadata = $content.setting.beq_metadata
        Write-Output "$($beqMetadata.beq_title)$([char]9)$($beqMetadata.beq_overview.Substring(0, [Math]::Min(1200, $beqMetadata.beq_overview.Length)))"
        Add-Content -Path "D:\BEQ\TitleCheck.txt" -Value "$($beqMetadata.beq_title)$([char]9)$($beqMetadata.beq_overview.Substring(0, [Math]::Min(1200, $beqMetadata.beq_overview.Length)))"
    }
}