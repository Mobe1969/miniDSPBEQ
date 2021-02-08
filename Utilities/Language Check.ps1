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
if ([System.IO.File]::Exists("D:\BEQ\LanguageCheck.txt")) {
    Clear-Content -Path "D:\BEQ\LanguageCheck.txt"
}
foreach ($file in $files) {
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    if ($null -ne $content.setting.beq_metadata) {
        $beqMetadata = $content.setting.beq_metadata
        $save = $false

        $language = "English"
        if ($fileName.IndexOf("(Ja)") -ge 0) {
            $language = "Japanese"
        }
        elseif ($fileName.IndexOf("(Fr)") -ge 0) {
            $language = "French"
        }
        elseif ($fileName.IndexOf("(Ko)") -ge 0) {
            $language = "Korean"
        }
        elseif ($fileName.IndexOf("(Ru)") -ge 0) {
            $language = "Russian"
        }
        elseif ($fileName.IndexOf("(No)") -ge 0) {
            $language = "Norwegian"
        }
        elseif ($fileName.IndexOf("(Ma)") -ge 0) {
            $language = "Mandarin"
        }
        elseif ($fileName.IndexOf("(Ca)") -ge 0) {
            $language = "Cantonese"
        }
        elseif ($fileName.IndexOf("(Es)") -ge 0) {
            $language = "Spanish"
        }
        elseif ($fileName.IndexOf("(De)") -ge 0) {
            $language = "German"
        }
        elseif ($fileName.IndexOf("(Fi)") -ge 0) {
            $language = "Finnish"
        }
        elseif ($fileName.IndexOf("(He)") -ge 0) {
            $language = "Hebrew"
        }
        else {
            $language = "English"
        }
        if ($file.FullName.Contains("Movie")) {
            $ItemType = "movie"
        }
        else {
            $ItemType = "tv"
        }
        $url = "https://api.themoviedb.org/3/" + $ItemType + "/" + $beqMetadata.beq_theMovieDB + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
        $result = Invoke-RestMethod -Uri $url
        if ($null -ne $result) {
            $cultureInfo = New-Object system.globalization.cultureinfo($result.original_language);
            if ($beqMetadata.beq_language -ne $cultureInfo.DisplayName) {
                Write-Output "$($file.Name): Original language $($cultureInfo.DisplayName), file language $($beqMetadata.beq_language)"
                Add-Content -Path "D:\BEQ\LanguageCheck.txt" -Value "$($file.Name): Original language $($cultureInfo.DisplayName), file language $($beqMetadata.beq_language)"
            }    
        }
    }
}