; Shows dialog for choosing custom Perl directory
Function BrowseForFolder
	nsDialogs::SelectFolderDialog "Select Perl folder" "c:\"
	pop $CustomPerlFolder
	${NSD_SetText} $nsDirReq_customPerlDir $CustomPerlFolder
FunctionEnd

; Function for showing installer Page 2 -- install Perl 
Function nsdChoosePerl
	!insertmacro MUI_HEADER_TEXT "Perl installation" "Choose your Perl distribution or custom Perl directory"
	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}
	
	;show perl executable path and whether the perl version is ok
	${NSD_CreateLabel} 0 0 100% 25u $PerlMsg
	Pop $PerlInstalledLabel
	
	; if there are some problems with version or finding perl, offer installation options
	${If} $PerlVersionOk == "1"
	${Else}
		${NSD_CreateLabel}  40u 39u -30u 12u "Strawberry Perl"
		Pop $StrPerlLabel
		${NSD_CreateButton} 5u 28u 30u 30u "Install"
		Pop $nsB_Strawberry
		${NSD_OnClick} $nsB_Strawberry installStrawberryPerl
		
	${EndIf}
	
	
	${NSD_CreateCheckBox} 5u 108u 100% 15u "Choose custom Perl directory"
	Pop $CB_ChoosePerlDir
	${NSD_SetState} $CB_ChoosePerlDir $CB_state_ChoosePerlDir
	
	${NSD_CreateDirRequest} 5u 124u 75% 15u ""
	Pop $nsDirReq_customPerlDir
	${NSD_SetText} $nsDirReq_customPerlDir $CustomPerlFolder
	
	${NSD_CreateBrowseButton} -15% 124u 15% 15u "Browse"
	Pop $nsButton_customPerlDir
	${NSD_OnClick} $nsButton_customPerlDir BrowseForFolder
	
	nsDialogs::Show
FunctionEnd

; Function is called automatically when the user leaves Page 2 -- the installation of Perl
Function nsdChoosePerlPageLeave
	; save user's choice (if he goes back, etc)
	${NSD_GetState} $CB_ChoosePerlDir $CB_state_ChoosePerlDir
	${NSD_GetText} $nsDirReq_customPerlDir $CustomPerlFolder
	Call testPerl
	
;	${If} $CB_state_ChoosePerlDir == 1
;		MessageBox MB_OK "Using Perl from directory $CustomPerlFolder"
;		MessageBox MB_OK "$PerlMsg"
;	${Else}
;		MessageBox MB_OK "Using Perl from directory $PerlPath"
;		MessageBox MB_OK "$PerlMsg"
;	${EndIf}
	
	${If} $PerlVersionOk == "1"
		; let the user go to the next page
		; We need to set library path environment variable for the rest of the script
		; so it does not use other make, g++, gcc and so on (ie when both ActivePerl and Strawberry Perl are installed)...
		ReadEnvStr $R0 "PATH"
		; Active Perl is no longer supported, but if we changed our mind, I'll leave it here 
		; since it does not do any harm, $PerlVersionOk can not be 1 if $PerlFlavour is "Active"
		${If} $PerlFlavour == "Active" 
			; search from left (>) in PerlPath for string "bin" and return string to the left of the found string (<)
			; exclude "\bin.*" from result, do not loop and be case-insensitive
			${StrStrAdv} $PerlPathBase $PerlPath "\bin" ">" "<" "0" "0" "0"
			; put active perl's executables (dmake, g++, gcc, perl) before any other executables
			StrCpy $R0 "$PerlPathBase\site\bin;$PerlPathBase\bin;$R0;"
		${Else}
			; search from left (>) in PerlPath for string "\perl\bin" and return string to the left of the found string (<)
			; exclude "\perl\bin.*" from result, do not loop and be case-insensitive
			${StrStrAdv} $PerlPathBase $PerlPath "\perl\bin" ">" "<" "0" "0" "0"
			; put strawberry perl's executables (dmake, g++, gcc, perl) before any other executables
			StrCpy $R0 "$PerlPathBase\c\bin;$PerlPathBase\perl\site\bin;$PerlPathBase\perl\bin;$R0;"
		${EndIf}
		 
		; MessageBox MB_OK "path: $R0"
		System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'
		StrCmp $0 0 "" +2
			MessageBox MB_OK "Could not set PATH environment variable"
		
		ReadEnvStr $R0 "LIBRARY_PATH"
		StrCpy $R0 "$PerlPathBase\c\lib\gcc\mingw32\3.4.5\;$PerlPathBase\c\lib;$R0"
		
		;MessageBox MB_OK "library_path: $R0"
		System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("LIBRARY_PATH", R0).r0'
		StrCmp $0 0 "" +2
			MessageBox MB_OK "Could not set LIBRARY_PATH environment variable"
	${Else}
		; don't leave this page until perl is correctly installed & located
		MessageBox MB_ICONEXCLAMATION "Can not find Strawberry Perl. Please install Strawberry Perl or choose custom Perl directory, if it is already installed. (Usually C:\strawberry\perl\bin)"
		Abort
	${EndIf}
	
FunctionEnd

; Enables or disables Next, Back and Cancel buttons (ie during isntallation of Perl modules)
Function enableNext

  GetDlgItem $0 $HWNDPARENT 1
  EnableWindow $0 $R0
;  GetDlgItem $0 $HWNDPARENT 2
;  EnableWindow $0 $R0
  GetDlgItem $0 $HWNDPARENT 3
  EnableWindow $0 $R0

FunctionEnd


Function nsdInstallPerlModules 
	!insertmacro MUI_HEADER_TEXT "Perl modules installation" "Installing TrEd Perl dependencies"
	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}
	
	; show some basic perl info
	${NSD_CreateLabel} 0 0 100% 12u "Installing modules for $PerlFlavour Perl"
	Pop $Label
	; Let the user see the basic log from installation of Perl modules
	nsDialogs::CreateControl EDIT \
		"${__NSD_Text_STYLE}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN}" \
		"${__NSD_Text_EXSTYLE}" \
		0 20 100% 70% \
		"Installing TrEd dependencies...$\r$\n"
		Pop $hwnd
	
	; Extract local cpan files to temporary installation directory
	SetOutPath "$TEMP\local_cpan"
	File /r "resources\cpan_script\*.*"
	
	StrCpy $R0 0
	Call enableNext
	StrCpy $R0 1
	GetFunctionAddress $R2 enableNext
	; When user chooses other perl, PATH is modified, so we are safe running perl without specifying path
	; We have to convert install_base to short (8.3) file name, because if it contains spaces, the install would fail badly, 
	; MakeMaker can not handle such names properly
	; For the short path name to work, we actually need the directory to exist...
	CreateDirectory $INSTDIR
	GetFullPathName /SHORT $INSTDIR_SHORT $INSTDIR
	
 	ExecDos::exec /NOUNLOAD /ASYNC /TOWINDOW /ENDFUNC=$R2 "cmd.exe /c perl $\"$TEMP\local_cpan\dpan\install_deps.pl$\" --install-base $INSTDIR_SHORT\dependencies --log $INSTDIR_SHORT\dependencies-install-log.txt 2>&1" "" $hwnd
	Pop $R9
	
	nsDialogs::Show
	
	ExecDos::wait $R9
	Pop  $R4
	
	; clean up
	RMDir /r "$TEMP\local_cpan"
FunctionEnd


Function createBat
	; find perl's architecture name
	nsExec::ExecToStack 'perl -MConfig -e "print \$\"$Config{archname}\$\""'
	Pop $0
	Pop $PerlConfigArchname
	
	ClearErrors
	FileOpen $0 "$INSTDIR\$PerlScript.bat" w
	IfErrors error no_error
	error:
		DetailPrint "Could not create $PerlScript.bat"
		GoTo done
	no_error:
	FileWrite $0 "@echo off$\r$\n"
	FileWrite $0 "set PATH=$INSTDIR_SHORT\c\bin;$INSTDIR_SHORT\bin;$INSTDIR_SHORT\dependencies\bin;%PATH%$\r$\n"
	FileWrite $0 "set PERL5LIB=$INSTDIR_SHORT\dependencies\lib\perl5;$INSTDIR_SHORT\dependencies\lib\perl5\$PerlConfigArchname;%PERL5LIB%$\r$\n"
	FileWrite $0 "set TRED_DIR=$INSTDIR_SHORT$\r$\n"
	FileWrite $0 "$\r$\n"
	FileWrite $0 "if $\"%OS%$\" == $\"Windows_NT$\" goto WinNT$\r$\n"
	FileWrite $0 "$PerlPath $PerlScript %1 %2 %3 %4 %5 %6 %7 %8 %9$\r$\n"
	FileWrite $0 "goto end$\r$\n"
	FileWrite $0 ":WinNT$\r$\n"
	FileWrite $0 "$\"$PerlPath$\" $\"$PerlScript$\" %*$\r$\n"
	FileWrite $0 ":end$\r$\n"
	FileWrite $0 "$\r$\n"
	FileClose $0
	DetailPrint "$PerlScript.bat created"
	done:
FunctionEnd

;--------------------------------
;Installer Sections


Section "TrEd" SecTrEd

	SetOutPath "$INSTDIR"
	File /r "tred\*"
	
	;SetOutPath "$INSTDIR\sample_data"
	;File /r "sample_data\*"
	
	; Needed for printing and as nsgmls lib
	SetOutPath "$INSTDIR\bin"
	File /r "tools\nsgmls\*"
	File /r "tools\print\*"
	; remove the svn hidden directory
	RMDir /r "$INSTDIR\bin\.svn\"

	CreateDirectory "$tredDataDir"
	
	; create bat files
	DetailPrint "Creating bat files..."
	StrCpy $PerlScript "tred"
	Call createBat
	StrCpy $PerlScript "btred"
	Call createBat
	StrCpy $PerlScript "trprint"
	Call createBat
	StrCpy $PerlScript "any2any"
	Call createBat
	
	;Store installation folder
	WriteRegStr HKCU "Software\TrEd" "Dir" $INSTDIR

	;Create uninstaller
	WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Start menu shortcut" SecTrEdSMShortcut
	CreateDirectory "$SMPROGRAMS\TrEd"
	;;; should I put tred to path or..?
	;SetOutPath $tredDataDir
	SetOutPath $INSTDIR
	CreateShortCut "$SMPROGRAMS\TrEd\TrEd.lnk" "$INSTDIR\tred.bat" "" "$INSTDIR\tredlib\tred.ico"
	CreateShortCut "$SMPROGRAMS\TrEd\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Desktop shortcut" SecTrEdDesktopShortcut
	;SetOutPath $tredDataDir
	SetOutPath $INSTDIR
	CreateShortCut "$DESKTOP\TrEd.lnk" "$INSTDIR\tred.bat" "" "$INSTDIR\tredlib\tred.ico"
	;CreateShortCut "$SMPROGRAMS\TrEd\TrEd.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

;; not for now, TrEd has a nice tool to install extensions
; SectionGroup "Extensions" SecExts
	;;this should be better generated by some script...

	; Section "PDT 2.0" SecPDT20
	; SectionEnd

	; Section "Vallex"
	; SectionEnd

; SectionGroupEnd
;--------------------------------
;Languages
 
	!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Version info

	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "TrEd"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "UFAL"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "(c) Petr Pajas"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Tree Editor"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "1.4.5.1.3"

	VIProductVersion "1.4.5.1.3"

;--------------------------------
;Descriptions

	;Language strings
	LangString DESC_SecTrEd ${LANG_ENGLISH} "Tree Editor TrEd"
	LangString DESC_SecTrEdSMShortcut ${LANG_ENGLISH} "Create TrEd's shortcut in start menu"
	LangString DESC_SecTrEdDesktopShortcut ${LANG_ENGLISH} "Create TrEd's shortcut on desktop menu"
;	LangString DESC_SecExts ${LANG_ENGLISH} "Choose TrEd extensions"
;	LangString DESC_SecPDT20 ${LANG_ENGLISH} "Prague Dependency Treebank 2.0"

	;Assign language strings to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
		!insertmacro MUI_DESCRIPTION_TEXT ${SecTrEd} $(DESC_SecTrEd)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecTrEdSMShortcut} $(DESC_SecTrEdSMShortcut)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecTrEdDesktopShortcut} $(DESC_SecTrEdDesktopShortcut)
;		!insertmacro MUI_DESCRIPTION_TEXT ${SecExts} $(DESC_SecExts)
;		!insertmacro MUI_DESCRIPTION_TEXT ${SecPDT20} $(DESC_SecPDT20)
	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

	RMDir /r "$INSTDIR\bin\"
	RMDir /r "$INSTDIR\devel\"
	RMDir /r "$INSTDIR\documentation\"
	RMDir /r "$INSTDIR\dependencies\"
	RMDir /r "$INSTDIR\examples\"
	RMDir /r "$INSTDIR\resources\"
	RMDir /r "$INSTDIR\tredlib\"
	RMDir /r "$INSTDIR\t\"
	;RMDir /r "$INSTDIR\sample_data\"
	
	RMDir /r "$APPDATA\.tred.d\"
	Delete "$APPDATA\.tredrc"
	Delete "$APPDATA\.tred_bookmarks"
	
	RMDir /r "$LOCALAPPDATA\tred_data\"
	
	; delete shortcuts from start menu
	Delete "$SMPROGRAMS\TrEd\TrEd.lnk"
	Delete "$SMPROGRAMS\TrEd\Uninstall.lnk"
	RMDir  "$SMPROGRAMS\TrEd"
	; and from desktop
	Delete "$DESKTOP\TrEd.lnk"
	
	Delete "$INSTDIR\any2any"
	Delete "$INSTDIR\any2any.bat"
	Delete "$INSTDIR\btred"
	Delete "$INSTDIR\btred.bat"
	Delete "$INSTDIR\ChangeLog"
	Delete "$INSTDIR\jtred"
	Delete "$INSTDIR\LICENSE"
	Delete "$INSTDIR\ntred"
	Delete "$INSTDIR\README"
	Delete "$INSTDIR\tred"
	Delete "$INSTDIR\tred.bat"
	Delete "$INSTDIR\trprint.bat"
		
	Delete $INSTDIR\Uninstall.exe

	RMDir "$INSTDIR"

	DeleteRegKey /ifempty HKCU "Software\TrEd"

SectionEnd
