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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Easily opens files with more options than FileOpen 
;;   P1 :o: Handle returned 
;;   P2 :i: File name 
;;   P3 :i: Access Mode 
;;         'r'  : Readonly 
;;         'w'  : Writeonly 
;;         'rw' : Read+Write 
;;   P4 :i: Share mode 
;;         ''    : None 
;;         'r'   : Readonly 
;;         'rw'  : Read+Write 
;;         'rwd' : Read+Write+Delete 
;;   P5 :i: Create mode 
;;         ''  : Open existing only 
;;         'c' : Create if not exist 
;;         'o' : Create and Overwrite 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
!define FileOpenEx "!insertmacro _FileOpenEx" 
!macro _FileOpenEx _Handle_ _File_ _Access_ _Share_ _Create_ 
   Push "${_Create_}" 
   Push "${_Share_}" 
   Push "${_Access_}" 
   Push "${_File_}" 
   Call FileOpenEx 
   Pop ${_Handle_} 
!macroend 

Function FileOpenEx  ;; $0:File, $1:Access, $2:Sharing, $3:Create 
   Exch $0 
   Exch 
   Exch $1 
   Exch 2 
   Exch $2 
   Exch 3 
   Exch $3 

   StrCmp "r" $1 0 +3 
      StrCpy $1 0x80000000  ;; GENERIC_READ 
      Goto +6 
   StrCmp "w" $1 0 +3 
      StrCpy $1 0x40000000  ;; GENERIC_WRITE 
      Goto +3 
   StrCmp "rw" $1 0 +3 
      StrCpy $1 0xC0000000  ;; GENERIC_READ | GENERIC_WRITE 

   StrCmp "" $2 0 +3 
      StrCpy $2 0   ;; FILE_SHARE_NONE 
      Goto +9 
   StrCmp "r" $2 0 +3 
      StrCpy $2 1   ;; FILE_SHARE_READ 
      Goto +6 
   StrCmp "rw" $2 0 +3 
      StrCpy $2 3   ;; FILE_SHARE_READ | FILE_SHARE_WRITE 
      Goto +3 
   StrCmp "rwd" $2 0 +3 
      StrCpy $2 7   ;; FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE 

   StrCmp "" $3 0 +3 
      StrCpy $3 3   ;; OPEN_EXISTING 
      Goto +6 
   StrCmp "c" $3 0 +3 
      StrCpy $3 4   ;; OPEN_ALWAYS 
      Goto +3 
   StrCmp "o" $3 0 +3 
      StrCpy $3 2   ;; CREATE_ALWAYS 

   System::Call 'Kernel32::CreateFile(t, i, i, i, i, i, i) i (r0, r1, r2, 0, r3, 0x80, 0) .r2'  ;; Open/Create file 

   Pop $3 
   Pop $0 
   Pop $1 
   Exch $2 
FunctionEnd  

Var LogFile_

; counts number of lines in a file, comes from http://nsis.sourceforge.net/Get_number_of_lines_in_text_file
Function LineCount
	Exch $R0
	Push $R1
	Push $R2
	;MessageBox MB_OK "File $R0"
	StrCpy $CountLines "0"
	;DetailPrint "Opening $R0 now..."
	${FileOpenEx} $LogFile_ $R0 "r" "rwd" ""
	IfErrors done
	;DetailPrint "open successful"
	loop:
		ClearErrors
		FileRead $LogFile_ $R1
		IfErrors +3
		IntOp $CountLines $CountLines + 1
	Goto loop
	
	done:
	FileClose $LogFile_
	StrCpy $R0 $CountLines
	Pop $R2
	Pop $R1
	Exch $R0
FunctionEnd


Function createBat
	; find perl's architecture name
	nsExec::ExecToStack "perl -MConfig -e $\"print $$Config{archname}$\""
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

; the progress of perl modules installation
Var Percent_finished

Section "TrEd" SecTrEd
	
	; clean up
	RMDir /r "$TEMP\local_cpan"
	DetailPrint "Zmazany temp!"

	; Extract local cpan files to temporary installation directory
	SetOutPath "$TEMP\local_cpan"
	File /r "resources\cpan_script\*.*"
	
	CreateDirectory $INSTDIR
	GetFullPathName /SHORT $INSTDIR_SHORT $INSTDIR
	StrCpy $ModulesLogFile "$INSTDIR_SHORT\dependencies-install-log.txt"

	;DetailPrint "Starting Perl Modules installation..."
	ExecDos::exec /NOUNLOAD /ASYNC /DETAILED /ENDFUNC=$R2 "cmd.exe /c set PERL_MM_USE_DEFAULT=1 && perl $\"$TEMP\local_cpan\dpan\install_deps.pl$\" --install-base $INSTDIR_SHORT\dependencies 1> $ModulesLogFile 2>&1"
	Pop $R9
		
	ExecDos::isdone /NOUNLOAD $R9
	Pop $ThreadRunning
	

	${While} $ThreadRunning = 0
		; count number of lines
		Push $ModulesLogFile ;text file
		Call LineCount
		Pop $LogFileLineCount
		
		; 8723 is number of lines in sample log file installation, 1% ... 55 lines, 
		; +3 is a little reserve
		IntOp $Percent_finished $LogFileLineCount / 90
		${If} $Percent_finished > 100
			IntOp $Percent_finished 100 + 0
		${EndIf}
		DetailPrint "Installing Perl modules, please wait: $Percent_finished % complete...";
		
		; update progress bar?
		
		; check if thread is running
		ExecDos::isdone /NOUNLOAD $R9
		Pop $ThreadRunning
		
		; sleep 10 seconds
		Sleep 10000
	${EndWhile}
	
	StrCpy $Percent_finished "100"
	DetailPrint "Installing Perl modules, please wait: $Percent_finished % complete...";
	
	; clean up
	RMDir /r "$TEMP\local_cpan"
	DetailPrint "Temp deleted"
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;TODO: set product version during release?
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
