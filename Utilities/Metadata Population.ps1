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

$files = Get-ChildItem "D:\BEQ\miniDSPBEQ" -Filter *.xml -Recurse | 
         Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
foreach ($file in $files) {
    $save = $false
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName -Encoding UTF8)
    $reportName = [io.path]::GetFileNameWithoutExtension($file.Name)
    if ($reportName -eq "Alone and Distracted (2014) DTS-HD MA 5.1") {
        $reportName = "Edge of Tomorrow (2014)(40s) DTS-HD MA 5.1"
    }
    if ($reportName -eq 'Snake Eyes- G.I. Joe Origins (2021)(It) DD 5.1') {
        continue
    }
    if ($file.FullName.Contains("Movie")) {
        $report = Get-ChildItem "D:\BEQ\beq-reports\Movies" -Filter "$reportName.jpg" -Recurse
    } elseif ($file.Name.StartsWith("Flat")) {
        continue
    } elseif ($file.FullName.Contains("Trailers")) {
        continue
    } else {
        $report = Get-ChildItem "D:\BEQ\beq-reports\TV Series" -Filter "$reportName.jpg" -Recurse
    }
    if ($null -eq $report) {
        Write-Output "$($file.Name) Unable to find report"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) Unable to find report"
        $reportURL = ""
    } else {
        $reportURL = [uri]::EscapeUriString("https://gitlab.com/Mobe1969/beq-reports/-/raw/master" + $report.FullName.Replace("D:\BEQ\beq-reports", "").Replace("\", "/"))
    }
    if ($null -eq $content.setting.beq_metadata) {
        Write-Output "$($file.Name) missing metadata"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing metadata"
        if ($file.FullName.Contains("Movie BEQs")) {
            $beq_metadata = [xml]"
<beq_metadata>
    <beq_title />
    <beq_alt_title />
    <beq_sortTitle />
    <beq_year />
    <beq_spectrumURL />
    <beq_pvaURL />
    <beq_edition />
    <beq_season />
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
        }
        else {
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
        <number></number>
        <poster></poster>
        <episodes count=""0""></episodes>
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
        }
        $import = $content.ImportNode($beq_metadata.beq_metadata, $true)
        $content.setting.AppendChild($import)
        $content.Save($file.FullName)
    }
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName -Encoding UTF8)
    $beqMetadata = $content.setting.beq_metadata
    $fileName = [io.path]::GetFileNameWithoutExtension($file.Name)
    if (-1 -ne $file.Name.IndexOf("(19")) {
        $title = $file.Name.SubString(0, $file.Name.IndexOf("(19")).Trim()
    }elseif (-1 -ne $file.Name.IndexOf("(20")) {
        $title = $file.Name.SubString(0, $file.Name.IndexOf("(20")).Trim()
    }
    if ($beqMetadata.beq_title -eq "") {
        if (!$beqMetadata.beq_title.Equals($title, 3)) {
            $beqMetadata.beq_title = $title
            $save = $true
        }
    }
    $alphaNumeric = $title.ToLower() -replace "[^a-zA-Z0-9&\.:\-' ]"
    if (!$beqMetadata.beq_sortTitle.Equals($alphaNumeric)) {
        $beqMetadata.beq_sortTitle = $alphaNumeric
        $save = $true
    }
    if (!$beqMetadata.beq_sortTitle.Equals($beqMetadata.beq_sortTitle.Replace("  ", " "))) {
        $beqMetadata.beq_sortTitle = $beqMetadata.beq_sortTitle.Replace("  ", " ")
        $save = $true
    }
    if (-1 -ne $file.Name.IndexOf("(19")) {
        $year = $file.Name.SubString($file.Name.IndexOf("(19") + 1, 4)
        if (!$beqMetadata.beq_year.Equals($year)) {
            $beqMetadata.beq_year = $year
            $save = $true
        }
    }elseif (-1 -ne $file.Name.IndexOf("(20")) {
        $year = $file.Name.SubString($file.Name.IndexOf("(20") + 1, 4)
        if (!$beqMetadata.beq_year.Equals($year)) {
            $beqMetadata.beq_year = $year
            $save = $true
        }
    }
        if (!$beqMetadata.beq_pvaURL.Equals($reportURL, 3)) {
            if (![string]::IsNullOrWhitespace($reportURL)) {
                $beqMetadata.beq_pvaURL = $reportURL
                $save = $true
            }
        }

    if ($fileName.IndexOf("(Ja)") -ge 0) {
        $language = "Japanese"
    }
    elseif ($fileName.IndexOf("(Ro)") -ge 0) {
        $language = "Romanian"
    }
    elseif ($fileName.IndexOf("(Mx)") -ge 0) {
        $language = "Mixed"
    }
    elseif ($fileName.IndexOf("(Fr)") -ge 0) {
        $language = "French"
    }
    elseif ($fileName.IndexOf("(Af)") -ge 0) {
        $language = "Afrikaans"
    }
    elseif ($fileName.IndexOf("(Fl)") -ge 0) {
        $language = "Flemish"
    }
    elseif ($fileName.IndexOf("(Ko)") -ge 0) {
        $language = "Korean"
    }
    elseif ($fileName.IndexOf("(Ru)") -ge 0) {
        $language = "Russian"
    }
    elseif ($fileName.IndexOf("(Th)") -ge 0) {
        $language = "Thai"
    }
    elseif ($fileName.IndexOf("(Vi)") -ge 0) {
        $language = "Vietnamese"
    }
    elseif ($fileName.IndexOf("(Tu)") -ge 0) {
        $language = "Turkish"
    }
    elseif ($fileName.IndexOf("(No)") -ge 0) {
        $language = "Norwegian"
    }
    elseif ($fileName.IndexOf("(Ic)") -ge 0) {
        $language = "Icelandic"
    }
    elseif ($fileName.IndexOf("(Cz)") -ge 0) {
        $language = "Czech"
    }
    elseif ($fileName.IndexOf("(Ma)") -ge 0) {
        $language = "Mandarin"
    }
    elseif ($fileName.IndexOf("(Ca)") -ge 0) {
        $language = "Cantonese"
    }
    elseif ($fileName.IndexOf("(Ml)") -ge 0) {
        $language = "Malay"
    }
    elseif ($fileName.IndexOf("(My)") -ge 0) {
        $language = "Malayalam"
    }
    elseif ($fileName.IndexOf("(Es)") -ge 0) {
        $language = "Spanish"
    }
    elseif ($fileName.IndexOf("(Zu)") -ge 0) {
        $language = "Zulu"
    }
    elseif ($fileName.IndexOf("(Ba)") -ge 0) {
        $language = "Basque"
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
    elseif ($fileName.IndexOf("(Fl)") -ge 0) {
        $language = "Flemish"
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
    elseif ($fileName.IndexOf("(Te)") -ge 0) {
        $language = "Telugu"
    }
    elseif ($fileName.IndexOf("(Ta)") -ge 0) {
        $language = "Tamil"
    }
    elseif ($fileName.IndexOf("(Mr)") -ge 0) {
        $language = "Marathi"
    }
    elseif ($fileName.IndexOf("(Ka)") -ge 0) {
        $language = "Kannada"
    }
    elseif ($fileName.IndexOf("(Pu)") -ge 0) {
        $language = "Punjabi"
    }
    elseif ($fileName.IndexOf("(In)") -ge 0) {
        $language = "Indonesian"
    }
    elseif ($fileName.IndexOf("(Kh)") -ge 0) {
        $language = "Khymer"
    }
    elseif ($fileName.IndexOf("(Ar)") -ge 0) {
        $language = "Arabic"
    }
    elseif ($fileName.IndexOf("(Ab)") -ge 0) {
        $language = "Arabic"
    }
    elseif ($fileName.IndexOf("(Ta)") -ge 0) {
        $language = "Tagalog"
    }
    elseif ($fileName.IndexOf("(Th)") -ge 0) {
        $language = "Thai"
    }
    elseif ($fileName.IndexOf("(Yo)") -ge 0) {
        $language = "Yoruba"
    }
    else {
        $language = "English"
    }
    if ($beqMetadata.beq_language -eq "" -or ($beqMetadata.beq_language -eq "English" -and $language -ne "English")) {
        $beqMetadata.beq_language = $language
        $save = $true
    }
    $beq_note = ""
    if ($fileName.IndexOf("(UHD)") -ge 0) {
        $beq_note = "UHD"
    }
    elseif ($fileName.IndexOf("(BR)") -ge 0) {
        $beq_note = "Blu-Ray"
    }
    elseif ($fileName.IndexOf("(HK)") -ge 0) {
        $beq_note = "Hong Kong Blu-Ray"
    }
    elseif ($fileName.IndexOf("(Cri)") -ge 0) {
        $beq_note = "Criterion"
    }
    if ($fileName.IndexOf("(D1)") -ge 0) {
        $beq_note = $beq_note + "[Disc 1]"
    }
    elseif ($fileName.IndexOf("(D2)") -ge 0) {
        $beq_note = $beq_note + "[Disc 2]"
    }
    if ($fileName.IndexOf("(Ma)") -ge 0 -and $fileName.IndexOf("(Ca)") -ge 0) {
        $beq_note = $beq_note + "Cantonese and Mandarin tracks identical"
    }
    $edition = ""
    if ($fileName.IndexOf("(TC)") -ge 0) {
        $edition = "Theatrical Cut"
    }
    elseif ($fileName.IndexOf("(Theatrical)") -ge 0) {
        $edition = "Theatrical Cut"
    }
    elseif ($fileName.IndexOf("(3D)") -ge 0) {
        $edition = "3D Cut"
    }
    elseif ($fileName.IndexOf("(FC)") -ge 0) {
        $edition = "Final Cut"
    }
    elseif ($fileName.IndexOf("(SP)") -ge 0) {
        $edition = "Special Edition"
    }
    elseif ($fileName.IndexOf("(EC)") -ge 0) {
        $edition = "Extended Cut"
    }
    elseif ($fileName.IndexOf("(Prime)") -ge 0) {
        $edition = "Prime"
    }
    elseif ($fileName.IndexOf("(Extended)") -ge 0) {
        $edition = "Extended Cut"
    }
    elseif ($fileName.IndexOf("(UC)") -ge 0) {
        $edition = "Unrated Cut"
    }
    elseif ($fileName.IndexOf("(HK)") -ge 0) {
        $edition = "Hong Kong Cut"
    }
    elseif ($fileName.IndexOf("(JC)") -ge 0) {
        $edition = "Japanese Cut"
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
    elseif ($fileName.IndexOf("(UE)") -ge 0) {
        $edition = "Ultimate Edition"
    }
    elseif ($fileName.IndexOf("(ULT)") -ge 0) {
        $edition = "Ultimate Cut"
    }
    elseif ($fileName.IndexOf("(DC)") -ge 0) {
        $edition = "Director's Cut"
    }
    elseif ($fileName.IndexOf("(IC)") -ge 0) {
        $edition = "International Cut"
    }
    elseif ($fileName.IndexOf("(TV)") -ge 0) {
        $edition = "TV Cut"
    }
    elseif ($fileName.IndexOf("(AC)") -ge 0) {
        $edition = "Alternate Cut"
    }
    if ($language -ne "Italian") {
        if ($beq_note.Contains('UHD') -or $beq_note.Contains('Blu-Ray')) {
            if (![string]::IsNullOrWhitespace($edition)) {
                $edition = $edition + ", " + $beq_note
            } else {
                $edition = $beq_note
            }
        }
    }
    if ($beqMetadata.beq_edition -ne $edition -and "" -ne $edition) {
        $beqMetadata.beq_edition = $edition
        $save = $true
    }
    if ($beqMetadata.beq_note -ne $beq_note -and "" -ne $beq_note) {
        $beqMetadata.beq_note = $beq_note
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
        if ($file.FullName.Contains("Movie BEQs")) {
            $ItemType = "movie"
        }
        else {
            $ItemType = "tv"
        }
        $url = "https://api.themoviedb.org/3/search/" + $ItemType + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&query=$safeTitle&page=1&year=$year"
        if ($file.FullName.Contains("(Trailer)")) {
            $response = $null
            $beqMetadata = $null
        } else {
            $response = Invoke-RestMethod -Uri $url
        }
        if ($null -ne $response -and $null -ne $response.results -and $response.results.Count -ge 1) { 
            $result = $response.results[0]
            if ($beqMetadata.beq_theMovieDB -ne $result.id.ToString() -and ![string]::IsNullOrWhitespace($result.id.ToString())) {
                $beqMetadata.beq_theMovieDB = $result.id.ToString()
                $save = $true
            }
        }
    }
    if (![string]::IsNullOrWhitespace($beqMetadata.beq_theMovieDB) -and ([string]::IsNullOrWhitespace($beqMetadata.beq_title)-or [string]::IsNullOrWhitespace($beqMetadata.beq_genres.genre) -or [string]::IsNullOrWhitespace($beqMetadata.beq_runtime) -or [string]::IsNullOrWhitespace($beqMetadata.beq_overview) -or [string]::IsNullOrWhitespace($beqMetadata.beq_rating))) {
        if ($beqMetadata.beq_title -eq "Alone and Distracted") {
            $fileTitle = "Edge of Tomorrow"
        } else {
            $fileTitle = $file.Name.SubString(0, $file.Name.IndexOf("(")).Trim()
        }
        Write-Output "$($file.Name) missing TMDB metadata content"
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing TMDB metadata content"
        if ($file.FullName.Contains("Movie")) {
            $ItemType = "movie"
        }
        else {
            $ItemType = "tv"
        }
        $url = "https://api.themoviedb.org/3/" + $ItemType + "/" + $beqMetadata.beq_theMovieDB + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
        if ($file.FullName.Contains("(Trailer)")) {
            $result = $null
            $beqMetadata = $null
        } else {
            $result = Invoke-RestMethod -Uri $url
        }
        if ($null -ne $result) { 
            if ($ItemType -eq "tv") {
                if ($beqMetadata.beq_title -ne $result.name) {
                    $beqMetadata.beq_title = $result.name
                    Write-Output "Updating title to $($beqMetadata.beq_title)"
                    $save = $true
                }
                # Todo Figure out season data
                $season = 1
                if ($fileName.IndexOf("(S0)") -ge 0 -or $fileName.IndexOf("(S00)") -ge 0) {
                    $season = 0
                }
                elseif ($fileName.IndexOf("(S1)") -ge 0 -or $fileName.IndexOf("(S01)") -ge 0) {
                    $season = 1
                }
                elseif ($fileName.IndexOf("(S2)") -ge 0 -or $fileName.IndexOf("(S02)") -ge 0) {
                    $season = 2
                }
                elseif ($fileName.IndexOf("(S3)") -ge 0 -or $fileName.IndexOf("(S03)") -ge 0) {
                    $season = 3
                }
                elseif ($fileName.IndexOf("(S4)") -ge 0 -or $fileName.IndexOf("(S04)") -ge 0) {
                    $season = 4
                }
                elseif ($fileName.IndexOf("(S5)") -ge 0 -or $fileName.IndexOf("(S05)") -ge 0) {
                    $season = 5
                }
                $beqMetadata.beq_season.SetAttribute("id", $result.seasons[$season-1].id)
                $beqMetadata.beq_season.number = "$season"
                $poster = $result.seasons[$season-1].poster_path
                $beqMetadata.beq_season.poster = "$poster"
                $episodeCount = $result.seasons[$season-1].episode_count
                $beqMetadata.beq_season.episodes.SetAttribute("count", $episodeCount)
                $Episodes = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20"
                switch ($episodeCount)
                {
                    1  { $Episodes = '1'    }
                    2  { $Episodes = '1,2'   }
                    3  { $Episodes = '1,2,3' }
                    4  { $Episodes = '1,2,3,4'  }
                    5  { $Episodes = '1,2,3,4,5'    }
                    6  { $Episodes = '1,2,3,4,5,6'  }
                    7  { $Episodes = '1,2,3,4,5,6,7'  }
                    8  { $Episodes = '1,2,3,4,5,6,7,8'  }
                    9  { $Episodes = '1,2,3,4,5,6,7,8,9'  }
                    10 { $Episodes = '1,2,3,4,5,6,7,8,9,10'  }
                    11 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11'  }
                    12 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12'  }
                    13 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13'  }
                    14 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13,14'  }
                    15 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15'  }
                    16 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16'  }
                    17 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17'  }
                    18 { $Episodes = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'  }
                    19 { $Episodes = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19"  }
                }
                $beqMetadata.beq_season.episodes.InnerText = $Episodes
                $save = $true

            } else {
                if ($beqMetadata.beq_title -ne $result.title) {
                    $beqMetadata.beq_title = $result.title
                    Write-Output "Updating title to $($beqMetadata.beq_title)"
                    $save = $true
                }
            }
            if ($beqMetadata.beq_title -ne $fileTitle -and $beqMetadata.beq_alt_title -ne $fileTitle) {
                $beqMetadata.beq_alt_title = $fileTitle
                Write-Output "Updating alt title to $($beqMetadata.beq_alt_title)"
                $save = $true
            }
            if ($beqMetadata.beq_poster -ne $result.poster_path -and ![string]::IsNullOrWhitespace($result.poster_path)) {
                $beqMetadata.beq_poster = $result.poster_path
                $save = $true
            }
            if ($beqMetadata.beq_overview -ne $result.overview) {
                $beqMetadata.beq_overview = $result.overview
                Write-Output "$($beqMetadata.beq_overview)"
                Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($beqMetadata.beq_overview)"
                $save = $true
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
                $collectionNode.InnerText = $result.belongs_to_collection.name.Replace(":", "")
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
        $audio = $audio.Replace("AC3", "DD")
    }
    elseif ($fileName.IndexOf("DD EX") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DD EX"))
    }
    elseif ($fileName.IndexOf("DD 5") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DD 5"))
    }
    elseif ($fileName.IndexOf("DD 2") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("DD 2"))
    }
    elseif ($fileName.IndexOf("AAC ") -ge 0) {
        $audio = $fileName.SubString($fileName.IndexOf("AAC "))
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
    if ($save) {
        $content.Save($file.FullName)
    } else {
        #Write-Output "No Change: $($file.Name)"
    }
    if ($file.Name -eq "009 Re Cyborg (2012)(Ja) DTS-HD MA 5.1.xml") {
        #break
    }
}