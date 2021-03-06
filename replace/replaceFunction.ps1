﻿$revision_hash = @{ }
$exportFile = Join-Path $PSScriptRoot "rewritelog.csv"

function Update-SourceLink {
    Param(
        [string]
        $SourceLink,
        [string]
        $PluginName,
        [int]
        $TicketId
    )

    switch ($PluginName) {
        "/KMBT/" { $repositoryName = "iQUAVIS-KM-KMBT"; break; }
        "/KMBT/Tool/CoopVSheet" { $repositoryName = "iQUAVIS-KM-KMBT"; break; }
        "/NML_Aras" { $repositoryName = "iQUAVIS-NISSAN-ARAS"; break; }
        "/TMC/TMC_GQR" { $repositoryName = "iQUAVIS-TMC-GQR"; break; }
        "/TMC/TMC_iSpirit" { $repositoryName = "iQUAVIS-TMC-iSpirit"; break; }
        "/TMC/iSpirit" { $repositoryName = "iQUAVIS-TMC-iSpirit"; break; }
        "/TMC-iQ-System/" { $repositoryName = "iQUAVIS-TMC-TLTP"; break; }
        "/Modelica/" { $repositoryName = "iQUAVIS-Modelica"; break; }
        "" { $repositoryName = "iQUAVIS"; break; }
        Default { return $SourceLink; }
    }

    # テスト用
    #$revision_hash = Get-RevisionMappingFile "D:\GitRepository\Shumi\replace\pjm-dev"
    $mappingData = New-Object PSCustomObject -Property @{ id = $TicketId; svn = $SourceLink; git = "" }
    $svnSourceLink = $SourceLink

    $getHashRepository = {
        return $revision_hash[$args[0]]
    }

    if ($svnSourceLink -contains "/doc/") {
        return $SourceLink
    }
    $svnSourceLink = $svnSourceLink -replace "source:(/|\\|`"/|`"\\|`"|)src", "source:trunk/src"
    $svnSourceLink = $svnSourceLink -replace "//trunk", "trunk"
    $svnSourceLink = $svnSourceLink.Replace("\\trunk", "trunk")
    $svnSourceLink = $svnSourceLink.Replace("./trunk", "trunk")
    $svnSourceLink = $svnSourceLink.Replace("source:`" ", "source:`"")
    if ($svnSourceLink.Contains("../diff/")) {
        $svnSourceLink = $svnSourceLink -replace "../diff/", ""
    }
    if ($svnSourceLink.Contains("/diff/")) {
        $svnSourceLink = $svnSourceLink -replace "/diff/", ""
    }
    if ($svnSourceLink.Contains("pjm:")) {
        $svnSourceLink = $svnSourceLink -replace "pjm:", ""
    }
    if ($svnSourceLink.Contains("iq-core:")) {
        $svnSourceLink = $svnSourceLink -replace "iq-core:", ""
    }
    if ($svnSourceLink.Contains("`"/")) {
        $svnSourceLink = $svnSourceLink -replace "`"/", "`""
    }
    if ($svnSourceLink.Contains("TeamSVN")) {
        $svnSourceLink = $svnSourceLink -replace "TeamSVN", ""
    }
    if ($svnSourceLink.Contains("pjm-dev")) {
        $svnSourceLink = $svnSourceLink -replace "pjm-dev", ""
    }



    if ($svnSourceLink.Contains("../revisions/")) {
        $array = $svnSourceLink -split "/"
        $script:count = 0
        foreach ($value in $array) {
            if ($value -eq "revisions") {
                $revision = $array[$script:count + 1]
                break
            }
            $script:count++
        }
        $svnSourceLink = $svnSourceLink.TrimEnd() -replace "../revisions/\d{1,6}/diff/", ""
        $svnSourceLink = "$svnSourceLink@$revision"
    }

    #ケース2,3,5,6,8,9,11,12
    if ($svnSourceLink.Contains("@")) {
        $array = $svnSourceLink -split "(/|\\|)(trunk|branches/.*?)/" -split "@" -split "#"
        $directoryPath = $array[3]
        if ($svnSourceLink -match "@\d{1,6}") {
            $revision = $Matches[0] -replace "@", ""
        }
        if (-not $revision) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        if ($svnSourceLink -match "(#|)L\d{1,4}") {
            $line = $Matches[0] -replace "#", ""
        }
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        if (-not $hash_repository.Values) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        $githubLink = "$($hash_repository.Values)/commit/$($hash_repository.keys)#diff-$md5$line"

    }
    elseif ($svnSourceLink.Contains("rev_to")) {
        $array = $svnSourceLink -split "(/|\\|)(trunk|branches/.*?)/" -split "(\\|).rev=" -split ".rev_to(=|)"
        $directoryPath = $array[3]
        $revision = $array[5] -replace "`"", ""
        $toRevision = $array[7] -replace "`"", ""
        if (-not $revision) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        if (-not $hash_repository.Values) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        $toHash_repository = & $getHashRepository $toRevision.Trim()
        $githubLink = "$($hash_repository.Values)/compare/$($hash_repository.keys)...$($toHash_repository.keys)#diff-$md5"
    }
    elseif ($svnSourceLink.Contains("?rev=")) {
        $array = $svnSourceLink -split "(/|\\|)(trunk|branches/.*?)/" -split "(\\|).rev=" -split "#"
        $directoryPath = $array[3]
        $revision = $array[5] -replace "`"", ""
        $line = $array[6] -replace "`"", ""
        if (-not $revision) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        $md5 = Get-MD5Hash $directoryPath
        $hash_repository = & $getHashRepository $revision.Trim()
        if (-not $hash_repository.Values) {
            $mappingData.git = $githubLink
            $outputCsv += $mappingData
            return $SourceLink
        }
        $githubLink = "$($hash_repository.Values)/commit/$($hash_repository.keys)#diff-$md5$line"
    }
    #ケース1
    elseif ($svnSourceLink -match "source:(`"/|`"\\|`"|/|\\|//|)trunk(/|\\)") {
        $githubLink = $svnSourceLink -replace "source:(`"/|`"\\|`"|/|\\|)trunk(/|\\)", "https://github.com/ISID/$repositoryName/blob/master/"
        $githubLink = $githubLink.Replace("TMC.", "TMC_")
    }
    #ケース4
    elseif ($svnSourceLink -match "source:(`"/|`"\\|`"|/|\\|//|)branches(/|\\)") {
        $githubLink = $svnSourceLink -replace "source:(`"/|`"\\|`"|/|\\|)branches(/|\\)", "https://github.com/ISID/$repositoryName/blob/"
        $githubLink = $githubLink.Replace("TMC.", "TMC_")
    }
    #ケース7,10
    elseif ($svnSourceLink -match "source:(`"/|`"\\|`"|/|\\|//|)plugin(/|\\)([^/]*?)") {
        $githubLink = $svnSourceLink -replace "source:(`"/|`"\\|`"|/|\\|//|)plugin(/|\\)([^/]*?)", "https://github.com/ISID/iQUAVIS-" #ケース7
        $githubLink = $githubLink -replace "trunk", "blob/master" #ケース7
        $githubLink = $githubLink -replace "branches", "blob" #ケース10
    }
    else {
        $githubLink = $SourceLink
    }
    if ($githubLink.Contains("#L")) {
        $githubLink = $githubLink -replace "#", ""
    }
    if ($githubLink -ne $SourceLink) {
        $githubLink = $githubLink -replace "`"", ""
        $githubLink = $githubLink + " "
    }

    $mappingData.git = $githubLink
    $mappingData | Export-Csv $exportFile -Append -encoding UTF8

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
        $Description,
        [string]
        $PluginName,
        [int]
        $TicketId
    )

    $updatedDescription = [regex]::Replace($Description, "(pjm:|iq-core:|)source:`"(|\r|\n|\r\n).+?`"", { Update-SourceLink -SourceLink $args[0].Groups[0].Value -PluginName $PluginName -TicketId $TicketId })
    $updatedDescription = [regex]::Replace($updatedDescription, "(pjm:|iq-core:|)source:(|\r|\n|\r\n).+?(\s|\r|\n|\r\n)", { Update-SourceLink -SourceLink $args[0].Groups[0].Value -PluginName $PluginName -TicketId $TicketId })
    return $updatedDescription
}

function Update-RedmineSourceLink {
    Param(
        [String]
        $CsvRootURL,
        [String]
        $SVNRootURL
    )

    & (Join-Path $PSScriptRoot 'ModuleLoader.ps1')
    Set-DBInstance "localhost\SQLEXPRESS"

    $errorLogPath = Join-Path $PSScriptRoot "error.log"
    $timeLog = Join-Path $PSScriptRoot "timestamp.log"
    $script:count = 0

    "importing mapping file."
    $csvfiles = Get-ChildItem $CsvRootURL -Recurse | Where-Object { $_.Extension -eq ".csv" }
    foreach ($csvfile in $csvfiles) {
        $csv = Import-Csv $csvfile.FullName
        $parentDirName = Split-Path (Split-Path $csvfile.FullName -Parent) -Leaf
        $repositoryPath = "https://github.com/ISID/$parentDirName"
        "importing $parentDirName mapping file."
        foreach ($csvline in $csv) {
            $script:count++
            $revision = $csvline.revision
            $branch = $csvline.branch
            $hash_repository = @{ }
            $hash_repository.Add($csvline.hash, $repositoryPath) | Out-Null
            if ($revision_hash.ContainsKey($revision)) {
                if ($branch -eq "refs/svn/root/trunk") {
                    $revision_hash.Remove($revision) | Out-Null
                    $revision_hash.Add($revision, $hash_repository) | Out-Null
                }
            }
            elseif ($branch -ne '') {
                $revision_hash.Add($revision, $hash_repository) | Out-Null
            }
            if ($script:count % 10000 -eq 0) {
                "$script:count revision imported."
                $date = Get-Date
                "$script:count revision imported. time:$date" | Out-File $timeLog -Append -encoding UTF8
            }
        }
        "imported $parentDirName mapping file."
    }
    "imported mapping file."

    $mySqlDllPath = Join-Path ${env:ProgramFiles(x86)} "MySQL\*Connector Net 8.0*\Assemblies\v4.5.2\MySql.Data.dll"
    if (-not (Test-Path $mySqlDllPath)) {
        Invoke-ChocoInstall -PackageName "mysql-connector" -Version 8.0.20
    }
    Add-Type -Path $mySqlDllPath

    $DB_NAME = "redmine"
    $MY_SQL_CONNECTION_STRING = "Server=localhost; Database=$($DB_NAME); Uid=root; Pwd=abcdefgH123" # MySQLのrootアカウントのパスワードで****を更新します。
    $getReaderValues = {
        $reader = $args[0]
        $values = New-Object object[] ($reader.FieldCount)
        $reader.GetValues($values) | Out-Null
        return $values
    }

    $toMySqlQuery = {
        return $args[0].Replace("$($args[1]).", [string]::Empty).Replace('[', '`').Replace(']', '`')
    }

    $getMySqlDbCommand = {
        $result = @{
            Command = $null;
            Cleanup = $null;
        }
        $mySqlConn = New-Object MySql.Data.MySqlClient.MySqlConnection $MY_SQL_CONNECTION_STRING
        $mySqlCommand = $mySqlConn.CreateCommand()
        $mySqlCommand.CommandTimeout = 0
        $mySqlConn.Open()
        $result.Command = $mySqlCommand
        $result.Cleanup = {
            if ($mySqlCommand) { $mySqlCommand.Dispose() }
            if ($mySqlConn) { $mySqlConn.Close() }
        }.GetNewClosure()
        return $result
    }

    $sql = "select ISSUES.Id, ISSUES.description, REPO.url, REPO.root_url, ISSUES.project_id
        from ISSUES
        inner join repositories REPO
        on ISSUES.project_id = REPO.project_id
        where REPO.root_url ='$SVNRootURL'
        order by ISSUES.Id; "
    $schemaName = "[dbo]"
    try {
        $mySqlCommandResult = & $getMySqlDbCommand
        $command = $mySqlCommandResult.Command
        $command.CommandText = & $toMySqlQuery $sql $schemaName
        $script:count = 0
        $changedIssues = New-Object System.Collections.ArrayList
        $mySqlReader = $command.ExecuteReader()
        while ($mySqlReader.Read()) {
            $mySqlValues = & $getReaderValues $mySqlReader
            if ($mySqlValues -isnot [array]) {
                $mySqlValues = @($mySqlValues)
            }
            $issue = New-Object PSCustomObject -Property @{id = ""; description = "" }
            $issue.id = $mySqlValues[0]
            $originalDescription = $mySqlValues[1]
            if ($SVNRootURL.Contains("iquavis-plugin")) {
                $pluginName = $mySqlValues[2] -replace $mySqlValues[3], ""
            }
            $issue.description = Update-DescriptionSourceLink -Description $originalDescription -PluginName $pluginName -TicketId $issue.id
            if ($originalDescription -ne $issue.description) {
                $changedIssues.Add($issue) | Out-Null
            }
            $script:count++
            if ($script:count % 10000 -eq 0) {
                "$script:count issues is checked."
                $date = Get-Date
                "$script:count issues is checked. time:$date" | Out-File $timeLog -Append -encoding UTF8
            }
            trap {
                Out-File -InputObject $issue.id -FilePath $errorLogPath -Append -encoding UTF8
                break
            }
        }
    }
    finally {
        if ($mySqlCommandResult) {
            $mySqlCleanup = $mySqlCommandResult.Cleanup
            if ($mySqlCleanup) {
                & $mySqlCleanup
            }
        }
    }

    try {
        $script:count = 0
        foreach ($issue in $changedIssues) {
            "#$($issue.id) is updating."
            $description = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($issue.description)
            $mySqlCommandResult = & $getMySqlDbCommand
            $command = $mySqlCommandResult.Command
            $updateSql = "UPDATE issues set description = '$description' where id = $($issue.id); "
            $command.CommandText = $updateSql
            $command.ExecuteNonQuery() | Out-Null
            "#$($issue.id) is updated."
            $script:count++
            if ($script:count % 1000 -eq 0) {
                "$script:count issues is updated."
                $date = Get-Date
                "$script:count issues is updated. time:$date" | Out-File $timeLog -Append -encoding UTF8
            }
            if ($mySqlCommandResult) {
                $mySqlCleanup = $mySqlCommandResult.Cleanup
                if ($mySqlCleanup) {
                    & $mySqlCleanup
                }
            }
            trap {
                Out-File -InputObject $updateSql -FilePath $errorLogPath -Encoding (COnvertTo-EncodingParameter (New-Object Text.UTF8Encoding $true)) -NoNewLine
                break
            }
        }
    }
    finally {
        if ($mySqlCommandResult) {
            $mySqlCleanup = $mySqlCommandResult.Cleanup
            if ($mySqlCleanup) {
                & $mySqlCleanup
            }
        }
    }
}

Update-RedmineSourceLink -CsvRootURL "D:\GitRepository\mappingfile\pjm-dev" -SVNRootURL "http://ksvnrp05.isid.co.jp/pjm-dev"
Update-RedmineSourceLink -CsvRootURL "D:\GitRepository\mappingfile\iquavis-plugin" -SVNRootURL "http://ksvnrp16.isid.co.jp/iquavis-plugin"
