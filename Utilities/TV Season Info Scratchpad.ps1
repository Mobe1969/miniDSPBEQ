"https://gitlab.com/Mobe1969/beq-reports/-/raw/master" + [uri]::EscapeDataString($report.FullName.Replace("D:\BEQ\Mobe\beq-reports", "").Replace("\", "/")).Replace("%2F", "/")

D:\BEQ\Mobe\beq-reports\TV Series\Black Sails\Season 1

$url = "https://api.themoviedb.org/3/tv/62264?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
$result = Invoke-RestMethod -Uri $url


$result.seasons[0].id
$result.seasons[0].poster_path

$result.seasons[1].id
$result.seasons[1].poster_path


$result.seasons[2].id
$result.seasons[2].poster_path


$result.seasons[3].id
$result.seasons[3].poster_path


$x = '<beq_season id="' + $result.seasons[0].id + '">
    <number>1</number>
    <poster>' + $result.seasons[0].poster_path + '</poster>
    <episodes count="' + $result.seasons[0].episode_count + '"></episodes>
</beq_season>'
$x
$x = '<beq_season id="' + $result.seasons[1].id + '">
    <number>2</number>
    <poster>' + $result.seasons[1].poster_path + '</poster>
    <episodes count="' + $result.seasons[1].episode_count + '"></episodes>
</beq_season>'
$x
$x = '<beq_season id="' + $result.seasons[2].id + '">
    <number>3</number>
    <poster>' + $result.seasons[2].poster_path + '</poster>
    <episodes count="' + $result.seasons[2].episode_count + '"></episodes>
</beq_season>'
$x
