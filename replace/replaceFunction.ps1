function Update-SourceLink {
    Param(
        [String]
        $SourceLink
    )
    $githubLink = $SourceLink -replace "`"source:trunk/", "https://github.com/ISID/iQUAVIS/blob/master/"
    $githubLink = $githubLink.Substring(0, $githubLink.Length - 1)
    return $githubLink
}
