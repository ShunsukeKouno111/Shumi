function Update-SourceLink {
    Param(
        [String]
        $SourceLink
    )
    $githubLink = $SourceLink -replace "`"source:trunk/", "https://github.com/ISID/iQUAVIS/blob/master/"
    $githubLink = $githubLink.Substring(0, $githubLink.Length - 1)
    return $githubLink
}
$moji1 = "`"source:trunk/src/net/Script/Net-Build.ps1`""
$moji2 = "`"source:trunk/src/net/Script/Net-Build.ps1@149657`""
$replaceMoji1 = [regex]::Replace($moji1, "`"source:trunk/[^@]+`"", { Update-SourceLink($args[0].Groups[0].Value) })
$replaceMoji2 = [regex]::Replace($moji2, "`"source:trunk/[^@]+`"", { Update-SourceLink($args[0].Groups[0].Value) })
$replaceMoji1
$replaceMoji2
