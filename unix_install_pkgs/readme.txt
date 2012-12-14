The unix install packages provide a way to install TrEd via standard packaging
mechanisms embedded in most Linux distributions. The generic idea of each package
is to:
- Install TrEd files into /opt/tred
- Symlink the start scripts from /opt/tred/bin to /usr/bin
- Install all possible dependencies (perl, CPAN modules, ...) via packaging
  systems
- Install remaining dependencies (CPAN modules, which are not provided as
  packages) using cpanminus script. The cpanm was choosed over the alternatives
  as it requires no configuration and it has '--no-interactive' switch. The
  cpanminus package existence is ensured by package dependencies.


DEB Packages
------------
Packages for Debian and Ubuntu are created by debuild tool. The configuration
files for debuild are in tred-2.0\debian. The most important files are:
- ./control -- the configuration for the package (name, description, ...).
  The package dependencies are also listed in this file.
- ./rules -- Make file fragment used for package compilation. Since the TrEd
  compilation is quite specific, the whole process is performed in the install
  step (override_dh_auto_install).
- ./postinst script is invoked after successful installation of the package.
  It installs CPAN modules that are not distributed as .deb packages. The script
  uses ugly hack. It provides the CPAN installer with text input to feed
  interactive configuration script (in case the CPAN has not been configured yet).

The building process is wrapped by prepare_deb_pkg.sh script. The script creates
a copy of configuration files, patch them, and invoke the debuild. The patching
updates the TrEd version number and release date in the config files. The .deb
package is created in the same directory where the .sh script is.

The package has been tested on Ubuntu (12.10) and Debian (Wheezy 7). It does not
work on current stable Debian (Squeezy 6), since several dependencies are
missing there:

libperl-ostype-perl
libmodule-metadata-perl
libjson-pp-perl
libcpan-meta-yaml-perl
libxml-sax-base-perl
libperlio-gzip-perl 

The Debian is not often used by common users and experienced users can install
those dependencies manually or they are already using testing (Wheezy) version.
Hence, it was decided that this problem needs not to be solved.



RPM Packages
------------
The packages for Red Hat based systems are created by rpmbuild tool. This tool
is ported to Ubuntu as well, so we can easily create both type of packages on
our TrEd-testbed-master (which is running Ubuntu). All configuration (for one
distribution) is in a single file. The file contains basic package info (like
name or description), list of dependencies, and scriptlets used for building
the package as well as scriptlets executed after the installation.

We use different configuration files for different Linux distributions since
their RPM repositories differs significantly. Usually, the configuration files
differs only in the list of dependencies and in the post-installation script
that has to install remaining CPAN modules.

The package compilation is done in three steps (by three scriptlets):
%prep - preparation, downloads install_tred.bash script from testbed web page
%build - performs the installation without libraries into a temporary dir
%install - moves the TrEd files into proper location and prepares symlinks of
	start scripts for /usr/bin dir.
 
Note that all files being installed by the package are listed (as wildcards) in
%files section. The %post section holds the post-install scriptlet that install
the CPAN modules.

RHEL installation required two specific workarounds in the %post scriptlet:
- A symlink /usr/lib64/libgdbm.so.2 that points to /usr/lib64/libgdbm.so has
  to be created (problems with naming conventions).
- The cpanminus module is missing on RHEL, so we use online installation script.
  It works as follows: 'wget -O - http://cpanmin.us | perl - --no-interactive
  <module-names> ...'.
  The wget downloads cpanminus script from it webpage a pass it on to perl.
  Perl then executes the script to install the modules.
Furthermore, RHEL rpm package has some dependencies in the Extra Package for
Enterprise Linux repository (http://fedoraproject.org/wiki/EPEL).

The release process is controlled by the prepare_rpm_pkg.sh script. It scans for
available specification files and create a rpm package for each file. It creates
a rpmbuild directory structure required for the package building process and 
copies the specification file at proper location. The specification is patched
(TrEd version is updated) before rpmbuild is invoked.



Integration with release process
--------------------------------
The package releasing is wrapped by release-deb.sh and release-rpm.sh scripts in
the admin directory. Each script invokes corresponding release_xxx_pkg.sh script
and then uploads created package(s) to the testbed web. Package files have TrEd
version in their name, so a symlink with generic name is created to point at the
newest package released (in the testbed web storage).

Both scripts are aliased by make targets in the main TrEd makefile. These
targets are part of the main 'release' target.
 