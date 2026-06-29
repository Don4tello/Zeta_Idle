; Zeta Idle — Inno Setup Script
; Build installer with Inno Setup 6: https://jrsoftware.org/isdl.php
; Run this script from the project root AFTER:  flutter build windows --release

#define AppName      "Zeta Idle"
#define AppVersion   "1.0"
#define AppPublisher "Matthias Mazur"
#define AppExeName   "zeta_idle.exe"
#define BuildDir     "..\build\windows\x64\runner\Release"
#define IconFile     "..\windows\runner\resources\app_icon.ico"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisherURL=
AppSupportURL=
AppUpdatesURL=
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; Require admin rights so the install goes to Program Files
PrivilegesRequired=admin
OutputDir=.
OutputBaseFilename=ZetaIdle_Setup
SetupIconFile={#IconFile}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
; Minimum Windows 10
MinVersion=10.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon";    Description: "{cm:CreateDesktopIcon}";    GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startmenuicon";  Description: "Create a Start Menu shortcut"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce

[Files]
; Main executable
Source: "{#BuildDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter runtime DLLs
Source: "{#BuildDir}\flutter_windows.dll";             DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\audioplayers_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; App data (Flutter assets, fonts, shaders, etc.)
Source: "{#BuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";        Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: startmenuicon
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}";  Tasks: startmenuicon
Name: "{autodesktop}\{#AppName}";  Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
