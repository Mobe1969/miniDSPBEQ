if ([System.IO.File]::Exists("D:\BEQ\Errors.txt")) {
    Clear-Content -Path "D:\BEQ\Errors.txt"
}

$id = "220932"
$url = "https://api.themoviedb.org/3/tv/" + $id + "?api_key=ac56a60e0c35557f7b8065bc996d77fc&language=en-US&append_to_response=release_dates"
$result = Invoke-RestMethod -Uri $url
$x = '    <beq_season id="' + $result.seasons[0].id + '">
        <number>1</number>
        <poster>' + $result.seasons[0].poster_path + '</poster>
        <episodes count="' + $result.seasons[0].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20</episodes>
    </beq_season>'
$x
Add-Content -Path "D:\BEQ\Errors.txt" -Value $x


$x = '    <beq_season id="' + $result.seasons[1].id + '">
        <number>2</number>
        <poster>' + $result.seasons[1].poster_path + '</poster>
        <episodes count="' + $result.seasons[1].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20</episodes>
    </beq_season>'
$x
Add-Content -Path "D:\BEQ\Errors.txt" -Value $x


$x = '    <beq_season id="' + $result.seasons[2].id + '">
        <number>3</number>
        <poster>' + $result.seasons[2].poster_path + '</poster>
        <episodes count="' + $result.seasons[2].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20</episodes>
    </beq_season>'
$x
Add-Content -Path "D:\BEQ\Errors.txt" -Value $x


$x = '    <beq_season id="' + $result.seasons[3].id + '">
        <number>4</number>
        <poster>' + $result.seasons[3].poster_path + '</poster>
        <episodes count="' + $result.seasons[3].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20</episodes>
    </beq_season>'
$x
Add-Content -Path "D:\BEQ\Errors.txt" -Value $x


$x = '    <beq_season id="' + $result.seasons[4].id + '">
        <number>5</number>
        <poster>' + $result.seasons[4].poster_path + '</poster>
        <episodes count="' + $result.seasons[4].episode_count + '">1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20</episodes>
    </beq_season>'
$x
Add-Content -Path "D:\BEQ\Errors.txt" -Value $x







