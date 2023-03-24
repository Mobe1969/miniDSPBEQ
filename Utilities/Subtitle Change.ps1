#$Search = 'Arial,40,&H00CCCCCC'
#$Replace = 'Arial,40,&H00AAAAAA'

ForEach ($File in (Get-ChildItem -Path 'D:\Video\Library\*.ass' -Recurse -File)) {
    (Get-Content $File) -Replace $Search,$Replace |
        Set-Content $File
}

[RegEx]$Search = '^PlayResY.*\d'
$Replace = 'PlayResY: 1080'
ForEach ($File in (Get-ChildItem -Path 'D:\Video\Library\*.ass' -Recurse -File)) {
    If (Get-Content $File.FullName | Select-String -Pattern "PlayResX: 1920") {
        write-output "1920x1080"
        (Get-Content $File) -Replace $Search,$Replace |
            Set-Content $File
    }
}

