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

    if ($SourceLink.Contains("@")) {
        #ケース2,3,5,6,8,9,11,12

        $array = $SourceLink -split "(trunk|branches/.*?)/" -split "@" -split "#"
        $directoryPath = $array[2]
        $revision = $array[3] -replace "`"", ""
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        $githubLink = $SourceLink -replace "source:(`"|)(trunk|branches/.*?|plugin/.*?/trunk)/[^@]*?", "$($hash_repository.Values)/"
        $githubLink = $githubLink -replace $directoryPath, ""
        $githubLink = $githubLink -replace "@\d{1,6}", "commit/$($hash_repository.keys)#diff-$md5"
        $githubLink = $githubLink -replace "#L", "L"
    }
    else {
        $githubLink = $SourceLink -replace "source:(`"|)trunk/", "https://github.com/ISID/iQUAVIS/blob/master/" #ケース1
        $githubLink = $githubLink -replace "source:(`"|)branches/", "https://github.com/ISID/iQUAVIS/blob/" #ケース4
        $githubLink = $githubLink -replace "source:(`"|)plugin/([^/]*?)", "https://github.com/ISID/iQUAVIS-`$1" #ケース7
        $githubLink = $githubLink -replace "trunk", "blob/master" #ケース7
        $githubLink = $githubLink -replace "branches", "blob" #ケース10
    }
    $githubLink = $githubLink -replace "`"", ""
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

    #$updatedDescription = [regex]::Replace($Description, "source:(`"|).+?`"", { Update-SourceLink($args[0].Groups[0].Value) })
    $updatedDescription = [regex]::Replace($Description, "source:`".+?`"", { Update-SourceLink($args[0].Groups[0].Value) })
    $updatedDescription = [regex]::Replace($updatedDescription, "source:.+?\s", { Update-SourceLink($args[0].Groups[0].Value) })
    return $updatedDescription
}
