$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Update-DescriptionSourceLink" {
    It "ケース1" {
        $SVNSourceLink = "ccc source:`"trunk/src/net/Script/Net-Build.ps1`" fff"
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "ccc https://github.com/ISID/iQUAVIS/blob/master/src/net/Script/Net-Build.ps1  fff"
    }
    It "ケース1 -ダブルコーテーションなし-" {
        $SVNSourceLink = "aaa source:trunk/src/net/Script/Net-Build.ps1 ccc"
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "aaa https://github.com/ISID/iQUAVIS/blob/master/src/net/Script/Net-Build.ps1  ccc"
    }
    It "ケース2" {
        $SVNSourceLink = "source:`"trunk/src/net/Script/Net-Build.ps1@149657`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2 "
    }
    It "ケース2 -ダブルコーテーションなし-" {
        $SVNSourceLink = "source:trunk/src/net/Script/Net-Build.ps1@149657 "
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2 "
    }
    It "ケース3" {
        $SVNSourceLink = "source:`"trunk/src/net/Script/Net-Build.ps1@149657#L132`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2L132 "
    }
    It "ケース3 -ダブルコーテーションなし-" {
        $SVNSourceLink = "bbb source:trunk/src/net/Script/Net-Build.ps1@149657#L132 aaa"
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "bbb https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2L132  aaa"
    }
    It "ケース4" {
        $SVNSourceLink = "source:`"branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs "
    }
    It "ケース5" {
        $SVNSourceLink = "source:`"branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs@155018`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/7b7dfdfbe2fdf4af1bbb3c36f543edd3f9a3e3eb#diff-dea7ca04b6ca6cab8d12b77a308b71f8 "
    }
    It "ケース6" {
        $SVNSourceLink = "source:`"branches/3.4.3/src/net/Common Source/Shared/AssemblyInfoData.cs@155018#L81`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/7b7dfdfbe2fdf4af1bbb3c36f543edd3f9a3e3eb#diff-dea7ca04b6ca6cab8d12b77a308b71f8L81 "
    }
    It "ケース7" {
        $SVNSourceLink = "source:`"plugin/DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/blob/master/src/Project/Client/Client.DOORS/PluginInfoData.cs "
    }
    It "ケース8" {
        $SVNSourceLink = "source:`"plugin/DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs@150084`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376ab "
    }
    It "ケース9" {
        $SVNSourceLink = "source:`"plugin//DOORS/trunk/src/Project/Client/Client.DOORS/PluginInfoData.cs@150084#L15`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/cd6699cc3832cafa5db31f67b94d1cfded472350#diff-937ede871a50d9d43e79b35cb21376abL15 "
    }
    It "ケース10" {
        $SVNSourceLink = "source:`"plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/blob/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs "
    }
    It "ケース11" {
        $SVNSourceLink = "source:`"plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs@157464`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/b460616f2bdb4819a50981bdf2c713b83fa09c7a#diff-937ede871a50d9d43e79b35cb21376ab "
    }
    It "ケース12" {
        $SVNSourceLink = "source:`"plugin/DOORS/branches/1.343/src/Project/Client/Client.DOORS/PluginInfoData.cs@157464#L15`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-DOORS/commit/b460616f2bdb4819a50981bdf2c713b83fa09c7a#diff-937ede871a50d9d43e79b35cb21376abL15 "
    }
    It "ケース13" { #../revisions/172558が対象リビジョン、trunk/src/net/Project/Client/Api/Operation/IOperationApi.csが指すファイル
        $SVNSourceLink = "source:../revisions/172558/diff/trunk/src/net/Project/Client/Api/Operation/IOperationApi.cs "
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/236e12385eac1d65c6281a5dce90d9e1d3616cf0#diff-deb1688ce2dcebeb800ca1e539570989 "
    }
    It "ケース14" { #../diff/ をRemoveすればいける?
        $SVNSourceLink = "pjm:source:../diff/trunk/src/net/Project/Server/Mail/Mail/Triggers/ITaskAlertBatchMailTrigger.cs@125670 "
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/2a610b370965fb100c035a0c34ea7337e226a40b#diff-e029a624dce3132299a83c8926efea0f "
    }
    It "ケース15" { #../diff/ をRemoveすればいける?
        $SVNSourceLink = "pjm:source:/trunk/src/net/Project/Server/Mail/Mail/Triggers/ProjectModel.cs "
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/master/src/net/Project/Server/Mail/Mail/Triggers/ProjectModel.cs  "
    }
    It "ケース16" { # リポジトリ名/compare/{コミットハッシュ}...{コミットハッシュ}#diff-{MD5}
        $SVNSourceLink = "source:`"../diff/trunk/src/net/Project/Client/Infrastructure/Services/MessageDialog/MessageDialog.cs?rev=172609&rev_to=171813`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/compare/f772dd003c3cbdf559919bc19eeee07997c88a8e...935adcc7ec6383136bf3a150ff1cd2188ef20e74#diff-628a73a4c57f3a0c8b105da5661aea84 "
    }
    It "ケース17" {
        $SVNSourceLink = "iq-core:source:`"../diff/trunk/src/net/Project/Server/Service/Web/Api/WebApi/Controllers/TaskReferenceController.cs\?rev=159409&rev_to=156308`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/compare/660be9513d2764a6fb27746fc45d4c07388abdea...0e648196cad24d6831b73153db29eda2c3d10273#diff-5b2cad33ef9da6d628fd8870adfb6aec "
    }
    It "ケース18" { #14のダブルコーテーション版
        $SVNSourceLink = "pjm:source:`"../diff/trunk/src/net/Unit Test/Server/Mail\Test.Mail/Triggers/TaskAlertBatchMailTriggerTest.cs@125670`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/2a610b370965fb100c035a0c34ea7337e226a40b#diff-5e0a2e0b1934c0d2fc8e334f24f1a4d2 "
    }
    It "ケース19" {
        $SVNSourceLink = "source:`"/trunk/src/net/Script/Net-Build.ps1@149657`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2 "
    }
    It "ケース20" {
        $SVNSourceLink = "source:/trunk/src/net/Script/Net-Build.ps1@149657 "
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/commit/56d5a47b2a461a34676326f13966652901ad94b5#diff-43758f965282ae160c9890a763c621e2 "
    }
    It "ケース21" {
        $SVNSourceLink = "source:/trunk/src/Project/Client/Client.TMC.iSpirit/PluginModule.cs "
        $GitHubSourceLink = Update-DescriptionSourceLink -Description $SVNSourceLink -PluginName "/TMC/TMC_iSpirit"
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS-TMC-iSpirit/blob/master/src/Project/Client/Client.TMC_iSpirit/PluginModule.cs  "
    }
    It "ケース22" {
        $SVNSourceLink = "source:`"/trunk/src/net/Project/Client/Module/Common/Util/TaskDtoUtil.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink -Description $SVNSourceLink -PluginName ""
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/master/src/net/Project/Client/Module/Common/Util/TaskDtoUtil.cs "
    }
    It "ケース23" {
        $SVNSourceLink = "iq-core:source:`"/trunk/src/net/Unit Test/Client/Module/Test.Common/Managers/Logics/RestrictionItemsLogicTest.Deliverable.cs`""
        $GitHubSourceLink = Update-DescriptionSourceLink -Description $SVNSourceLink -PluginName ""
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/blob/master/src/net/Unit Test/Client/Module/Test.Common/Managers/Logics/RestrictionItemsLogicTest.Deliverable.cs "
    }
    It "ケース24" {
        $SVNSourceLink = "iq-core:source:`"../diff/trunk/src/net/Project/Client/Module/Rem.Spread/Views/BlockDiagramDSM/BlockDiagramDSMViewModel.OpenCommand.cs?rev=150141&rev_to150028`""
        $GitHubSourceLink = Update-DescriptionSourceLink $SVNSourceLink
        $GitHubSourceLink | Should Be "https://github.com/ISID/iQUAVIS/compare/643b7b1bb1264526c61407a608d41140df424325...711bb77e52cb36e1287185b39a65ed9811d16168#diff-6a2e3ef0b28d30bbe2387a4b5702622c "
    }
}
