$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Update-DescriptionSourceLink" {
    It "ケース1" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/master/src/net/Script/Net-Build.ps1"
    }
    It "ケース2" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1@149657`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2"
    }
    It "ケース3" {
        $SVNSourceLink = "`"source:trunk/src/net/Script/Net-Build.ps1@149657#L132`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2L132"
    }
    It "ケース4" {
        $SVNSourceLink = "`"source:branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/3.4.3/src/net/Common%20Source/Shared/AssemblyInfoData.cs"
    }
    It "ケース5" {
        $SVNSourceLink = "`"source:branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs@155018`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/7b7dfdfbe2fdf4af1bbb3c36f543edd3f9a3e3eb#diff-dea7ca04b6ca6cab8d12b77a308b71f8"
    }
    It "ケース6" {
        $SVNSourceLink = "`"source:branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs@155018#L81`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/7b7dfdfbe2fdf4af1bbb3c36f543edd3f9a3e3eb#diff-dea7ca04b6ca6cab8d12b77a308b71f8L81"
    }
    It "ケース7" {
        $SVNSourceLink = "`"source:plugin/DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/blob/master/src/Project/Client/Client.DOORS/PluginInfoData.cs"
    }
    It "ケース8" {
        $SVNSourceLink = "`"source:plugin/DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs@150084`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376ab"
    }
    It "ケース9" {
        $SVNSourceLink = "`"source:plugin//DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs@150084#L15`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376abL15"
    }
    It "ケース10" {
        $SVNSourceLink = "`"source:plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/blob/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs"
    }
    It "ケース11" {
        $SVNSourceLink = "`"source:plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs@157464`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376ab"
    }
    It "ケース12" {
        $SVNSourceLink = "`"source:plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs@157464#L15`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376abL15"
    }
}
