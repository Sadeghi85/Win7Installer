#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Win7Installer.ico
#AutoIt3Wrapper_Outfile=Win7Installer.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Windows 7 fast installer
#AutoIt3Wrapper_Res_Description=Windows 7 fast installer
#AutoIt3Wrapper_Res_Fileversion=1.0.0.5
#AutoIt3Wrapper_Res_LegalCopyright=© 2011 Sadeghi85
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Field=ProductName|Win7Installer.exe
#AutoIt3Wrapper_Res_Field=ProductVersion|1.0.0.5
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#NoAutoIt3Execute
#include <Constants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
Opt("MustDeclareVars", 1)
Global $sIni = @TempDir & "\stats"

Switch $CMDLINE[0]
	Case 5
		If $CMDLINE[1] = "-install" Then
			Local $iTemp = ""
			Local $aTemp = ""
			Local $sInfo = ""

			WinSetState("Windows 7 fast installer", "", @SW_HIDE)

			$iTemp = Run(@ComSpec & " /k imagex.exe /apply" & ' "' & $CMDLINE[2] & '" ' & $CMDLINE[3] & ' ' & $CMDLINE[4] & ":\", @TempDir, @SW_HIDE, $STDOUT_CHILD)

			Do
				$sInfo &= StdoutRead($iTemp)
				If @error Then ExitLoop
				$aTemp = StringRegExp($sInfo, '.*?\r\n\r\n(?s)(.*)', 1)
			Until Not @error

			If IsArray($aTemp) Then
				$sInfo = $aTemp[0]
			Else
				ProcessClose($iTemp)
				MsgBox(48, "Windows 7 fast installer", "An unknown error occurred. Press OK to close this program.")
				WinClose("Windows 7 fast installer")
				Exit
			EndIf

			WinActivate("Installing Windows...")
			WinSetState("Installing Windows...", "", @SW_SHOW)

			While 1
				$sInfo &= StdoutRead($iTemp)
				If @error Then ExitLoop

				If StringInStr($sInfo, "error") Then
					While 1
						$sInfo &= StdoutRead($iTemp)
						If @error Then ExitLoop
						Sleep(100)
					WEnd

					ExitLoop
				EndIf

				$aTemp = StringRegExp($sInfo, '(\d{1,2})%.*?(\d{0,}:?\d{1,2}.*?)\r\n', 3)
				If Not @error Then
					IniWrite($sIni, "internals", "progress", $aTemp[UBound($aTemp) - 2])
					IniWrite($sIni, "internals", "remaining", $aTemp[UBound($aTemp) - 1])
				EndIf

				Sleep(100)
			WEnd

			ProcessClose($iTemp)

			If StringInStr($sInfo, "error") Then
				WinSetState("Installing Windows...", "", @SW_HIDE)
				$aTemp = StringRegExp($sInfo, '\r\n(.*?(?i)error(?s).*)', 1)
				MsgBox(48, "Windows 7 fast installer", $aTemp[0])
				WinActivate("Windows 7 fast installer")
				WinSetState("Windows 7 fast installer", "", @SW_SHOW)
				FileDelete($sIni)
				Exit
			EndIf

			Sleep(100)

			If IniRead($sIni, "internals", "exitflag", 0) = 1 Then
				FileDelete($sIni)
				Exit
			EndIf

			ShellExecuteWait("bcdboot.exe", $CMDLINE[4] & ":\windows /s " & $CMDLINE[5] & ":", @TempDir, "", @SW_HIDE)

			Sleep(100)

			If $CMDLINE[5] = $CMDLINE[4] Then

				ShellExecuteWait("bcdedit.exe", "/store " & $CMDLINE[5] & ":\boot\bcd /set {default} osdevice boot", @TempDir, "", @SW_HIDE)
				ShellExecuteWait("bcdedit.exe", "/store " & $CMDLINE[5] & ":\boot\bcd /set {default} device boot", @TempDir, "", @SW_HIDE)
				ShellExecuteWait("bcdedit.exe", "/store " & $CMDLINE[5] & ":\boot\bcd /set {bootmgr} device boot", @TempDir, "", @SW_HIDE)
				ShellExecuteWait("bcdedit.exe", "/store " & $CMDLINE[5] & ":\boot\bcd /set {memdiag} device boot", @TempDir, "", @SW_HIDE)
			EndIf

			WinSetState("Installing Windows...", "", @SW_HIDE)
			FileDelete($sIni)

			If MsgBox(289, "Windows 7 fast installer", "Installation completed successfully. Do you want to restart the computer now?") <> 1 Then
				WinActivate("Windows 7 fast installer")
				WinSetState("Windows 7 fast installer", "", @SW_SHOW)
				Exit
			Else
				If ProcessExists("xpelogon.exe") Then
					ProcessClose("xpelogon.exe")
				Else
					Shutdown(2)
					Exit
				EndIf
			EndIf
		Else
			Exit
		EndIf
EndSwitch

Global $WM_QUERYENDSESSION = 0x0011
GUIRegisterMsg($WM_QUERYENDSESSION, "_CancelShutdown")
Global $fShutdownInitiated = False
Global $iEdition = 0
Global $fIs64Bit = False

If _Singleton("Windows 7 fast installer", 1) = 0 Then
	WinActivate("Windows 7 fast installer")
	Exit
EndIf

AdlibRegister("_ChangeProgress", "5000")

Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=c:\users\admin\desktop\Win7Installer.kxf
Global $frmMain = GUICreate("Windows 7 fast installer", 365, 229, -1, -1)
Global $mnuFile = GUICtrlCreateMenu("&File")
Global $mnuExit = GUICtrlCreateMenuItem("&Exit", $mnuFile)
GUICtrlSetOnEvent(-1, "mnuExitClick")
Global $MenuItem2 = GUICtrlCreateMenu("&Help")
Global $mnuAbout = GUICtrlCreateMenuItem("&About", $MenuItem2)
GUICtrlSetOnEvent(-1, "mnuAboutClick")
GUISetOnEvent($GUI_EVENT_CLOSE, "frmMainClose")
Global $Group1 = GUICtrlCreateGroup("", 4, 0, 356, 90)
Global $Label5 = GUICtrlCreateLabel("Source:", 20, 20, 41, 17, 0)
GUICtrlSetTip(-1, "Path to installation WIM file")
Global $txtPathToSource = GUICtrlCreateInput("", 62, 18, 218, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
GUICtrlSetTip(-1, "Path to installation WIM file")
GUICtrlSetCursor(-1, 0)
Global $btnBrowse = GUICtrlCreateButton("Browse ...", 283, 16, 65, 26, BitOR($BS_CENTER, $BS_VCENTER, $BS_NOTIFY))
GUICtrlSetOnEvent(-1, "btnBrowseClick")
Global $Group2 = GUICtrlCreateGroup("", 16, 42, 95, 41)
Global $Label1 = GUICtrlCreateLabel("Boot drive:", 22, 58, 55, 17, 0)
GUICtrlSetTip(-1, "Drive letter")
Global $txtBootDrive = GUICtrlCreateInput("", 78, 56, 25, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_UPPERCASE))
GUICtrlSetLimit(-1, 1)
GUICtrlSetOnEvent(-1, "txtInstallationDriveChange")
GUICtrlSetTip(-1, "Drive letter")
GUICtrlSetCursor(-1, 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group3 = GUICtrlCreateGroup("", 120, 42, 123, 41)
Global $Label3 = GUICtrlCreateLabel("Installation drive:", 126, 58, 83, 17, 0)
GUICtrlSetTip(-1, "Drive letter")
Global $txtInstallationDrive = GUICtrlCreateInput("", 210, 56, 25, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_UPPERCASE))
GUICtrlSetLimit(-1, 1)
GUICtrlSetOnEvent(-1, "txtInstallationDriveChange")
GUICtrlSetTip(-1, "Drive letter")
GUICtrlSetCursor(-1, 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $cmbEdition = GUICtrlCreateCombo("", 252, 54, 95, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "cmbEditionChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group5 = GUICtrlCreateGroup("", 4, 92, 356, 56)
Global $btnInstallMBR = GUICtrlCreateButton("Install MBR", 16, 108, 77, 26, BitOR($BS_CENTER, $BS_VCENTER, $BS_NOTIFY))
GUICtrlSetOnEvent(-1, "btnInstallMBRClick")
Global $btnPartitionManagement = GUICtrlCreateButton("Partition Management", 120, 108, 122, 26, BitOR($BS_CENTER, $BS_VCENTER, $BS_NOTIFY))
GUICtrlSetOnEvent(-1, "btnPartitionManagementClick")
Global $btnInstallPBR = GUICtrlCreateButton("Install PBR", 270, 108, 77, 26, BitOR($BS_CENTER, $BS_VCENTER, $BS_NOTIFY))
GUICtrlSetOnEvent(-1, "btnInstallPBRClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group4 = GUICtrlCreateGroup("", 4, 150, 356, 53)
Global $btnInstall = GUICtrlCreateButton("Install", 146, 166, 77, 26, BitOR($BS_CENTER, $BS_VCENTER, $BS_NOTIFY))
GUICtrlSetOnEvent(-1, "btnInstallClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $frmOutput = GUICreate("Installing Windows...", 485, 60, -1, -1, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU), BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
GUISetOnEvent($GUI_EVENT_CLOSE, "frmOutputClose", $frmOutput)
Global $prgOutput = GUICtrlCreateProgress(8, 8, 466, 25)
GUISetState(@SW_HIDE, $frmOutput)

If Not FileInstall("bootice.exe", @TempDir & "/bootice.exe", 1) Then Exit
If Not FileInstall("imagex.exe", @TempDir & "/imagex.exe", 1) Then Exit
If Not FileInstall("bcdboot.exe", @TempDir & "/bcdboot.exe", 1) Then Exit
If Not FileInstall("bcdedit.exe", @TempDir & "/bcdedit.exe", 1) Then Exit

While 1
	If $fShutdownInitiated = True Then
		_DoCleanUp()
		Shutdown(6)
	EndIf

	Sleep(100)
WEnd

Func _ChangeProgress()
	Local $iTemp = IniRead($sIni, "internals", "progress", 0)
	Local $sTemp = IniRead($sIni, "internals", "remaining", "")
	If $iTemp <> GUICtrlRead($prgOutput) Then
		GUICtrlSetData($prgOutput, $iTemp)
		GUICtrlSetTip($prgOutput, $sTemp)
	EndIf
EndFunc   ;==>_ChangeProgress

Func _CancelShutdown($hWndGUI, $MsgID, $WParam, $LParam)
	$fShutdownInitiated = True
	Return False
EndFunc   ;==>_CancelShutdown

Func _DoCleanUp()
	FileDelete(@TempDir & "\bootice.exe")
	FileDelete(@TempDir & "\imagex.exe")
	FileDelete(@TempDir & "\bcdboot.exe")
	FileDelete(@TempDir & "\bcdedit.exe")
	FileDelete($sIni)
EndFunc   ;==>_DoCleanUp

Func cmbEditionChange()
	If $fIs64Bit Then
		Switch GUICtrlRead(@GUI_CtrlId)
			Case "Select Edition"
				$iEdition = 0
			Case "Home Basic"
				$iEdition = 1
			Case "Home Premium"
				$iEdition = 2
			Case "Professional"
				$iEdition = 3
			Case "Ultimate"
				$iEdition = 4
		EndSwitch
	Else
		Switch GUICtrlRead(@GUI_CtrlId)
			Case "Select Edition"
				$iEdition = 0
			Case "Starter"
				$iEdition = 1
			Case "Home Basic"
				$iEdition = 2
			Case "Home Premium"
				$iEdition = 3
			Case "Professional"
				$iEdition = 4
			Case "Ultimate"
				$iEdition = 5
		EndSwitch
	EndIf
EndFunc   ;==>cmbEditionChange

Func btnBrowseClick()
	Local $sTemp = FileOpenDialog("Open", "", "Windows Imaging Format (install.wim)", 1 + 2, "install.wim", $frmMain)

	If @error Then
		GUICtrlSetData($txtPathToSource, "")
		GUICtrlSetTip($txtPathToSource, "Path to installation WIM file")
		GUICtrlSetState($cmbEdition, $GUI_DISABLE)
	Else
		Local $sInfo = ""
		Local $iTemp = Run(@ComSpec & " /k imagex.exe /info" & ' "' & $sTemp & '"', @TempDir, @SW_HIDE, $STDOUT_CHILD)

		While 1
			$sInfo &= StdoutRead($iTemp)
			If @error Then ExitLoop
			Sleep(100)
		WEnd

		ProcessClose($iTemp)

		Local $aTemp = StringRegExp($sInfo, '(?si)<image(.*?)</image>', 3)

		If @error Or UBound($aTemp) < 4 Or UBound($aTemp) > 5 Then
			MsgBox(48, "Windows 7 fast installer", "This is NOT a valid installation file", 0, $frmMain)
			GUICtrlSetData($txtPathToSource, "")
			GUICtrlSetTip($txtPathToSource, "Path to installation WIM file")
			GUICtrlSetState($cmbEdition, $GUI_DISABLE)
		Else
			GUICtrlSetData($txtPathToSource, $sTemp)
			GUICtrlSetTip($txtPathToSource, $sTemp)
			GUICtrlSetState($cmbEdition, $GUI_ENABLE)
			If UBound($aTemp) = 4 Then
				GUICtrlSetData($cmbEdition, "|Select Edition|Home Basic|Home Premium|Professional|Ultimate", "Select Edition")
				$fIs64Bit = True
			ElseIf UBound($aTemp) = 5 Then
				GUICtrlSetData($cmbEdition, "|Select Edition|Starter|Home Basic|Home Premium|Professional|Ultimate", "Select Edition")
				$fIs64Bit = False
			EndIf
		EndIf
	EndIf
EndFunc   ;==>btnBrowseClick

Func btnInstallMBRClick()
	If StringLen(GUICtrlRead($txtBootDrive)) Then
		GUISetState(@SW_HIDE, $frmMain)

		ShellExecute("bootice.exe", "/device=" & GUICtrlRead($txtBootDrive) & ": /mbr /install /type=nt60", @TempDir, "", @SW_SHOWMINNOACTIVE)

		WinWaitActive("[REGEXPTITLE:(?i)\*_\*|Pauly]")

		If WinActive("[REGEXPTITLE:(?i)Pauly]") Then
			ProcessClose("bootice.exe")
			MsgBox(48, "Windows 7 fast installer", "Invalid boot drive", 0, $frmMain)
			GUICtrlSetData($txtBootDrive, "")
			GUICtrlSetState($txtBootDrive, $GUI_FOCUS)
			GUISetState(@SW_SHOW, $frmMain)
		Else
			WinWaitClose("[REGEXPTITLE:(?i)Pauly]")
			GUISetState(@SW_SHOW, $frmMain)
		EndIf
	Else
		GUICtrlSetState($txtBootDrive, $GUI_FOCUS)
	EndIf
EndFunc   ;==>btnInstallMBRClick

Func btnInstallPBRClick()
	If StringLen(GUICtrlRead($txtBootDrive)) Then
		GUISetState(@SW_HIDE, $frmMain)

		ShellExecute("bootice.exe", "/device=" & GUICtrlRead($txtBootDrive) & ": /pbr /install /type=bootmgr", @TempDir, "", @SW_SHOWMINNOACTIVE)

		WinWaitActive("[REGEXPTITLE:(?i)Rename the boot file|Pauly]")

		If WinActive("[REGEXPTITLE:(?i)Pauly]") Then
			ProcessClose("bootice.exe")
			MsgBox(48, "Windows 7 fast installer", "Invalid boot drive", 0, $frmMain)
			GUICtrlSetData($txtBootDrive, "")
			GUICtrlSetState($txtBootDrive, $GUI_FOCUS)
			GUISetState(@SW_SHOW, $frmMain)
		Else
			WinWaitClose("[REGEXPTITLE:(?i)Pauly]")
			GUISetState(@SW_SHOW, $frmMain)
		EndIf
	Else
		GUICtrlSetState($txtBootDrive, $GUI_FOCUS)
	EndIf
EndFunc   ;==>btnInstallPBRClick

Func btnPartitionManagementClick()
	If StringLen(GUICtrlRead($txtInstallationDrive)) Then
		GUISetState(@SW_HIDE, $frmMain)

		ShellExecute("bootice.exe", "/device=" & GUICtrlRead($txtInstallationDrive) & ": /partitions", @TempDir, "", @SW_SHOWMINNOACTIVE)

		WinWaitActive("[REGEXPTITLE:(?i)Partitions Management|Pauly]")

		If WinActive("[REGEXPTITLE:(?i)Pauly]") Then
			ProcessClose("bootice.exe")
			MsgBox(48, "Windows 7 fast installer", "Invalid installation drive", 0, $frmMain)
			GUICtrlSetData($txtInstallationDrive, "")
			GUICtrlSetState($txtInstallationDrive, $GUI_FOCUS)
			GUISetState(@SW_SHOW, $frmMain)
		Else
			WinWaitClose("[REGEXPTITLE:(?i)Pauly]")
			GUISetState(@SW_SHOW, $frmMain)
		EndIf
	Else
		GUICtrlSetState($txtInstallationDrive, $GUI_FOCUS)
	EndIf
EndFunc   ;==>btnPartitionManagementClick

Func frmMainClose()
	_DoCleanUp()
	Exit
EndFunc   ;==>frmMainClose

Func frmOutputClose()
	WinSetState("Installing Windows...", "", @SW_HIDE)
	IniWrite($sIni, "internals", "exitflag", 1)
	ProcessClose("imagex.exe")
	WinActivate("Windows 7 fast installer")
	WinSetState("Windows 7 fast installer", "", @SW_SHOW)
EndFunc   ;==>frmOutputClose

Func mnuAboutClick()
	SplashTextOn("Windows 7 fast installer", "Windows 7 fast installer" & @LF & @LF & "© 2011 Sadeghi85", 150, 100, -1, -1, 33, "", 8)
	Sleep(3000)
	SplashOff()
EndFunc   ;==>mnuAboutClick

Func mnuExitClick()
	_DoCleanUp()
	Exit
EndFunc   ;==>mnuExitClick

Func txtInstallationDriveChange()
	If Asc(StringLower(GUICtrlRead(@GUI_CtrlId))) < 97 Or Asc(StringLower(GUICtrlRead(@GUI_CtrlId))) > 122 Then
		GUICtrlSetData(@GUI_CtrlId, "")
	EndIf
EndFunc   ;==>txtInstallationDriveChange

Func btnInstallClick()
	If Not StringLen(GUICtrlRead($txtBootDrive)) Then
		GUICtrlSetState($txtBootDrive, $GUI_FOCUS)
		Return
	EndIf

	If Not StringLen(GUICtrlRead($txtInstallationDrive)) Then
		GUICtrlSetState($txtInstallationDrive, $GUI_FOCUS)
		Return
	EndIf

	If Not $iEdition Then
		If GUICtrlGetState($cmbEdition) = $GUI_SHOW + $GUI_DISABLE Then
			GUICtrlSetState($btnBrowse, $GUI_FOCUS)
		Else
			GUICtrlSetState($cmbEdition, $GUI_FOCUS)
		EndIf

		Return
	EndIf

	If StringLen(GUICtrlRead($txtPathToSource)) Then

		If MsgBox(289, "Windows 7 fast installer", "Are you sure you want to continue with the installation?", 0, $frmMain) <> 1 Then Return

		ShellExecute(@AutoItExe, $CMDLINERAW & " -install" & ' "' & GUICtrlRead($txtPathToSource) & '" ' & $iEdition & ' ' & GUICtrlRead($txtInstallationDrive) & ' ' & GUICtrlRead($txtBootDrive), @ScriptDir, "", @SW_HIDE)
	Else
		GUICtrlSetState($btnBrowse, $GUI_FOCUS)
	EndIf
EndFunc   ;==>btnInstallClick
