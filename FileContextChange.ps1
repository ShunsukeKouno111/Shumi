#どこの配下を検索するかを指定します。
$basedir = "C:\UserRegistration"
#変換元の文字列を指定します。
$from = "href=`"~/"
#変換後のの文字列を指定します。
$to = "href=`"http://iqoc.ap.iquavis.com/nvh/UerRegistration/"
#変換したいファイルの拡張子を指定します。
$files = Get-ChildItem $basedir -Recurse | Where-Object { $_.Extension -eq ".cs"}
#ファイルを1つずつ見ていきます。
foreach ($item in $files) {
    #ファイルの中身を読み込み、変換します。
    $cs =  Get-Content -Encoding UTF8 $item.FullName | ForEach-Object {$_ -replace $from,$to}
    #変換後のファイルを同一ファイル名で保存します。
    $cs | Out-File -Encoding UTF8 $item.FullName
}

