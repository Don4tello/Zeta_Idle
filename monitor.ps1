$adb = "C:\Android\Sdk\platform-tools\adb.exe"
$log = "C:\ZetaIdle\monitor.log"

function Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "$ts $msg" | Tee-Object -Append $log
}

function GetUI {
    & $adb shell "uiautomator dump /sdcard/ui.xml" 2>$null | Out-Null
    & $adb pull /sdcard/ui.xml "C:\ZetaIdle\ui_live.xml" 2>$null | Out-Null
    return Get-Content "C:\ZetaIdle\ui_live.xml" -Raw -ErrorAction SilentlyContinue
}

function FindCenter($content, $pattern) {
    $m = [regex]::Match($content, $pattern)
    if ($m.Success) {
        $cx = ([int]$m.Groups[1].Value + [int]$m.Groups[3].Value) / 2
        $cy = ([int]$m.Groups[2].Value + [int]$m.Groups[4].Value) / 2
        return @($cx, $cy)
    }
    return $null
}

function Tap($x, $y) { & $adb shell input tap $x $y | Out-Null }
function Wake { & $adb shell input keyevent 224 | Out-Null }

Log "Monitor started — will keep auto-campaign ON and advance battles"

$tick = 0
while ($true) {
    $tick++
    Wake
    Start-Sleep -Milliseconds 500

    $ui = GetUI
    if (-not $ui) {
        Log "Could not read UI — waiting..."
        Start-Sleep -Seconds 30
        continue
    }

    # Check auto-campaign state
    $acOn  = $ui -match 'Auto-Campaign: ON'
    $acOff = $ui -match 'Auto-Campaign: OFF'

    # Check for FIGHT/HERO buttons (victory overlay)
    $fightBtn = FindCenter $ui 'desc.*?FIGHT.*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"'
    $heroBtn  = FindCenter $ui 'desc.*?(?<![A-Z])HERO(?![A-Z]).*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"'

    # Check for CAMPAIGN FIGHT button (play screen)
    $campaignFight = $ui -match 'NO ACTIVE BATTLE|Campaign'

    if ($acOff) {
        Log "Auto-Campaign OFF — re-enabling at (1008,164)"
        Tap 1008 164
        Start-Sleep -Milliseconds 500
    }

    if ($fightBtn) {
        Log "Victory overlay — tapping FIGHT at ($($fightBtn[0]), $($fightBtn[1]))"
        Tap $fightBtn[0] $fightBtn[1]
        Start-Sleep -Seconds 2
    }

    # Every 10 ticks: take screenshot for log
    if ($tick % 10 -eq 0) {
        & $adb shell screencap -p /sdcard/s.png 2>$null | Out-Null
        & $adb pull /sdcard/s.png "C:\ZetaIdle\monitor_ss.png" 2>$null | Out-Null
        $lvlMatch = [regex]::Match($ui, 'Level\s+(\d+)|Lv\.?\s*(\d+)')
        Log "Tick $tick — AC:$(if($acOn){'ON'}else{'OFF'}) Screenshot saved"
    }

    Start-Sleep -Seconds 20
}
