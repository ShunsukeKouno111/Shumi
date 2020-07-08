$filepass = "D:\work\wiki_contents_id.log"
foreach ($line in Get-Content $filepass) {  
    if($line -match "[0-9]+"){
        $tmp = $line.Trim("|")
        $tmp.Trim() | Out-File  D:\work\wiki_contents_id_only_num_bcp.txt -Append -encoding UTF8
    }
}
