"https://gitlab.com/Mobe1969/beq-reports/-/raw/master" + [uri]::EscapeDataString($report.FullName.Replace("D:\BEQ\Mobe\beq-reports", "").Replace("\", "/")).Replace("%2F", "/")

D:\BEQ\Mobe\beq-reports\TV Series\Black Sails\Season 1
#$id = "1437"

#$id = "34967" # Falling skies
$id = "72844"
$id = "77236"
#$id = "65708" # Taboo
#$id = "84661" # The Outsider
$id = "58928"
$url = "https://api.themoviedb.org/3/tv/" + $id + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
$result = Invoke-RestMethod -Uri $url

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
$x = '<beq_season id="' + $result.seasons[2].id + '">
    <number>4</number>
    <poster>' + $result.seasons[2].poster_path + '</poster>
    <episodes count="' + $result.seasons[2].episode_count + '"></episodes>
</beq_season>'
$x
$x = '<beq_season id="' + $result.seasons[2].id + '">
    <number>5</number>
    <poster>' + $result.seasons[2].poster_path + '</poster>
    <episodes count="' + $result.seasons[2].episode_count + '"></episodes>
</beq_season>'
$x



$x = '<beq_season id="' + $result.seasons[1].id + '">
    <number>1</number>
    <poster>' + $result.seasons[1].poster_path + '</poster>
    <episodes count="' + $result.seasons[1].episode_count + '"></episodes>
</beq_season>'
$x
$x = '<beq_season id="' + $result.seasons[2].id + '">
        <number>2</number>
        <poster>' + $result.seasons[2].poster_path + '</poster>
        <episodes count="' + $result.seasons[2].episode_count + '"></episodes>
    </beq_season>'
$x