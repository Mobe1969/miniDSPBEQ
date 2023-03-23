$Search = 'Arial,40,&H00CCCCCC'
$Replace = 'Arial,40,&H00AAAAAA'

ForEach ($File in (Get-ChildItem -Path 'D:\Video\Library\*.ass' -Recurse -File)) {
    (Get-Content $File) -Replace $Search,$Replace |
        Set-Content $File
}