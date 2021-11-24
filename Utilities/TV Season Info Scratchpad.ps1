
$id = "54155"
$url = "https://api.themoviedb.org/3/tv/" + $id + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
$result = Invoke-RestMethod -Uri $url

$x = '    <beq_season id="' + $result.seasons[0].id + '">
        <number>1</number>
        <poster>' + $result.seasons[0].poster_path + '</poster>
        <episodes count="' + $result.seasons[0].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13</episodes>
    </beq_season>'
$x
$x = '    <beq_season id="' + $result.seasons[1].id + '">
        <number>2</number>
        <poster>' + $result.seasons[1].poster_path + '</poster>
        <episodes count="' + $result.seasons[1].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13</episodes>
    </beq_season>'
$x
$x = '    <beq_season id="' + $result.seasons[2].id + '">
        <number>3</number>
        <poster>' + $result.seasons[2].poster_path + '</poster>
        <episodes count="' + $result.seasons[2].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13</episodes>
    </beq_season>'
$x



