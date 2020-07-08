function Update-SourceLink {
    Param(
        [String]
        $SourceLink
    )
    $githubLink = $SourceLink -replace "`"source:trunk/", "https://github.com/ISID/iQUAVIS/blob/master/"
    $githubLink = $githubLink.Substring(0, $githubLink.Length - 1)
    return $githubLink
}

function Update-DescriptionSourceLink {
    Param(
        [String]
        $Description
    )
    $updatedDescription = [regex]::Replace($Description, "`"source:.+?`"", { Update-SourceLink($args[0].Groups[0].Value) })
    return $updatedDescription
}

$SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1`" `"source:trunk/src/net/Script/Net-Build.ps1`" `"source:trunk/src/net/Script/Net-Build.ps1`" "
$GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
