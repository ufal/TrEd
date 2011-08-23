1.) Create a playground, let's say C:\tred_portable

2.) Download Strawberry Perl portable (the same version has to be installed on Windows system)

3.) Download tred-installer.exe

4.) Extract Perl portable into C:\tred_portable\perl_portable dir

5.) Install TrEd to some directory, lets say c:\tred_portable\tred_portable

6.) Update bat files (we have to update PATH, PERL5LIB, TERM and TRED_DIR env variables), inspire by already existing ones

7.) Remove Uninstall.exe

8.) Try TrEd in portable mode (change path to installed perl or sth), fix if sth does not work

9.) Delete C:\tred_portable\perl_portable\cpan\build\

10.) Pack & commit