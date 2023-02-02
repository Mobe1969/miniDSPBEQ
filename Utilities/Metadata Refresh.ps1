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


$files = Get-ChildItem "D:\BEQ\miniDSPBEQ\TV BEQs" -Filter *.xml -Recurse 
if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}
foreach ($file in $files) {
    $save = $false
    $content = [System.Xml.XmlDocument](Get-Content $file.FullName -Encoding UTF8)
    $beqMetadata = $content.setting.beq_metadata
    $fileName = [io.path]::GetFileNameWithoutExtension($file.Name)

    if ($beqMetadata.beq_title -eq "Alone and Distracted") {
        $fileTitle = "Edge of Tomorrow"
    } else {
        $fileTitle = $file.Name.SubString(0, $file.Name.IndexOf("(")).Trim()
    }
    Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($file.Name) missing TMDB metadata content"
    $ItemType = "tv"
    $url = "https://api.themoviedb.org/3/" + $ItemType + "/" + $beqMetadata.beq_theMovieDB + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
    if ($file.FullName.Contains("(Trailer)")) {
        $result = $null
        $beqMetadata = $null
    } else {
        $result = Invoke-RestMethod -Uri $url
    }
    if ($null -ne $result) { 
        if ($beqMetadata.beq_overview -ne $result.overview) {
            $beqMetadata.beq_overview = $result.overview
            Write-Output "$($beqMetadata.beq_overview)"
            Add-Content -Path "D:\BEQ\Errors.txt" -Value "$($beqMetadata.beq_overview)"
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
    if ($save) {
        $content.Save($file.FullName)
    } else {
        #Write-Output "No Change: $($file.Name)"
    }
}