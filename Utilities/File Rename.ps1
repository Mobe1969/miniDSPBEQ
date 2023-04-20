$files = Get-ChildItem "E:\Video\Temp\Video\YouTube\Video\ENG SUB《臥底毒師》Undercover Drug Maker( 50集全，已完結)"
foreach ($file in $files) {
    if ($file.Name.Contains("ENG SUB#絕命毒師 《臥底毒師》▶EP ")) {
        Rename-Item -Path $file.FullName -NewName $file.Name.Replace("ENG SUB#絕命毒師 《臥底毒師》▶EP ", "The Drug Hunter S01E").Replace(" 頂級天才制毒師臥底販毒黑幫☠️💉金三角上演驚險刺激#無間道 ⚠️#破冰行動 姊妹篇🌟#于和偉 #徐崢 #吳秀波 # FULL 4K", "")
    }
}
