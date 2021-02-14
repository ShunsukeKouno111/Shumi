function Add-GitIgnore {
    <#
    .Synopsis
        gitignoreを作成します。
    .Description
        svn:ignoreを読み取り、それに対応するgitignoreを配置してsvn:addを行います。
    .Outputs
        無し
    .Parameter InputDir
        対象となるSVNリポジトリのパスです。
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        $InputDir
    )

    $callSVN = {
        try {
            $svnValue = Invoke-Expression "svn.exe $($args[0])"
        }
        catch { $svnInfoError = $_ }
        if ($lastExitCode -ne 0) {
            throw $svnInfoError
        }
        return $svnValue
    }

    & $callSVN "cleanup `"$InputDir`" --remove-unversioned"

    # MEMO : svn.exe propgetコマンドでsvn:ignore一覧を出力しています。下記のようにフォルダとignoreする文字列が出力がされます。
    # branches\3.3.4\src - CI-Result
    # EnvSetup.user.ps1
    #
    # branches\3.3.4\src\net - coverage
    # ...
    $svnGitignore = & $callSVN "propget -R svn:ignore `"$InputDir`""
    if ($svnGitignore -isnot [array] ) {
        $svnGitignore = @($svnGitignore)
    }

    $delimiter = ' - '
    foreach ($line in $svnGitignore) {
        # MEMO : svn.exe propgetの出力で、値がない行を区切りとして判定しています。
        if (-not $line) {
            $gitignoreFilePath = Join-Path $gitignoreDirectory ".gitignore"
            $gitignoreString | Out-File -Encoding UTF8 $gitignoreFilePath -Force
            $svnStatus = & $callSVN "status -v `"$gitignoreFilePath`""
            # MEMO : SVNバージョン管理外のgitignoreのみsvn:addします。
            $UNVERSIONED = '?'
            if ($UNVERSIONED -eq $svnStatus.Split(' ')[0]) {
                & $callSVN "add `"$gitignoreFilePath`""
            }
        }
        elseif ($line.Contains($delimiter)) {
            $array = $line -split $delimiter
            $gitignoreDirectory = $array[0]
            $gitignoreString = $array[1]
        }
        elseif ($line) {
            $gitignoreString = $gitignoreString + [Environment]::NewLine + $line
        }
        else {
            Write-Error "Unexpected value:$line"
        }
    }
}

Add-GitIgnore "D:\TeamSVN\pjm-dev"
