7-Zip for installers 4.57
-------------------------

7-Zip is a file archiver for Windows 98/ME/NT/2000/2003/XP. 

7-Zip Copyright (C) 1999-2007 Igor Pavlov.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

7zr.exe is reduced version of 7za.exe of 7-Zip.
7zr.exe supports only 7z format with this codecs: LZMA, BCJ, BCJ2, Copy.

Example of compressing command for installation packages:

7zr a -t7z archive.7z * -m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx


7zSD.sfx is SFX module for installers (it uses msvcrt.dll)

SFX modules for installers (7zS.sfx and 7zSD.sfx) allow to create installation program. 
Such module extracts archive to temp folder and then runs specified program and removes 
temp files after program finishing. Self-extract archive for installers must be created 
as joining 3 files: SFX_Module, Installer_Config, 7z_Archive. 
Installer_Config is optional file. You can use the following command to create installer 
self-extract archive:

copy /b 7zSD.sfx + config.txt + archive.7z archive.exe

The smallest installation package size can be achivied, if installation files was 
uncompressed before including to 7z archive.

-y switch for installer module (at runtime) specifies quiet mode for extracting.

Installer Config file format
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Config file contains commands for Installer. File begins from string 
;!@Install@!UTF-8! and ends with ;!@InstallEnd@!. File must be written 
in UTF-8 encoding. File contains string pairs: 

ID_String="Value"

ID_String          Description 

Title              Title for messages 
BeginPrompt        Begin Prompt message 
Progress           Value can be "yes" or "no". Default value is "yes". 
RunProgram         Command for executing. Default value is "setup.exe". 
                   Substring %%T will be replaced with path to temporary 
                   folder, where files were extracted 
Directory          Directory prefix for "RunProgram". Default value is ".\\" 
ExecuteFile        Name of file for executing 
ExecuteParameters  Parameters for "ExecuteFile" 


You can omit any values.

There are two ways to run program: RunProgram and ExecuteFile. 
Use RunProgram, if you want to run some program from .7z archive. 
Use ExecuteFile, if you want to open some document from .7z archive or 
if you want to execute some command from Windows.

If you use RunProgram and if you specify empty directory prefix: Directory="", 
the system searches for the executable file in the following sequence:

1. The directory from which the application (installer) loaded. 
2. The temporary folder, where files were extracted. 
3. The Windows system directory. 


Config file Examples
~~~~~~~~~~~~~~~~~~~~

;!@Install@!UTF-8!
Title="7-Zip 4.00"
BeginPrompt="Do you want to install the 7-Zip 4.00?"
RunProgram="setup.exe"
;!@InstallEnd@!



;!@Install@!UTF-8!
Title="7-Zip 4.00"
BeginPrompt="Do you want to install the 7-Zip 4.00?"
ExecuteFile="7zip.msi"
;!@InstallEnd@!



;!@Install@!UTF-8!
Title="7-Zip 4.01 Update"
BeginPrompt="Do you want to install the 7-Zip 4.01 Update?"
ExecuteFile="msiexec.exe"
ExecuteParameters="/i 7zip.msi REINSTALL=ALL REINSTALLMODE=vomus"
;!@InstallEnd@!

