; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Docker Toolbox"
#define MyAppVersion "1.8.1a"
#define MyAppPublisher "Docker"
#define MyAppURL "https://docker.com"
#define MyAppContact "https://docs.docker.com"

#define b2dIsoPath ".\bundle\Boot2Docker\boot2docker.iso"

#define dockerCli ".\bundle\docker\docker.exe"
#define dockerMachineCli ".\bundle\docker\docker-machine.exe"

#define kitematic ".\bundle\kitematic"

#define msysGit ".\bundle\msysGit\Git.exe"

#define virtualBoxCommon ".\bundle\VirtualBox\common.cab"
#define virtualBoxMsi ".\bundle\VirtualBox\VirtualBox_amd64.msi"

#define EventStartedFile FileOpen(".\bundle\started.txt")
#define EventStartedData = FileRead(EventStartedFile)
#expr FileClose(EventStartedFile)
#undef EventStartedFile

#define EventFinishedFile FileOpen(".\bundle\finished.txt")
#define EventFinishedData = FileRead(EventFinishedFile)
#expr FileClose(EventFinishedFile)
#undef EventFinishedFile  

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{FC4417F0-D7F3-48DB-BCE1-F5ED5BAFFD91}
AppCopyright={#MyAppPublisher}
AppContact={#MyAppContact}
AppComments={#MyAppURL}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName=Docker
DisableProgramGroupPage=yes
; lets not be annoying
;InfoBeforeFile=.\LICENSE
;DisableFinishedPage
;InfoAfterFile=
OutputBaseFilename=DockerToolbox-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardImageFile=windows-installer-side.bmp
WizardSmallImageFile=windows-installer-logo.bmp
WizardImageStretch=no
WizardImageBackColor=$22EBB8

; in the installer itself:

; in the "Add/Remove" list:
UninstallDisplayIcon={app}\unins000.exe

SignTool=ksign /d $q{#MyAppName}$q /du $q{#MyAppURL}$q $f

SetupIconFile=toolbox.ico

; for modpath.iss
ChangesEnvironment=true

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "upgrade"; Description: "Upgrade Docker Toolbox only"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Run]
Filename: "{win}\explorer.exe"; Parameters: "{userprograms}\Docker\"; Flags: postinstall

[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"
Name: modifypath; Description: "Add docker.exe & docker-machine.exe to &PATH"

[Components]
Name: "Docker"; Description: "Docker Client for Windows" ; Types: full upgrade
Name: "DockerMachine"; Description: "Docker Machine for Windows" ; Types: full upgrade
Name: "Kitematic"; Description: "Kitematic for Windows" ; Types: full upgrade
Name: "VirtualBox"; Description: "VirtualBox"; Types: full
Name: "MSYS"; Description: "MSYS-git UNIX tools"; Types: full

[Files]
Source: ".\docker-quickstart-terminal.ico"; DestDir: "{app}"; Flags: ignoreversion

; Docker
Source: "{#dockerCli}"; DestDir: "{app}"; Flags: ignoreversion; Components: "Docker"
Source: ".\start.sh"; DestDir: "{app}"; Flags: ignoreversion; Components: "Docker";
Source: ".\delete.sh"; DestDir: "{app}"; Flags: ignoreversion; Components: "Docker"

; DockerMachine
Source: "{#dockerMachineCli}"; DestDir: "{app}"; Flags: ignoreversion; Components: "DockerMachine"
Source: ".\migrate.sh"; DestDir: "{app}"; Flags: ignoreversion; Components: "DockerMachine"
Source: ".\migrate.bat"; DestDir: "{app}"; Flags: ignoreversion; Components: "DockerMachine"

; Kitematic
Source: "{#kitematic}\*"; DestDir: "{app}\kitematic"; Flags: ignoreversion recursesubdirs; Components: "Kitematic"; 

; Boot2Docker
Source: "{#b2dIsoPath}"; DestDir: "{app}"; Flags: ignoreversion; Components: "DockerMachine"; AfterInstall: CopyBoot2DockerISO();

; msys-Git
Source: "{#msysGit}"; DestDir: "{app}\installers\msys-git"; DestName: "msys-git.exe"; AfterInstall: RunInstallMSYS();  Components: "MSYS"

; VirtualBox
Source: "{#virtualBoxCommon}"; DestDir: "{app}\installers\virtualbox"; Components: "VirtualBox"
Source: "{#virtualBoxMsi}"; DestDir: "{app}\installers\virtualbox"; DestName: "virtualbox.msi"; AfterInstall: RunInstallVirtualBox(); Components: "VirtualBox"

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{userprograms}\Docker\Kitematic (Alpha)"; WorkingDir: "{app}"; Filename: "{app}\kitematic\Kitematic.exe"; Components: "Kitematic"
Name: "{commondesktop}\Kitematic (Alpha)"; WorkingDir: "{app}"; Filename: "{app}\kitematic\Kitematic.exe"; Tasks: desktopicon; Components: "Kitematic"
Name: "{userprograms}\Docker\Docker Quickstart Terminal"; WorkingDir: "{app}"; Filename: "{app}\start.sh"; IconFilename: "{app}/docker-quickstart-terminal.ico"; Components: "Docker"
Name: "{commondesktop}\Docker Quickstart Terminal"; WorkingDir: "{app}"; Filename: "{app}\start.sh"; IconFilename: "{app}/docker-quickstart-terminal.ico"; Tasks: desktopicon; Components: "Docker"

[UninstallRun]
Filename: "{app}\delete.sh"

[UninstallDelete]
Type: filesandordirs; Name: "{localappdata}\..\Roaming\Kitematic"

[Code]
var
	restart: boolean;
// http://stackoverflow.com/questions/9238698/show-licenseagreement-link-in-innosetup-while-installation
	DockerInstallDocs: TLabel;

const
	UninstallKey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1';
//  32 bit on 64  HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall


function IsUpgrade: Boolean;
var
	Value: string;
begin
	Result := (
		RegQueryStringValue(HKLM, UninstallKey, 'UninstallString', Value)
		or
		RegQueryStringValue(HKCU, UninstallKey, 'UninstallString', Value)
	) and (Value <> '');
end;


function NeedRestart(): Boolean;
begin
	Result := restart;
end;

function NeedToInstallVirtualBox(): Boolean;
begin
	Result := (
		(GetEnv('VBOX_INSTALL_PATH') = '')
		and
		(GetEnv('VBOX_MSI_INSTALL_PATH') = '')
	);
end;

function NeedToInstallMSYS(): Boolean;
begin
	Result := not RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1');
end;

procedure DocLinkClick(Sender: TObject);
var
	ErrorCode: Integer;
begin
	ShellExec('', 'https://docs.docker.com/installation/windows/', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure InitializeWizard;
begin
	DockerInstallDocs := TLabel.Create(WizardForm);
	DockerInstallDocs.Parent := WizardForm;
	DockerInstallDocs.Left := 8;
	DockerInstallDocs.Top := WizardForm.ClientHeight - DockerInstallDocs.ClientHeight - 8;
	DockerInstallDocs.Cursor := crHand;
	DockerInstallDocs.Font.Color := clBlue;
	DockerInstallDocs.Font.Style := [fsUnderline];
	DockerInstallDocs.Caption := '{#MyAppName} installation documentation';
	DockerInstallDocs.OnClick := @DocLinkClick;
end;

function InitializeSetup(): boolean;
var
  ResultCode: integer;
  WinHttpReq: Variant;
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  if (Version.Major = 10) then
  begin
    SuppressibleMsgBox('Windows 10 is not currently supported by the Docker Toolbox, due to an incompatibility with VirtualBox. There is a Windows 10 test build available at github.com/docker/toolbox/releases', mbCriticalError, MB_OK, IDOK);
    Result := False;
    Exit;
  end;

  try
    WinHttpReq := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    WinHttpReq.Open('POST', 'https://api.mixpanel.com/track/?data={#EventStartedData}', false);
    WinHttpReq.SetRequestHeader('Content-Type', 'application/json');
    WinHttpReq.Send('');
  except
  end;
  // Proceed Setup
  Result := True;

end;

procedure CurPageChanged(CurPageID: Integer);
begin
	DockerInstallDocs.Visible := True;

	WizardForm.FinishedLabel.AutoSize := True;
	WizardForm.FinishedLabel.Caption :=
		'{#MyAppName} installation completed.' + \
		#13#10 + \
		#13#10 + \
		'Run using the `Docker Quickstart Terminal` icon on your desktop or in [Program Files] - then start a test container with:' + \
		#13#10 + \
		'         `docker run hello-world`' + \
		#13#10 + \
		#13#10 + \
		// TODO: it seems making hyperlinks is hard :/
		//'To save and share container images, automate workflows, and more sign-up for a free <a href="http://hub.docker.com/?utm_source=b2d&utm_medium=installer&utm_term=summary&utm_content=windows&utm_campaign=product">Docker Hub account</a>.' + \
		#13#10 + \
		#13#10 +
		'You can upgrade your existing Docker Machine dev VM without data loss by running:' + \
		#13#10 + \
		'         `docker-machine upgrade dev`' + \
		#13#10 + \
		#13#10 + \
		'For further information, please see the {#MyAppName} installation documentation link.'
	;
	//if CurPageID = wpSelectDir then
		// to go with DisableReadyPage=yes and DisableProgramGroupPage=yes
		//WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
	//else
		//WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
	//if CurPageID = wpFinished then
		//WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
		// if CurPageID = wpSelectComponents then
		// begin
		//	if IsUpgrade() then
		//	begin
		//		Wizardform.TypesCombo.ItemIndex := 2
		//	end;
		// Wizardform.ComponentsList.Checked[3] := NeedToInstallVirtualBox();
		// Wizardform.ComponentsList.Checked[4] := NeedToInstallMSYS();
		// end;
end;

procedure RunInstallVirtualBox();
var
	ResultCode: Integer;
begin
	WizardForm.FilenameLabel.Caption := 'installing VirtualBox'
	if Exec(ExpandConstant('msiexec'), ExpandConstant('/qn /i "{app}\installers\virtualbox\virtualbox.msi" /norestart'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
	begin
		// handle success if necessary; ResultCode contains the exit code
		//MsgBox('virtualbox install OK', mbInformation, MB_OK);
	end
	else begin
		// handle failure if necessary; ResultCode contains the error code
		MsgBox('virtualbox install failure', mbInformation, MB_OK);
	end;
	//restart := True;
end;

procedure RunInstallMSYS();
var
	ResultCode: Integer;
begin
	WizardForm.FilenameLabel.Caption := 'installing MSYS Git'
	if Exec(ExpandConstant('{app}\installers\msys-git\msys-git.exe'), '/sp- /verysilent /norestart', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
	begin
		// handle success if necessary; ResultCode contains the exit code
		//MsgBox('msys installed OK', mbInformation, MB_OK);
	end
	else begin
		// handle failure if necessary; ResultCode contains the error code
		MsgBox('msys install failure', mbInformation, MB_OK);
	end;
end;

procedure CopyBoot2DockerISO();
var
  ResultCode: Integer;
begin
  WizardForm.FilenameLabel.Caption := 'copying boot2docker iso'
  if not ForceDirectories(ExpandConstant('{userdocs}\..\.docker\machine\cache')) then
      MsgBox('Failed to create docker machine cache dir', mbError, MB_OK);
  if not FileCopy(ExpandConstant('{app}\boot2docker.iso'), ExpandConstant('{userdocs}\..\.docker\machine\cache\boot2docker.iso'), false) then
      MsgBox('File moving failed!', mbError, MB_OK);
end;

function MigrateVM() : Boolean;
var
  ResultCode: Integer;
begin
  if not IsComponentSelected('DockerMachine') or not FileExists('C:\Program Files\Oracle\VirtualBox\VBoxManage.exe') or not FileExists(ExpandConstant('{app}\docker-machine.exe')) then
  begin
    Result := true

    exit
  end;

  ExecAsOriginalUser('C:\Program Files\Oracle\VirtualBox\VBoxManage.exe', 'showvminfo default', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  if ResultCode <> 1 then
  begin
    Result := true
    exit
  end;

  ExecAsOriginalUser('C:\Program Files\Oracle\VirtualBox\VBoxManage.exe', 'showvminfo boot2docker-vm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  if ResultCode <> 0 then
  begin
    Result := true
    exit
  end;
                              
  if MsgBox('Migrate your existing Boot2Docker VM to work with the Docker Toolbox? Your existing Boot2Docker VM will not be affected. This should take about a minute.', mbConfirmation, MB_YESNO) = IDYES then
  begin
    WizardForm.StatusLabel.Caption := 'Migrating Boot2Docker VM...'
    WizardForm.FilenameLabel.Caption := 'This will take a minute...'
    ExecAsOriginalUser(ExpandConstant('{app}\docker-machine.exe'), ExpandConstant('rm -f default > nul 2>&1'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
    DelTree(ExpandConstant('{userdocs}\..\.docker\machine\machines\default'), True, True, True);
    ExecAsOriginalUser(ExpandConstant('{app}\migrate.bat'), ExpandConstant('> {localappdata}\Temp\toolbox-migration-logs.txt 2>&1'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
    if ResultCode = 0 then
    begin
      MsgBox('Succcessfully migrated Boot2Docker VM to a Docker Machine VM named "default"', mbInformation, MB_OK);
    end
    else begin
      MsgBox('Migration of Boot2Docker VM failed. Please file an issue with the migration logs at https://github.com/docker/machine/issues/new.', mbCriticalError, MB_OK);
      Exec(ExpandConstant('{win}\notepad.exe'), ExpandConstant('{localappdata}\Temp\toolbox-migration-logs.txt'), '', SW_SHOW, ewNoWait, ResultCode)
      Result := false
      exit;
    end;
  end;
  Result := true
end;   

const
	ModPathName = 'modifypath';
	ModPathType = 'user';

function ModPathDir(): TArrayOfString;
begin
	setArrayLength(Result, 1);
	Result[0] := ExpandConstant('{app}');
end;
#include "modpath.iss"

procedure CurStepChanged(CurStep: TSetupStep);
var
	taskname:	String;
  WinHttpReq: Variant;
  migrationSuccess: Boolean;
begin
	taskname := ModPathName;

	if CurStep = ssPostInstall then
  begin
    if IsTaskSelected(taskname) then
			ModPath();

    migrationSuccess:= MigrateVM();

    if migrationSuccess then
    begin
      try
        WinHttpReq := CreateOleObject('WinHttp.WinHttpRequest.5.1');
        WinHttpReq.Open('POST', 'https://api.mixpanel.com/track/?data={#EventFinishedData}', false);
        WinHttpReq.SetRequestHeader('Content-Type', 'application/json');
        WinHttpReq.Send('');
      except
      end;
    end;
  end
end;