$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ケース1" {
    It "正しく変換できるか" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1`""
        $GitHubSourceLink = [regex]::Replace($SVNSourceLink, "`"source:trunk/[^@]+`"", { Update-SourceLink($args[0].Groups[0].Value) })
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/master/src/net/Script/Net-Build.ps1"
    }
    It "ケース2のURLの変換を行わないか" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1@149657`""
        $GitHubSourceLink = [regex]::Replace($SVNSourceLink, "`"source:trunk/[^@]+`"", { Update-SourceLink($args[0].Groups[0].Value) })
        $GitHubSourceLink | Should Be $SVNSourceLink
    }
    It "ケース3のURLの変換を行わないか" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1@149657#L132`""
        $GitHubSourceLink = [regex]::Replace($SVNSourceLink, "`"source:trunk/[^@]+`"", { Update-SourceLink($args[0].Groups[0].Value) })
        $GitHubSourceLink | Should Be $SVNSourceLink
    }
}
