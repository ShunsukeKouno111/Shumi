function WriteStepCountLog($basedir,$destination){
    $psfiles = Get-ChildItem $basedir -Recurse | Where-Object { $_.Extension -eq ".ps1" }
    $csfiles = Get-ChildItem $basedir -Recurse | Where-Object { $_.Extension -eq ".cs" }
    $psstep = CountStep($psfiles)
    $csstep = CountStep($csfiles)
    $sumstep = $psstep + $csstep
    $today = Get-Date -UFormat "%Y/%m/%d"
    $log = $today + "   PowerShell:" + $psstep + "steps  " + "C#:" + $csstep + "steps  " + "Sum:" + $sumstep + "steps  "
    $destinationFilePath = $destination + "\StepCountLog.txt"
    $log | Out-File $destinationFilePath -Append 
}
function CountStep($files) {
    foreach ($item in $files) {
        # 
        $step += (Get-Content $item.Fullname).Length
    } 
    return $step
}
WriteStepCountLog $args[0] $args[1]
