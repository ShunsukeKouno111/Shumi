function Update-RerationalRevision {
    Param(
        [String]
        $CsvRootURL,
        [String]
        $SVNRootURL
    )

    & (Join-Path $PSScriptRoot 'ModuleLoader.ps1')
    Set-DBInstance "localhost\SQLEXPRESS"

    $timeLog = Join-Path $PSScriptRoot "timestamp.log"
    $errorLogPath = Join-Path $PSScriptRoot "notFoundRelationRevision.log"
    $revision_hash = @{ }
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
                $date = Get-Date
                "$script:count revision imported. time:$date" | Out-File $timeLog -Append -encoding UTF8
            }
        }
        "imported $parentDirName mapping file."
    }
    "imported mapping file."
    function Get-HashRepository {
        Param(
            [String]
            $revision
        )
        return $revision_hash[$revision]
    }

    $mySqlDllPath = Join-Path ${env:ProgramFiles(x86)} "MySQL\*Connector Net 8.0*\Assemblies\v4.5.2\MySql.Data.dll"
    if (-not (Test-Path $mySqlDllPath)) {
        Invoke-ChocoInstall -PackageName "mysql-connector" -Version 8.0.20
    }
    Add-Type -Path $mySqlDllPath

    $DB_NAME = "redmine"
    $MY_SQL_CONNECTION_STRING = "Server=localhost;Database=$($DB_NAME);Uid=root;Pwd=abcdefgH123" # MySQLのrootアカウントのパスワードで****を更新します。
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
    $tableName = "changesets_issues"
    $changesetsIssues = New-Object System.Collections.ArrayList

    $tableInfo = Get-AppDBSelectStatement -DatabaseName $DB_NAME -TableName $tableName # 対象テーブルを絞る場合は -TableName オプションを利用します。
    $tableInfo | ForEach-Object {
        $sql = $_.Sql
        if (-not ($sql.Contains("ORDER BY"))) {
            $sql = $sql -replace '^SELECT\s+(\[\w+\]).+$', '$0 ORDER BY issue_id;'
        }
        $schemaName = "[$($_.SchemaName)]"
        try {
            $mySqlCommandResult = & $getMySqlDbCommand
            $command = $mySqlCommandResult.Command
            $command.CommandText = & $toMySqlQuery $sql $schemaName
            $script:count = 0
            Invoke-SqlDataReader -DatabaseName $DB_NAME -Sql $sql -Action {
                $mySqlValues = & $getReaderValues $args[0]
                $changesets_issues = New-Object PSCustomObject -Property @{changeset_id = ""; issue_id = "" }
                $changesets_issues.changeset_id = $mySqlValues[0]
                $changesets_issues.issue_id = $mySqlValues[1]
                $changesetsIssues.Add($changesets_issues) > $null
                $script:count++
                if ($script:count % 10000 -eq 0) {
                    "$script:count changesets_issues added."
                    $date = Get-Date
                    "$script:count changesets_issues added. time:$date" | Out-File $timeLog -Append -encoding UTF8
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
            $changesets = New-Object System.Collections.ArrayList
            $count = 0
            for ($count; $count -lt $changesetsIssues.Count; ) {
                $nowIssueId = $changesetsIssues[$count].issue_id
                "Adding #$nowIssueId's changesets."
                $sql = "select changesets.id,changesets.revision,changesets.comments,REPO.url,REPO.root_url,REPO.project_id
                from changesets
                inner join repositories REPO
                on changesets.repository_id = REPO.id
                where root_url ='$SVNRootURL' and"
                for ($count ; $count -le $changesetsIssues.Count; ) {
                    $nowChangesetsIssue = $changesetsIssues[$count]
                    if ($nowIssueId -eq $nowChangesetsIssue.issue_id -and $count -ne $changesetsIssues.Count) {
                        $changeset_id = $nowChangesetsIssue.changeset_id
                        $sql += " changesets.id = $changeset_id or"
                        $count++
                    }
                    else {
                        $sql = $sql.Substring(0, $sql.Length - 3) + ";"
                        $mySqlCommandResult = & $getMySqlDbCommand
                        $command = $mySqlCommandResult.Command
                        $command.CommandText = & $toMySqlQuery $sql $schemaName
                        Invoke-SqlDataReader -DatabaseName $DB_NAME -Sql $sql -Action {
                            $mySqlValues = & $getReaderValues $args[0]
                            $changeset = New-Object PSCustomObject -Property @{
                                id       = $mySqlValues[0];
                                issue_id = $nowIssueId;
                                revision = $mySqlValues[1];
                                comments = $mySqlValues[2]
                            }
                            if ($changeset.comments.Contains("https://github.com") -eq $false) {
                                $changesets.Add($changeset) > $null
                            }
                        }
                        break
                    }
                    if ($count % 10000 -eq 0) {
                        "$script:count changesets added."
                        $date = Get-Date
                        "$script:count changesets added. time:$date" | Out-File $timeLog -Append -encoding UTF8
                    }
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
        $ticketNumber = 0
        $script:count = 0
        try {
            foreach ($changeset in $changesets) {
                if ($ticketNumber -ne $changeset.issue_id) {
                    "#$ticketNumber is updated."
                    $ticketNumber = $changeset.issue_id
                    "#$ticketNumber is updating."
                    $script:count++
                }
                if ($script:count % 10000 -eq 0) {
                    $date = Get-Date
                    "$script:count issues updated. time:$date" | Out-File $timeLog -Append -encoding UTF8
                }
                $hash_repository = Get-CommitHash $changeset.revision
                $hash = $hash_repository.Keys
                $repository = "https://github.com/ISID/$($hash_repository.Values)"
                if ($null -eq $hash) {
                    "ticket number:$($changeset.issue_id) revision:$($changeset.revision) isn't found." | Out-File $errorLogPath -Append -encoding UTF8
                }
                else {
                    $comments = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($changeset.comments)
                    $mySqlCommandResult = & $getMySqlDbCommand
                    $command = $mySqlCommandResult.Command
                    $shortHash = $hash.SubString(0, 7)
                    $updateSql = "UPDATE changesets set comments = '""$shortHash"":$repository/commit/$hash`r`n$comments' where id = $($changeset.id);"
                    $command.CommandText = $updateSql
                    $command.ExecuteNonQuery() > $null
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
}

Update-RerationalRevision "D:\GitRepository\mappingfile\pjm-dev" "http://ksvnrp05.isid.co.jp/pjm-dev"
$date = Get-Date
"pjm-dev finished. time:$date" | Out-File $timeLog -Append -encoding UTF8
Update-RerationalRevision "D:\GitRepository\mappingfile\iquavis-plugin" "http://ksvnrp16.isid.co.jp/iquavis-plugin"
$date = Get-Date
"iquavis-plugin finished. time:$date" | Out-File $timeLog -Append -encoding UTF8
