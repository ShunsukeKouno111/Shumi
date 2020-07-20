$revision_hash = @{ }

function Update-SourceLink {
    Param(
        [string]
        $SourceLink
    )

    $revision_hash = Get-RevisionMappingFile "D:\GitRepository\Shumi\replace\pjm-dev"

    $getHashRepository = {
        return $revision_hash[$args[0]]
    }

    if ($SourceLink.Contains("/doc/")) {
        return $SourceLink
    }
    if ($SourceLink.Contains("../diff/")) {
        $SourceLink = $SourceLink -replace "../diff/", ""
    }
    if ($SourceLink.Contains("pjm:source")) {
        $SourceLink = $SourceLink -replace "pjm:", ""
    }
    if ($SourceLink.Contains("\")) {
        $SourceLink = $SourceLink -replace "\\", "\\"
    }
    if ($SourceLink.Contains("../revisions/")) {
        $array = $SourceLink -split "/"
        $script:count = 0
        foreach ($value in $array) {
            if ($value -eq "revisions") {
                $revision = $array[$script:count + 1]
                break
            }
            $script:count++
        }
        $SourceLink = $SourceLink.TrimEnd() -replace "../revisions/\d{1,6}/diff/", ""
        $SourceLink = "$SourceLink@$revision"
    }

    #ケース2,3,5,6,8,9,11,12
    if ($SourceLink.Contains("@")) {
        $array = $SourceLink -split "(trunk|branches/.*?)/" -split "@" -split "#"
        $directoryPath = $array[2]
        $revision = $array[3] -replace "`"", ""
        $line = $array[4] -replace "`"", ""
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        # MEMO : リビジョンをコミットハッシュに変換する際にTrimした文末空白を付け直すため
        # 例 : "source:trunk~~~@125670 "
        # if ((-not $line) -and ($SourceLink -notcontains "`"")) {
        #     $line = " "
        # }
        $githubLink = "$($hash_repository.Values)/commit/$($hash_repository.keys)#diff-$md5$line"
        # $githubLink = $SourceLink -replace "source:(`"|)(trunk|branches/.*?|plugin/.*?/(trunk|branches/.*?))/[^@]*?", "$($hash_repository.Values)/"
        # $githubLink = $githubLink -replace $directoryPath, ""
        # $githubLink = $githubLink -replace "@\d{1,6}", "commit/$($hash_repository.keys)#diff-$md5"
        # $githubLink = $githubLink -replace "#L", "L"

    }
    elseif ($SourceLink.Contains("?rev=")) {
        $array = $SourceLink -split "(trunk|branches/.*?)/" -split ".rev=" -split ".rev_to="
        $directoryPath = $array[2]
        $revision = $array[3] -replace "`"", ""
        $toRevision = $array[4] -replace "`"", ""
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        $toHash_repository = & $getHashRepository $toRevision.Trim()
        $githubLink = $SourceLink -replace "source:(`"|)(trunk|branches/.*?|plugin/.*?/(trunk|branches/.*?))/[^@]*?", "$($hash_repository.Values)/"
        $githubLink = $githubLink -replace $directoryPath, ""
        #?rev=172609&rev_to=171813
        $githubLink = $githubLink -replace ".rev=\d{1,6}.rev_to=\d{1,6}", "compare/$($hash_repository.keys)...$($toHash_repository.keys)#diff-$md5"
    }
    #ケース1
    elseif ($SourceLink -match "source:(`"|)trunk/") {
        $githubLink = $SourceLink -replace "source:(`"|)trunk/", "https://github.com/ISID/iQUAVIS/blob/master/"
    }
    #ケース4
    elseif ($SourceLink -match "source:(`"|)branches/") {
        $githubLink = $SourceLink -replace "source:(`"|)branches/", "https://github.com/ISID/iQUAVIS/blob/"
    }
    #ケース7,10
    elseif ($SourceLink -match "source:(`"|)plugin/([^/]*?)") {
        $githubLink = $SourceLink -replace "source:(`"|)plugin/([^/]*?)", "https://github.com/ISID/iQUAVIS-" #ケース7
        $githubLink = $githubLink -replace "trunk", "blob/master" #ケース7
        $githubLink = $githubLink -replace "branches", "blob" #ケース10
    }
    else {
        $githubLink = $SourceLink
    }
    if ($githubLink -ne $SourceLink) {
        $githubLink = $githubLink -replace "`"", ""
        $githubLink = $githubLink + " "
    }
    return $githubLink
}

function Get-MD5Hash {
    param (
        [string]
        $FilePath
    )

    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = New-Object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($FilePath)))
    return $hash.toLower().replace("-", "")

}

function Get-RevisionMappingFile {
    param (
        [string]
        $CsvRootURL
    )

    $csvfiles = Get-ChildItem $CsvRootURL -Recurse | Where-Object { $_.Extension -eq ".csv" }
    foreach ($csvfile in $csvfiles) {
        $csv = Import-Csv $csvfile.FullName
        $parentDirName = Split-Path (Split-Path $csvfile.FullName -Parent) -Leaf
        $repositoryPath = "https://github.com/ISID/$parentDirName"
        foreach ($csvline in $csv) {
            $script:count++
            $revision = $csvline.revision
            $branch = $csvline.branch
            $hash_repository = @{ }
            $hash_repository.Add($csvline.hash, $repositoryPath) > $null
            if ($revision_hash.ContainsKey($revision)) {
                if ($branch -eq "refs/svn/root/trunk") {
                    $revision_hash.Remove($revision) > $null
                    $revision_hash.Add($revision, $hash_repository) > $null
                }
            }
            elseif ($branch -ne '') {
                $revision_hash.Add($revision, $hash_repository) > $null
            }
            if ($script:count % 10000 -eq 0) {
                "$script:count revision imported."
            }
        }
    }
    return $revision_hash
}

function Update-DescriptionSourceLink {
    Param(
        [string]
        $Description
    )

    $updatedDescription = [regex]::Replace($Description, "(pjm:|)source:`".+?`"", { Update-SourceLink($args[0].Groups[0].Value) })
    $updatedDescription = [regex]::Replace($updatedDescription, "(pjm:|)source:.+?\s", { Update-SourceLink($args[0].Groups[0].Value) })
    return $updatedDescription
}
