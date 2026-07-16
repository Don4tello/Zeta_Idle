$adb = "C:\Android\Sdk\platform-tools\adb.exe"

function Tap($x, $y) {
    & $adb shell input tap $x $y
    Start-Sleep -Milliseconds 400
}

function Screenshot {
    & $adb shell screencap -p /sdcard/s.png | Out-Null
    & $adb pull /sdcard/s.png "C:\ZetaIdle\ss.png" 2>$null | Out-Null
}

function WakeScreen {
    & $adb shell input keyevent 224  # KEYCODE_WAKEUP
    Start-Sleep -Milliseconds 300
    & $adb shell input swipe 540 1800 540 1200 300  # swipe up to unlock (if locked)
    Start-Sleep -Milliseconds 500
}

function Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host "[$ts] $msg"
}

# ── Coordinate map for 1080x2400 Samsung S21 ─────────────────────────────────
$coords = @{
    # Character select — Don4tello slot 3 ">" arrow
    char_don4tello  = @(583, 883)

    # Bottom nav tabs
    tab_hero        = @(135, 2320)
    tab_play        = @(405, 2320)
    tab_inventory   = @(675, 2320)

    # PLAY screen — Campaign start button (approx center-left)
    campaign_fight  = @(540, 900)

    # Battle screen app bar — auto-campaign toggle (rightmost icon)
    auto_campaign   = @(1010, 160)

    # Battle screen — pause button (2nd from left in action bar)
    pause_btn       = @(800, 160)

    # Victory overlay — FIGHT button (right of the two buttons)
    fight_btn       = @(660, 2130)

    # Victory overlay — HERO button (left of the two buttons)
    hero_btn        = @(370, 2130)

    # Center of screen (keep-alive tap — safe, won't do anything in most states)
    center          = @(540, 1200)
}

Log "Starting auto-level loop. Target: Level 100"
Log "Screen: 1080x2400, ADB: $adb"

$iteration = 0

while ($true) {
    $iteration++
    WakeScreen

    # Every tap cycle: tap FIGHT button area (handles victory overlay if up)
    # and also tap center (safe anywhere else)
    Log "Iter $iteration — tapping FIGHT area to advance battle"
    Tap $coords.fight_btn[0] $coords.fight_btn[1]
    Start-Sleep -Milliseconds 800

    # Also wake screen center as a no-op safe tap in most states
    Tap $coords.center[0] $coords.center[1]

    # Every 10 iterations (~15 min) take a screenshot and log level
    if ($iteration % 10 -eq 0) {
        Log "Taking progress screenshot..."
        Screenshot
        Log "Screenshot saved to C:\ZetaIdle\ss.png"
    }

    Log "Sleeping 90s before next action..."
    Start-Sleep -Seconds 90
}
