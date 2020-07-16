$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\replaceFunction.ps1"

function Update-RedmineSourceLink {
    Param(
        [String]
        $CsvRootURL,
        [String]
        $SVNRootURL
    )

    & (Join-Path $PSScriptRoot 'ModuleLoader.ps1')
    Set-DBInstance "localhost\SQLEXPRESS"

    $errorLogPath = Join-Path $PSScriptRoot "nothinghash.log"
    $timeLog = Join-Path $PSScriptRoot "timestamp.log"
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

    $sql = "select ISSUES.Id,ISSUES.description,REPO.url,REPO.root_url,ISSUES.project_id
        from ISSUES
        inner join repositories REPO
        on ISSUES.project_id = REPO.project_id
        where root_url ='$SVNRootURL'
        order by ISSUES.Id;"
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
            $issue.description = Update-DescriptionSourceLink $originalDescription
            if ($originalDescription -ne $issue.description) {
                $changedIssues.Add($issue) > $null
            }
            $script:count++
            if ($script:count % 10000 -eq 0) {
                "$script:count issues is checked."
                $date = Get-Date
                "$script:count issues is checked. time:$date" | Out-File $timeLog -Append -encoding UTF8
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

Update-RedmineSourceLink "D:\GitRepository\mappingfile\pjm-dev" "http://ksvnrp05.isid.co.jp/pjm-dev"