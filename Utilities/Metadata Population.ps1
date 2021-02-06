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
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
foreach ($file in $files) {
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    $reportName = [io.path]::GetFileNameWithoutExtension($file.Name)
    $report = Get-ChildItem "D:\BEQ\Mobe\beq-reports" -Filter "$reportName.jpg" -Recurse
    if ($null -eq $report) {
        Write-Output "$($file.Name) Unable to find report"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) Unable to find report"
    }
    else {
        $correctURL = [String]"https://gitlab.com/Mobe1969/beq-reports/-/raw/master/Movies/" + [uri]::EscapeDataString($report.Name)
        $correctURL2 = [String]$correctURL.Replace("(", "%28").Replace(")", "%29")
        if ($null -ne $content.setting.beq_metadata) {
            $beqMetadata = $content.setting.beq_metadata
            $save = $false
            $fileName = [io.path]::GetFileNameWithoutExtension($file.Name)
            if ($fileName.IndexOf("DTS-HD") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("DTS-HD"))
            }
            elseif ($fileName.IndexOf("DTS-X") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("DTS-X"))
            }
            elseif ($fileName.IndexOf("TrueHD") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("TrueHD"))
            }
            elseif ($fileName.IndexOf("AC3") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("AC3"))
            }
            elseif ($fileName.IndexOf("LPCM") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("LPCM"))
            }
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
            $title = $file.Name.SubString(0, $file.Name.IndexOf("(")).Trim()
            if ($title.Contains("-")) {
                $dash = $title.IndexOf("-")
                $dashToColon = '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' '
                if ($title.Substring($dash + 1, 1).IndexOfAny($dashToColon) -ge 0 -and $title.Substring($dash - 1, 1).IndexOfAny($dashToColon) -ge 0) {
                    $title = $title.Replace("-", ":")
                }
            }
            if (!$beqMetadata.beq_title.Equals($title, 3)) {
   	            $beqMetadata.beq_title = $file.Name.SubString(0, $file.Name.IndexOf("(")).Replace("-", ":").Trim()
                $save = $true
            }
            if (!$beqMetadata.beq_sortTitle.Equals($title.ToLower(), 3)) {
                $beqMetadata.beq_sortTitle = $file.Name.SubString(0, $file.Name.IndexOf("(")).Replace("-", ":").Trim().ToLower()
                $save = $true
            }
            if (!$beqMetadata.beq_year.Equals($file.Name.SubString($file.Name.IndexOf("(") + 1, 4), 3)) {
                $beqMetadata.beq_year = $file.Name.SubString($file.Name.IndexOf("(") + 1, 4)
                $save = $true
            }
            if (!$beqMetadata.beq_pvaURL.Equals($correctURL, 3)) {
                $beqMetadata.beq_pvaURL = $correctURL
                $save = $true
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_theMovieDB)) {
                Write-Output "$($file.Name) missing TMDB metadata"
                Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing TMDB metadata"
                $safeTitle = [uri]::EscapeDataString($beqMetadata.beq_title)
                $year = $beqMetadata.beq_year
                if ($file.FullName.Contains("Movie")) {
                    $ItemType = "movie"
                }
                else {
                    $ItemType = "tv"
                }
                $url = "https://api.themoviedb.org/3/search/" + $ItemType + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&query=$safeTitle&page=1&year=$year"
                $response = Invoke-RestMethod -Uri $url
                if ($null -ne $response -and $null -ne $response.results -and $response.results.Count -ge 1) { 
                    $result = $response.results[0]
                    if ($beqMetadata.beq_theMovieDB -ne $result.id.ToString() -and ![string]::IsNullOrWhitespace($result.id.ToString())) {
                        $beqMetadata.beq_theMovieDB = $result.id.ToString()
                        $save = $true
                    }
                }
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_title) -or [string]::IsNullOrWhitespace($beqMetadata.beq_poster) -or [string]::IsNullOrWhitespace($beqMetadata.beq_genres) -or [string]::IsNullOrWhitespace($beqMetadata.beq_runtime) -or [string]::IsNullOrWhitespace($beqMetadata.beq_poster) -or [string]::IsNullOrWhitespace($beqMetadata.beq_overview) -or [string]::IsNullOrWhitespace($beqMetadata.beq_rating)) {
                Write-Output "$($file.Name) missing TMDB metadata content"
                Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing TMDB metadata content"
                if ($file.FullName.Contains("Movie")) {
                    $ItemType = "movie"
                }
                else {
                    $ItemType = "tv"
                }
                $url = "https://api.themoviedb.org/3/" + $ItemType + "/" + $beqMetadata.beq_theMovieDB + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
                $result = Invoke-RestMethod -Uri $url
                if ($null -ne $result) { 
                    if ($beqMetadata.beq_poster -ne $result.poster_path -and ![string]::IsNullOrWhitespace($result.poster_path)) {
                        $beqMetadata.beq_poster = $result.poster_path
                        $save = $true
                    }
                    if ($beqMetadata.beq_overview -ne [Regex]::Replace($result.overview, "[^\u0000-\u007F]+", "") -and ![string]::IsNullOrWhitespace([Regex]::Replace($result.overview, "[^\u0000-\u007F]+", ""))) {
                        $beqMetadata.beq_overview = [Regex]::Replace($result.overview, "[^\u0000-\u007F]+", "")
                        $save = $true
                    }
                    if ($beqMetadata.beq_title -ne [Regex]::Replace($result.title, "[^\u0000-\u007F]+", "") -and $beqMetadata.beq_alt_title -ne [Regex]::Replace($result.title, "[^\u0000-\u007F]+", "") -and ![string]::IsNullOrWhitespace([Regex]::Replace($result.title, "[^\u0000-\u007F]+", ""))) {
                        $beqMetadata.beq_alt_title = [Regex]::Replace($result.title, "[^\u0000-\u007F]+", "")
                        $save = $true
                    }
                    if ([string]::IsNullOrWhitespace($beqMetadata.beq_genres) -and $result.genres.Count -gt 0) {                    
                        $beq_genres = $content.CreateElement("beq_genres")
                        foreach ($genre in $result.genres) {
                            if (![string]::IsNullOrWhitespace($genre.name)) {
                                $genreNode = $content.CreateElement("genre")
                                $genreNode.SetAttribute("id", $genre.id.ToString())
                                $genreNode.InnerText = $genre.name
                                $beq_genres.AppendChild($genreNode)
                            }
                        }
                        if ($null -ne $content.setting.beq_metadata.$beq_genres) {
                            $content.setting.beq_metadata.RemoveChild($content.setting.beq_metadata.beq_genres)
                        }
                        $import = $content.ImportNode($beq_genres, $true)
                        $content.setting.beq_metadata.AppendChild($import)
                        $save = $true
                    }
                    Set-Rating -Code "US"
                    Set-Rating -Code "GB"
                    Set-Rating -Code "AU"
                    Set-Rating -Code "CA"
                    Set-Rating -Code "DE"
                    Set-Rating -Code "FR"
                    Set-Rating -Code "NO"
                    Set-Rating -Code "ES"
                    Set-Rating -Code "FI"
                    Set-Rating -Code "JP"
                    Set-Rating -Code "KR"
                    Set-Rating -Code "IT"
                    Set-Rating -Code "CH"
                    Set-Rating -Code "CN"
                    Set-Rating -Code "TW"
                    Set-Rating -Code "IE"
                    Set-Rating -Code "RU"
                    Set-Rating -Code "HK"
                    Set-Rating -Code "NL"
                    Set-Rating -Code "NZ"
                    Set-Rating -Code "NL"
                    Set-Rating -Code "MX"
                    if ([string]::IsNullOrWhitespace($beqMetadata.beq_runtime) -and ![string]::IsNullOrWhitespace($result.runtime.ToString())) {
                        $beqMetadata.beq_runtime = $result.runtime.ToString()
                        $save = $true
                    }
                    if ([string]::IsNullOrWhitespace($beqMetadata.beq_poster) -and ![string]::IsNullOrWhitespace($result.poster_path)) {
                        $beqMetadata.beq_poster = $result.poster_path
                        $save = $true
                    }
                    if ($beqMetadata.beq_overview -ne [Regex]::Replace($result.overview, "[^\u0000-\u007F]+", "") -and ![string]::IsNullOrWhitespace([Regex]::Replace($result.overview, "[^\u0000-\u007F]+", ""))) {
                        $beqMetadata.beq_overview = [Regex]::Replace($result.overview, "[^\u0000-\u007F]+", "")
                        $save = $true
                    }
                }
            }
            if ($beqMetadata.beq_language -eq "" -or ($beqMetadata.beq_language -eq "English" -and $language -ne "English")) {
                $beqMetadata.beq_language = $language
                $save = $true
            }
            if ($beqMetadata.beq_audioTypes.audioType -ne $audio) {
                if ($audio -ne "") {
                    $beq_audioTypes = $content.CreateElement("beq_audioTypes")
                    $audioType = $content.CreateElement("audioType")
                    $audioType.InnerText = $audio
                    $beq_audioTypes.AppendChild($audioType)
                    if ($null -ne $content.setting.beq_metadata.beq_audioTypes) {
                        $content.setting.beq_metadata.RemoveChild($content.setting.beq_metadata.beq_audioTypes)
                    }
                    $import = $content.ImportNode($beq_audioTypes, $true)
                    $content.setting.beq_metadata.AppendChild($import)
                    $save = $true
                }
            }
            if ($save) {
                $content.Save($file.FullName)
            }
            if ($file.Name -eq "Three West (2016) DTS-HD MA 5.1.xml") {
                #break
            }
        }
        else {
            Write-Output "$($file.Name) missing metadata"
            Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing metadata"
            $beq_season = [xml]"<beq_season>
    <number></number>
    <poster></poster>
    <episodes></episodes>
    </beq_season>"
            $beq_metadata = [xml]"<beq_metadata>
	<beq_title />
	<beq_alt_title />
	<beq_sortTitle />
	<beq_year />
	<beq_spectrumURL />
	<beq_pvaURL />
	<beq_edition />
    <beq_season>
    </beq_season>
	<beq_note />
	<beq_warning />
	<beq_gain />
	<beq_language>
	</beq_language>
	<beq_source>Disc</beq_source>
	<beq_overview />
	<beq_rating>
	</beq_rating>
	<beq_author>mobe1969</beq_author>
	<beq_avs />
	<beq_theMovieDB />
	<beq_poster>
	</beq_poster>
	<beq_runtime>
	</beq_runtime>
	<beq_audioTypes>
		<audioType />
	</beq_audioTypes>
	<beq_genres>
		<genre />
	</beq_genres>
</beq_metadata>"
            $fileName = [io.path]::GetFileNameWithoutExtension($file.Name)
            if ($fileName.IndexOf("DTS-HD") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("DTS-HD"))
            }
            elseif ($fileName.IndexOf("DTS-X") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("DTS-X"))
            }
            elseif ($fileName.IndexOf("TrueHD") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("TrueHD"))
            }
            elseif ($fileName.IndexOf("AC3") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("AC3"))
            }
            elseif ($fileName.IndexOf("LPCM") -ge 0) {
                $audio = $fileName.SubString($fileName.IndexOf("LPCM"))
            }
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
            elseif ($fileName.IndexOf("(He)") -ge 0) {
                $language = "Hebrew"
            }
            else {
                $language = "English"
            }
   	        $beq_metadata.beq_metadata.beq_title = $file.Name.SubString(0, $file.Name.IndexOf("(")).Replace("-", ":").Trim()
            $beq_metadata.beq_metadata.beq_sortTitle = $file.Name.SubString(0, $file.Name.IndexOf("(")).Replace("-", ":").Trim().ToLower()
            if (!$beqMetadata.beq_year.Equals($file.Name.SubString($file.Name.IndexOf("(") + 1, 4), 3)) {
                $beq_metadata.beq_metadata.beq_year = $file.Name.SubString($file.Name.IndexOf("(") + 1, 4)
                $save = $true
            }
            $beq_metadata.beq_metadata.beq_pvaURL = $correctURL
            $beq_metadata.beq_metadata.beq_audioTypes.audioType = $audio
            $beq_metadata.beq_metadata.beq_language = $language
            $import = $content.ImportNode($beq_metadata.beq_metadata, $true)
            $content.setting.AppendChild($import)
            $content.Save($file.FullName)
        }
    }
}

