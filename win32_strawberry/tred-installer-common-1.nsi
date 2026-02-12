;--------------------------------
;Interface Settings

        !define MUI_HEADERIMAGE
        ; Display TrEd logo in the header
        !define MUI_HEADERIMAGE_BITMAP "resources\tred.bmp"
        ; And also use TrEd icon for the installer
        !define MUI_ICON "resources\tred.ico"

        ; Show a message box with a warning when the user wants to close the installer.
        !define MUI_ABORTWARNING
        ; Larger space for components, don't need long description
        !define MUI_COMPONENTSPAGE_SMALLDESC
        ; Do not automatically jump to the finish page, to allow the user to check the (un)install log.
        !define MUI_FINISHPAGE_NOAUTOCLOSE
        !define MUI_UNFINISHPAGE_NOAUTOCLOSE

;--------------------------------
;Pages
        ;; Installer
        ; Page 1 -- Welcome page
        !insertmacro MUI_PAGE_WELCOME
        ; Page 2 -- Install Perl & basic perl functionality test
        Page custom nsdChoosePerl nsdChoosePerlPageLeave
        ; Page 3 -- Accept TrEd's license
        !insertmacro MUI_PAGE_LICENSE "tred\LICENSE"
        ; Page 4 -- Choose TrEd installation directory -- so we also know where to install dependencies
        !insertmacro MUI_PAGE_DIRECTORY
        ; Page 5 -- Choose TrEd components (probably extensions)
        !insertmacro MUI_PAGE_COMPONENTS
        ; Page 6 -- Install Perl modules from CPAN
        ; Page custom nsdInstallPerlModules
        ; Page cancelled
        ; maybe later -- check and report which modules are not installed
        ; nsdInstallPerlModulesLeave

        ; Page 7 -- TrEd installation procedure itself
        !insertmacro MUI_PAGE_INSTFILES
        ; Show doc after installation?
        !define MUI_FINISHPAGE_SHOWREADME $INSTDIR\documentation\index.html
        ; Finish page
        !insertmacro MUI_PAGE_FINISH

        ;; Uninstaller
        ; Page 1 -- Welcome page
        !insertmacro MUI_UNPAGE_WELCOME
        ; Page 2 --
        !insertmacro MUI_UNPAGE_CONFIRM
        ; Page 3 --
        !insertmacro MUI_UNPAGE_INSTFILES
        ; Page 4 -- Finish page
        !insertmacro MUI_UNPAGE_FINISH


;--------------------------------


;; Be careful, all variables in NSIS are global,
;; so things can get pretty messy...

; nsDialogs page
Var Dialog
; shared variable for labels
Var Label
; Label next to nsB_Strawberry -- install strawberry perl button
Var StrPerlLabel
; Label showing whether the Perl is installed
Var PerlInstalledLabel
; nsDialogs Button for installation Strawberry Perl
Var nsB_Strawberry
; nsDialogs Button for installation Active Perl
;Var nsB_ActivePerl
; nsDialogs CheckBox for custom Perl dir
Var CB_ChoosePerlDir
; state of the CheckBox for custom Perl dir
Var CB_state_ChoosePerlDir
; nsDialogs Directory Request element
Var nsDirReq_customPerlDir
; nsDialogs Button for firing up the standard 'Choose directory' window
Var nsButton_customPerlDir
; custom Per folder, if any...
Var CustomPerlFolder

; Perl Version in the form of 5.8, 5.10, 5.12 string, set by testPerl function
Var PerlVersion
; Is "1" if the Perl version is ok, "0" otherwise, set by testPerl function
Var PerlVersionOk
; "Active" or "Strawberry", depends on whether the module "ActivePerl" is installed,
; set by testPerl function
Var PerlFlavour
; Path, where perl.exe is found, set by testPerl function
Var PerlPath
; Base path of Perl installation, for Active Perl it is PerlPath without "\bin",
; for Strawberry Perl PerlPath without "perl\bin"
Var PerlPathBase

; Information for the user about his perl version, flavour and folder
Var PerlMsg
; Shared return value from various functions
Var RetVal

; the Perl version that suits TrEd best
Var DesiredPerlVersion

; Downloaded html page (with links to Perl distribution)
; Var HtmlPage
; Line read from a file (shared variable)
; Var Line

; Var Result
; Position of anchor with a link to Perl installer
; Var AnchorBeginPos
; Var AnchorEndPos
; The link for downloading Perl distribution
Var DownLink
; Name of Perl installer (both on their servers and locally)
Var PerlInstallerName


; working directory for TrEd
Var tredDataDir
; Name of the perl script passed as an argument to a function
Var PerlScript

; Installation directory in 8.3 format
Var INSTDIR_SHORT

; perl's architecture name
Var PerlConfigArchname

; original PATH environment variable
Var OriginalPath

; path where strawberry perl is installed
Var StrawberryDefaultPath

; perl modules installer thread
Var ThreadRunning

; path to log file for CPAN modules installation
Var ModulesLogFile

; number of lines in log file
Var LogFileLineCount

; var holding count of lines in generic line counting function
Var CountLines


Function .onInit
        ; we don't know yet whether any kind of perl is installed
        StrCpy $PerlVersionOk "0"

        ; save original path env variable
        ReadEnvStr $OriginalPath "PATH"

        ; default path where strawberry perl is usually installed
        StrCpy $StrawberryDefaultPath "C:\Strawberry\c\bin;C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin"

        ; try to find perl executable and version
        Call testPerl
        ; this is the default version that will be downloaded if the user does not have any perl installed
        ;;StrCpy $DesiredPerlVersion "5.16"
        ;;StrCpy $DownLink "http://strawberry-perl.googlecode.com/files/strawberry-perl-5.16.3.1-32bit.msi"
        StrCpy $DesiredPerlVersion "5.24"
        StrCpy $DownLink "http://strawberryperl.com/download/5.24.0.1/strawberry-perl-5.24.0.1-32bit.msi"
        StrCpy $CustomPerlFolder ""
        ; does the user need to configure that?
        StrCpy $tredDataDir "$LOCALAPPDATA\tred_data"

        ; tell MakeMaker that we are running non interactively
        StrCpy $R0 "1"
        System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PERL_MM_USE_DEFAULT", R0).r0'
        StrCmp $0 0  "" +2
                MessageBox MB_OK "Can't set environment variable, please install XML::SAX module manually."

FunctionEnd

; Checks whether Perl exists and its version
Function testPerl
        ; set original PATH (if the user changes his decision to go from custom perl path to default one)
        ; prepend default strawberry path if it is installed
        ; (if Active Perl is installed too, Strawberry should have higher priority)
        StrCpy $R0 "$StrawberryDefaultPath;$OriginalPath"
        System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'
        StrCmp $0 0  "" +2
                MessageBox MB_OK "Can't set environment variable, won't be able to find Perl."

        ; In case we use Perl distribution which is not in the PATH
        ${If} $CustomPerlFolder == ""
                ; we do not have to modify PATH variable
        ${Else}
                ; Modify path only if custom path is not empty && checkbox is checked
                ${If} $CB_state_ChoosePerlDir == ${BST_CHECKED}
                        ; modify PATH variable (for this installer only)
                        ReadEnvStr $R0 "PATH"
                        StrCpy $R0 "$CustomPerlFolder;$R0;"
                        ; MessageBox MB_OK "set path to $R0"
                        System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'
                        StrCmp $0 0 "" +2
                                MessageBox MB_OK "Could not set environment variable"
                ${EndIf}

        ${EndIf}

        nsExec::ExecToStack "perl -e $\"$$_=$$];s/...$$//;s/\.0+/./;print$\""
        Pop $RetVal
        Pop $PerlVersion
        ${If} $RetVal == "0"
                ; OK, perl found
        ${Else}
                StrCpy $PerlMsg "Perl not found. Install Perl or choose a directory containing Perl executable."
                Goto done
        ${EndIf}

        ; find perl executable
        nsExec::ExecToStack "perl -MConfig -e $\"print $$Config{perlpath}$\""
        Pop $0
        Pop $PerlPath

        ; find out perl flavour
        nsExec::ExecToStack 'perl -MActivePerl -e 1'
        Pop $RetVal
        Pop $R0

        ${If} $RetVal == "0"
                StrCpy $PerlFlavour "Active"
        ${Else}
                StrCpy $PerlFlavour "Strawberry"
        ${EndIf}

        ${If} $PerlFlavour == "Active"
                StrCpy $PerlMsg "Active Perl is no longer supported. Please install Strawberry Perl 5.24, or choose a directory which contains Strawberry Perl executable."
                Goto done
        ${EndIf}

        ${If} $PerlVersion == ""
                StrCpy $PerlMsg "Perl not found. Install Perl or choose a directory containing Perl executable."
        ${ElseIf} $PerlVersion == "5.8"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${ElseIf} $PerlVersion == "5.10"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${ElseIf} $PerlVersion == "5.12"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${ElseIf} $PerlVersion == "5.14"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${ElseIf} $PerlVersion == "5.16"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${ElseIf} $PerlVersion == "5.24"
                StrCpy $PerlMsg "$PerlFlavour Perl $PerlVersion found in $PerlPath, OK."
                StrCpy $PerlVersionOk "1"
        ${Else}
                StrCpy $PerlMsg "Perl version ($PerlVersion) not supported. Please install Strawberry Perl 5.24, or choose a directory containing Perl executable."
        ${EndIf}
        done:
FunctionEnd
