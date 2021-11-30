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

clear

$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ\TV BEQs" -Filter *.xml -Recurse
#$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ\Movie BEQs" -Filter *.xml -Recurse
$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ" -Filter *.xml -Recurse
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
foreach ($file in $files) {
    if ($file.Name.Substring(0, 4).Equals("Flat", 3)) {
        continue
    }
    $save = $false
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    $reportName = [io.path]::GetFileNameWithoutExtension($file.Name)
    if ($reportName -eq "Alone and Distracted (2014) DTS-HD MA 5.1") {
        $reportName = "Edge of Tomorrow (2014)(40s) DTS-HD MA 5.1"
    }
    if ($file.FullName.Contains("Movie")) {
        $report = Get-ChildItem "D:\BEQ\Mobe\beq-reports\Movies" -Filter "$reportName.jpg"
    }
    else {
        $report = Get-ChildItem "D:\BEQ\Mobe\beq-reports\TV Series" -Filter "$reportName.jpg" -Recurse
    }
    if ($null -eq $report) {
        Write-Output "$($file.Name) Unable to find report"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) Unable to find report"
        $reportURL = ""
        continue
    } else {
        $reportURL = [String]"https://gitlab.com/Mobe1969/beq-reports/-/raw/master" + [uri]::EscapeDataString($report.FullName.Replace("D:\BEQ\Mobe\beq-reports", "").Replace("\", "/")).Replace("%2F", "/")
        $reportURL = [String]$reportURL.Replace("(", "%28").Replace(")", "%29")
    }
    if ($null -eq $content.setting.beq_metadata) {
        Write-Output "$($file.Name) missing metadata"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing metadata"
        $beq_season = [xml]"
<beq_season>
    <number></number>
    <poster></poster>
    <episodes></episodes>
</beq_season>"
        $beq_metadata = [xml]"
<beq_metadata>
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
    <beq_collection></beq_collection>
    <beq_audioTypes>
        <audioType />
    </beq_audioTypes>
    <beq_genres>
    </beq_genres>
</beq_metadata>"
        $import = $content.ImportNode($beq_metadata.beq_metadata, $true)
        $content.setting.AppendChild($import)
        $content.Save($file.FullName)
    }
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    $beqMetadata = $content.setting.beq_metadata
    $fileName = [io.path]::GetFileNameWithoutExtension($file.Name)
    $title = $file.Name.SubString(0, $file.Name.IndexOf("(")).Trim()

    if ($title.Contains("-")) {
        $dash = $title.IndexOf("-")
        $dashToColon = '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' '
        if ($title.Substring($dash + 1, 1).IndexOfAny($dashToColon) -ge 0 -and $title.Substring($dash - 1, 1).IndexOfAny($dashToColon) -ge 0) {
            $title = $title.Replace("-", ":")
        }
    }
    if ($beqMetadata.beq_title -eq "") {
        if (!$beqMetadata.beq_title.Equals($title, 3)) {
            $beqMetadata.beq_title = $title
            $save = $true
        }
    }
    if (!$beqMetadata.beq_sortTitle.Equals($title.ToLower(), 3)) {
        $beqMetadata.beq_sortTitle = $title.ToLower()
        $save = $true
    }
    if (!$beqMetadata.beq_year.Equals($file.Name.SubString($file.Name.IndexOf("(") + 1, 4), 3)) {
        $beqMetadata.beq_year = $file.Name.SubString($file.Name.IndexOf("(") + 1, 4)
        $save = $true
    }
    if (!$beqMetadata.beq_pvaURL.Equals($reportURL, 3)) {
        $beqMetadata.beq_pvaURL = $reportURL
        $save = $true
    }
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
    elseif ($fileName.IndexOf("(Ic)") -ge 0) {
        $language = "Icelandic"
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
    elseif ($fileName.IndexOf("(Da)") -ge 0) {
        $language = "Danish"
    }
    elseif ($fileName.IndexOf("(Du)") -ge 0) {
        $language = "Dutch"
    }
    elseif ($fileName.IndexOf("(Po)") -ge 0) {
        $language = "Portuguese"
    }
    elseif ($fileName.IndexOf("(Pl)") -ge 0) {
        $language = "Polish"
    }
    elseif ($fileName.IndexOf("(Fi)") -ge 0) {
        $language = "Finnish"
    }
    elseif ($fileName.IndexOf("(It)") -ge 0) {
        $language = "Italian"
    }
    elseif ($fileName.IndexOf("(He)") -ge 0) {
        $language = "Hebrew"
    }
    elseif ($fileName.IndexOf("(Se)") -ge 0) {
        $language = "Swedish"
    }
    elseif ($fileName.IndexOf("(Hi)") -ge 0) {
        $language = "Hindi"
    }
    elseif ($fileName.IndexOf("(In)") -ge 0) {
        $language = "Indonesian"
    }
    elseif ($fileName.IndexOf("(Ab)") -ge 0) {
        $language = "Arabic"
    }
    else {
        $language = "English"
    }
    if ($beqMetadata.beq_language -eq "" -or ($beqMetadata.beq_language -eq "English" -and $language -ne "English")) {
        $beqMetadata.beq_language = $language
        $save = $true
    }
    $edition = ""
    if ($fileName.IndexOf("(TC)") -ge 0) {
        $edition = "Theatrical Cut"
    }
    elseif ($fileName.IndexOf("(Theatrical)") -ge 0) {
        $edition = "Theatrical Cut"
    }
    elseif ($fileName.IndexOf("(EC)") -ge 0) {
        $edition = "Extended Cut"
    }
    elseif ($fileName.IndexOf("(Extended)") -ge 0) {
        $edition = "Extended Cut"
    }
    elseif ($fileName.IndexOf("(UC)") -ge 0) {
        $edition = "Unrated Cut"
    }
    elseif ($fileName.IndexOf("(UR)") -ge 0) {
        $edition = "Unrated Cut"
    }
    elseif ($fileName.IndexOf("(Unrated)") -ge 0) {
        $edition = "Unrated Cut"
    }
    elseif ($fileName.IndexOf("(Uncut)") -ge 0) {
        $edition = "Unrated Cut"
    }
    elseif ($fileName.IndexOf("(DC)") -ge 0) {
        $edition = "Director's Cut"
    }
    elseif ($fileName.IndexOf("(AC)") -ge 0) {
        $edition = "Alternate Cut"
    }
    if ($beqMetadata.beq_edition -ne $edition -and "" -ne $edition) {
        $beqMetadata.beq_edition = $edition
        $save = $true
    }
    if ([string]::IsNullOrWhitespace($beqMetadata.beq_theMovieDB)) {
        Write-Output "$($file.Name) missing TMDB metadata"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing TMDB metadata"
        if ($beqMetadata.beq_title -eq "Alone and Distracted") {
            $safeTitle = [uri]::EscapeDataString("Edge of Tomorrow")
        } else {
            $safeTitle = [uri]::EscapeDataString($beqMetadata.beq_title)
        }
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
    if (![string]::IsNullOrWhitespace($beqMetadata.beq_theMovieDB) -and ([string]::IsNullOrWhitespace($beqMetadata.beq_title)-or [string]::IsNullOrWhitespace($beqMetadata.beq_genres.genre) -or [string]::IsNullOrWhitespace($beqMetadata.beq_runtime) -or [string]::IsNullOrWhitespace($beqMetadata.beq_overview) -or [string]::IsNullOrWhitespace($beqMetadata.beq_rating))) {
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
            if ($beqMetadata.beq_overview -ne $result.overview) { # -and ![string]::IsNullOrWhitespace($result.overview)) {
                $beqMetadata.beq_overview = $result.overview
                Write-Output "$($beqMetadata.beq_overview)"
                Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($beqMetadata.beq_overview)"
                $save = $true
            }
            if ($beqMetadata.beq_title -ne $result.title -and $beqMetadata.beq_alt_title -ne $result.title -and ![string]::IsNullOrWhitespace($result.title)) {
                $beqMetadata.beq_alt_title = $result.title
                $save = $true
            }
            if ($beqMetadata.beq_title -eq [Regex]::Replace($beqMetadata.beq_alt_title, ":", "")) {
                $beqMetadata.beq_title = $beqMetadata.beq_alt_title
                $beqMetadata.beq_alt_title = ""
                Write-Output "Updating title to $($beqMetadata.beq_title)"
                $save = $true
            }
            if ($beqMetadata.beq_title -ne $beqMetadata.beq_alt_title -and "" -ne $beqMetadata.beq_alt_title) {
                Write-Output "Title $($beqMetadata.beq_title), Alt Title $($beqMetadata.beq_alt_title)"
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_genres.genre) -and $result.genres.Count -gt 0) {                    
                $beq_genres = $content.CreateElement("beq_genres")
                foreach ($genre in $result.genres) {
                    if (![string]::IsNullOrWhitespace($genre.name)) {
                        $genreNode = $content.CreateElement("genre")
                        $genreNode.SetAttribute("id", $genre.id.ToString())
                        $genreNode.InnerText = $genre.name
                        $beq_genres.AppendChild($genreNode)
                    }
                }
                $currentGenres = $content.SelectSingleNode("/setting/beq_metadata/beq_genres")
                if ($null -ne $currentGenres) {
                    $currentGenres.ParentNode.RemoveChild($currentGenres)
                }
                $importGenre = $content.ImportNode($beq_genres, $true)
                $content.setting.beq_metadata.AppendChild($importGenre)
                $save = $true
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_collection) -and ![string]::IsNullOrWhitespace($result.belongs_to_collection.id)) {                    
                $collectionNode = $content.CreateElement("beq_collection")
                $collectionNode.SetAttribute("id", $result.belongs_to_collection.id.ToString())
                $collectionNode.InnerText = $result.belongs_to_collection.name
                $currentCollectionNode = $content.SelectSingleNode("/setting/beq_metadata/beq_collection")
                if ($null -ne $currentCollectionNode) {
                    $currentCollectionNode.ParentNode.RemoveChild($currentCollectionNode)
                }
                $beqMetadata.AppendChild($collectionNode)
                $save = $true
            }
            Set-Rating -Code "US"
            Set-Rating -Code "GB"
            Set-Rating -Code "AU"
            Set-Rating -Code "CA"
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_rating)) {
                $beqMetadata.beq_rating = "NR"
                $save = $true
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_runtime)) {
                if (![string]::IsNullOrWhitespace($result.runtime)) {
                    $beqMetadata.beq_runtime = $result.runtime.ToString()
                } else {
                    $beqMetadata.beq_runtime = "0"
                }
                $save = $true
            }
            if ([string]::IsNullOrWhitespace($beqMetadata.beq_poster) -and ![string]::IsNullOrWhitespace($result.poster_path)) {
                $beqMetadata.beq_poster = $result.poster_path
                $save = $true
            }
            if ($beqMetadata.beq_overview -ne $result.overview -and ![string]::IsNullOrWhitespace($result.overview)) {
                $beqMetadata.beq_overview = $result.overview
                Write-Output "$($beqMetadata.beq_overview)"
                Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($beqMetadata.beq_overview)"
                $save = $true
            }
        }
    }
    if ($fileName.IndexOf("DTS-HD") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DTS-HD"))
    }
    elseif ($fileName.IndexOf("DD+") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DD+"))
        if ($beqMetadata.beq_source -ne "Streaming") {
            $beqMetadata.beq_source = "Streaming"
            $save = $true
        }
    }
    elseif ($fileName.IndexOf("DTS-X") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DTS-X"))
    }
    elseif ($fileName.IndexOf("DTS-ES") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DTS-ES"))
    }
    elseif ($fileName.IndexOf("DTS") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DTS"))
    }
    elseif ($fileName.IndexOf("Atmos") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("Atmos"))
    }
    elseif ($fileName.IndexOf("TrueHD") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("TrueHD"))
    }
    elseif ($fileName.IndexOf("AC3") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("AC3"))
    }
    elseif ($fileName.IndexOf("DD 5") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DD 5"))
    }
    elseif ($fileName.IndexOf("LPCM") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("LPCM"))
    }
    $foundAudio = $false
    foreach ($audioType in $beqMetadata.beq_audioTypes.audioType){
        if ($audioType -eq $audio) {
            $foundAudio = $true
        }    
    }
    if ($foundAudio -eq $false) {
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
    if ($beqMetadata.beq_title -eq [Regex]::Replace($beqMetadata.beq_alt_title, "[\-():!.,]", "")) {
        $beqMetadata.beq_title = $beqMetadata.beq_alt_title
        $beqMetadata.beq_alt_title = ""
        Write-Output "Updating title to $($beqMetadata.beq_title)"
        $save = $true
    }
    #if ($beqMdescretadata.beq_title -ne $beqMetadata.beq_alt_title -and "" -ne $beqMetadata.beq_alt_title) {
    #    Write-Output "Title $($beqMetadata.beq_title), Alt Title $($beqMetadata.beq_alt_title)"
    #    Add-Content -Path "D:\BEQ\Errors.txt" -Value "Title $($beqMetadata.beq_title), Alt Title $($beqMetadata.beq_alt_title)"
    #}
    if ($save) {
        $content.Save($file.FullName)
    } else {
        #Write-Output "No Change: $($file.Name)"
    }
    if ($file.Name -eq "009 Re Cyborg (2012)(Ja) DTS-HD MA 5.1.xml") {
        #break
    }
}