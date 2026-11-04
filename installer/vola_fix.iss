; Builds the Peaks Fix Windows installer.
; Build the app first (flutter build windows --release), then:
;   ISCC.exe /DAppVersion=0.06.03.11.26 installer\vola_fix.iss
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6B0E7C57-5B0B-4F3E-9B64-4C1E5D8A9F21}
AppName=Peaks Fix
AppVersion={#AppVersion}
AppPublisher=Peaks Fix
DefaultDirName={autopf}\Peaks Fix
DefaultGroupName=Peaks Fix
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=Output
OutputBaseFilename=PeaksFix_Setup_{#AppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\vola_fix.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Peaks Fix"; Filename: "{app}\vola_fix.exe"
Name: "{autodesktop}\Peaks Fix"; Filename: "{app}\vola_fix.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\vola_fix.exe"; Description: "Launch Peaks Fix and create the Admin login"; Flags: nowait postinstall skipifsilent

[Messages]
FinishedLabel=Setup has installed [name] on your computer.%n%nThe first time Peaks Fix opens it asks you to create the shop's Admin login. Keep that password safe: it can't be recovered.%n%nShop data is kept separately from the program, so uninstalling or updating never deletes it.
