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


$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ\TV BEQs" -Filter *.xml -Recurse
#$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ\Movie BEQs" -Filter *.xml -Recurse
$files = Get-ChildItem "D:\BEQ\Mobe1969_miniDSPBEQ" -Filter "*.xml" -Recurse
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
foreach ($file in $files) {
    if ($file.Name.Substring(0, 4).Equals("Flat", 3)) {
        continue
    }
    $save = $false
#    $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
    $regex = "[^\x00-\x7F]"
    $content = Get-Content $file.FullName
    if ([Regex]::IsMatch($content, $regex)) {
        Write-Output "$($file.Name) processing"
        $content = [System.Xml.XmlDocument](Get-Content $file.FullName)
        $beqMetadata = $content.setting.beq_metadata
        $reportName = [io.path]::GetFileNameWithoutExtension($file.Name)
        if ($reportName -eq "Alone and Distracted (2014) DTS-HD MA 5.1") {
            $reportName = "Edge of Tomorrow (2014)(40s) DTS-HD MA 5.1"
        }
        if ($beqMetadata.beq_title -eq "Alone and Distracted") {
            $fileTitle = "Edge of Tomorrow"
        } else {
            $fileTitle = $file.Name.SubString(0, $file.Name.IndexOf("(")).Trim()
        }
        if ($file.FullName.Contains("Movie")) {
            $report = Get-ChildItem "D:\BEQ\Mobe\beq-reports\Movies" -Filter "$reportName.jpg" -Recurse
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
            break
        }
        if ([string]::IsNullOrEmpty($beqMetadata.beq_theMovieDB)) {
            break
        }
        $year = $beqMetadata.beq_year
        Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) setting TMDB metadata content"
        if ($file.FullName.Contains("Movie")) {
            $ItemType = "movie"
        }
        else {
            $ItemType = "tv"
        }
        $url = "https://api.themoviedb.org/3/" + $ItemType + "/" + $beqMetadata.beq_theMovieDB + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
        $result = Invoke-RestMethod -Uri $url
        if ($null -ne $result) { 
            $beqMetadata.beq_overview = $result.overview
            $beqMetadata.beq_poster = $result.poster_path
            if ($ItemType -eq "tv") {
                $beqMetadata.beq_title = $result.name
            } else {
                $beqMetadata.beq_title = $result.title
            }
            if ($beqMetadata.beq_title -ne $fileTitle) {
                $beqMetadata.beq_alt_title = $fileTitle
            } else {
                $beqMetadata.beq_alt_title = ""
            }
        }
        $content.Save($file.FullName)
    }
}