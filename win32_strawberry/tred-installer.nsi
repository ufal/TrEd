;--------------------------------
;Include Modern UI, nsDialogs, LogicLib and String Functions
        !addplugindir "resources\nsis_plugins\Plugins"
        !include "MUI2.nsh"
        !include nsDialogs.nsh
        !include LogicLib.nsh
        !include "StrFunc.nsh"

;       ${StrStr} # Supportable for Install Sections and Functions
;    ${UnStrStr} # Supportable for Uninstall Sections and Functions
        ${StrLoc} # Supportable for Install Sections and Functions
        ${StrStrAdv} # Supportable for Install Sections and Functions
;    ${UnStrLoc} # Supportable for Uninstall Sections and Functions
;---------------------------------

;General

        ;Name and file
        Name "TrEd"
        OutFile "tred-installer.exe"

        ;Default installation folder
        InstallDir "$PROGRAMFILES\tred"

        ;Get installation folder from registry if available
        InstallDirRegKey HKCU "Software\TrEd\" "Dir"

        ;Request application privileges for Windows Vista
        RequestExecutionLevel admin


!include "tred-installer-common-1.nsi"

; Function findStrawberryPerlLink
;         ClearErrors
;         ;; find build number
;         ; Download webpage with versions of Perl and links to installers
;         inetc::get "http://strawberryperl.com/" "$TEMP\strawberry-page.html"
;         Pop $R0 ;Get the return value
;         StrCmp $R0 "OK" +3
;                 MessageBox MB_OK "Download failed: $R0 $\nPlease exit installer and install Perl manually."
;                 Quit


;         ; find link on the page
;         FileOpen $HtmlPage $TEMP\strawberry-page.html r
;         IfErrors done
;         loop:
;                 FileRead $HtmlPage $Line
;                 IfErrors close
;                 ${StrLoc} $Result $Line $DesiredPerlVersion ">"
;                 IntCmp $Result 0 loop
;                 ; find position of string "<a href=" in the line
;                 ${StrLoc} $AnchorBeginPos $Line "<a href=" ">"
;                 ; find position of string "$\">" in the line
;                 ${StrLoc} $AnchorEndPos $Line "$\">" ">"
;                 ; copy the text between these 2 strings to DownLink
;                 IntOp $0 $AnchorEndPos - $AnchorBeginPos
;                 IntOp $1 $0 - 9
;                 IntOp $AnchorBeginPos $AnchorBeginPos + 9
;                 StrCpy $DownLink $Line $1 $AnchorBeginPos

;                 ;       MessageBox MB_OK "riadok: $DownLink"
;                 ;Goto loop
;         close:
;                 FileClose $HtmlPage
;         ; find link to active perl installation package

;         done:
; FunctionEnd

Function installStrawberryPerl
        ; find download link for strawberry perl
        ; Call findStrawberryPerlLink

        ; download msi installer
        MessageBox MB_YESNO|MB_ICONQUESTION \
                        "Do you want to download file from URL: $\n\
                        $DownLink $\n \
                        and install Strawberry Perl?" \
                        IDNO done
        ;;; docasne, aby sa nemuselo znova stahovat...
        StrCpy $PerlInstallerName "strawberry-perl.msi"
        IfFileExists $TEMP\$PerlInstallerName install

        inetc::get /POPUP "$DownLink" /CAPTION "Downloading Strawberry Perl..." "$DownLink" "$TEMP\$PerlInstallerName" /END
        Pop $R0 ;Get the return value
        StrCmp $R0 "OK" +3
                MessageBox MB_OK "Download failed: $R0 $\nPlease exit installer and install Perl manually."
                Quit

        ; start strawberry perl installation
        install:
        ExecWait '"msiexec" /i "$TEMP\$PerlInstallerName"'
        IfErrors error done
        error:
                MessageBox MB_OK "Installation failed. $\nSometimes it is a false alarm (usually on Windows 7). $\nIf not, please exit installer and install Perl manually."
                Call testPerl
                ; Update label after Perl installation
                ${NSD_SetText} $PerlInstalledLabel $PerlMsg
                Pop $Label
                Quit
        done:
                ; update PATH from registry, or we wouldn't be able to find newly installed Perl
                ; set both OriginalPath and PATH environment variable so that modules can be installed
                ; (hopefully) flawlessly
                ; HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment -> Path
                ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"

                ; expand Path read before ^^ into OriginalPath
                ExpandEnvStrings $OriginalPath $0

                ;StrCpy $R0 "$OriginalPath"
                StrCpy $R0 "$StrawberryDefaultPath;$OriginalPath"
                System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'
                StrCmp $0 0  "" +2
                        MessageBox MB_OK "Can't set environment variable"


                Call testPerl

                ; Active Perl is still first in PATH, prompt the user to choose custom Perl directory
                ${If} $PerlFlavour == "Active"
                        StrCpy $PerlMsg "Strawberry Perl installed correctly. Since Active Perl remained your primary Perl distribution, you need to choose custom Perl directory."
                ${EndIf}

                ; Update label after Perl installation
                ${NSD_SetText} $PerlInstalledLabel $PerlMsg
                Pop $Label

                ; Hide install button, if the installation was successful
                ${If} $PerlVersionOk == "1"
                        ; if installed & perl version is ok, hide button
                        ShowWindow $nsB_Strawberry ${SW_HIDE}
                        ShowWindow $StrPerlLabel ${SW_HIDE}
                ${EndIf}
FunctionEnd

!include "tred-installer-common-2.nsi"
