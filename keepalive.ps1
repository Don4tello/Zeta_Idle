$adb = "C:\Android\Sdk\platform-tools\adb.exe"
$i = 0
while ($true) {
    $i++
    & $adb shell input keyevent 224  # wake screen
    Start-Sleep -Milliseconds 300
    & $adb shell input tap 540 1200  # tap center (safe on any screen)
    $ts = Get-Date -Format "HH:mm:ss"
    "$ts keep-alive tap #$i" | Out-File -Append "C:\ZetaIdle\keepalive.log"
    Start-Sleep -Seconds 90
}
