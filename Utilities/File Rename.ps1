$files = Get-ChildItem "D:\Video\Library\Troubled Times Three Brothers"
foreach ($file in $files) {
    if ($file.Name.Contains("（黄渤、刘烨、张涵予、张鲁一等主演，管虎导演）")) {
        Rename-Item -Path $file.FullName -NewName $file.Name.Replace("（黄渤、刘烨、张涵予、张鲁一等主演，管虎导演）", "").Replace(" 頂級天才制毒師臥底販毒黑幫☠️💉金三角上演驚險刺激#無間道 ⚠️#破冰行動 姊妹篇🌟#于和偉 #徐崢 #吳秀波 # FULL 4K", "")
    }
}
