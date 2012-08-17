## TrEd Makefile

SHELL=/bin/bash

##TODO netreba nejak tak, aby sa make mohlo spustit aj z ineho adresara...?
#$(shell cd admin && ./env.sh && cd ..)
#include admin/env.sh


all: help

help:
	cd admin && ./print-make-usage.sh

prereq:
	cd admin && ./prereq.sh

sync-www:
	cd admin && ./sync-www.sh

# make a fresh release of TrEd
# NOTE: this also includes 'install'
release:
	cd admin && ./release-tred.sh

# Same as release, but uses qcmd+qtop instead of interactive qrsh
release-tred-qcmd:
	cd admin && ./release-tred-qcmd.sh

# Same as 'release' but without 'install'
release-tred-no-install:
	cd admin && ./release-tred-no-install.sh

# Auxiliary: Build extensions, TrEd distributions and rsync the updated WWW tree to the web server
tred-web-release: pack-extensions prepare-tred-web-release sync-www

# Update changelog in the working copy
make-changelog:
	cd admin && ./make-changelog.sh

# Update distribution tree:
# The update is implemented as "atomic" operation to avoid problems when
# applications are using the distribution tree.
# - fresh SVN export
# - updated ChangeLog
# - TrEd version number (based on SVN revision)
# - compile the documentation from DocBook and POD (tred/devel/make_manual)
# - updated extensions dir (SVN working copy)
update-dist-dir: make-changelog
	cd admin && ./update-dist-dir.sh

# UFAL installation: update pre-installed extensions pdt20 and pdt_vallex
install-tred-extensions:
	cd admin && ./install-tred-extensions.sh

# UFAL installation: install TrEd and pre-installed extensions
# - updates and uses the source distribution tree
# - implemented as 'almost atomic' operation:
#   (new versions created as %.new, then old versions moved to %.old
#   and %.new renamed to %)
install: prereq update-dist-dir install-tred-extensions
	cd admin && ./install-tred.sh

# Copy updated dependency package and installation script to the WWW tree
build-dep-package: update-dep-packages
	cd admin && ./build-dep-package.sh

# as above, plus rsync to the web server
release-dep-package: build-dep-package 
	make sync-www

# Build latest versions of TrEd extension packages from the (working copy!)
# of the extension repository and copy them to the source WWW tree.
pack-extensions:
	cd admin && ./pack-extensions.sh

# Auxiliary:
# Create TrEd distribution packages, update the documentation and Changelog 
# in the source WWW tree from the source distribution tree 
# The package sizes on the main page are computed by the admin/create_tred_packages.sh script
# update-dist-dir and build-dep-package should be run before prepare-tred-web-release
prepare-tred-web-release:
	cd admin && ./prepare-tred-web-release.sh

update-dep-packages: prereq update-unix-dep-packages update-win32-strawberry-dep-packages
# no longer need to do this, only for active perl...
# update-win32-dep-packages

# Fetch fresh dependency packages from CPAN and other sources
# (in the unix_install/packages_unix directory)
update-unix-dep-packages:
	cd admin && ./update-unix-dep-packages.sh

update-win32-dep-packages:
	cd admin && ./update-win32-dep-packages.sh

update-win32-strawberry-dep-packages:
	cd admin && ./update-win32-strawberry-dep-packages.sh


# Try to compile the dependencies (testing)
test-dep-packages:
	cd admin && ./test-dep-packages.sh

#
# Targets that need to run on the SGE cluster are implemented as 
# SGE jobs which usually just call
#   make 'job-TARGET'
# on the allocated cluster node. (where TARGET is the original name of the target).
#
job-tred-release: install new-treex-pml build-dep-package pack-extensions prepare-tred-web-release

#hm, this is kindof weird (look also at next target)
job-tred-pkg-release:
	
# Don't forget prepare-tred-web-release prerequisities...
job-tred-pkg-no-release: update-dist-dir build-dep-package prepare-tred-web-release

# netreba tu pridat dalsie ciele, aby to ozaj bolo len bez instalacie...?
job-tred-release-no-install: update-dist-dir build-dep-package prepare-tred-web-release

job-test-packages:
	cd admin && ./job-test-packages.sh

#### Treex::PML section
# not creatig ppm any more... build-treex-pml-ppm removed from chain
new-treex-pml: prereq compile-treex-pml-dist install-treex-pml

compile-treex-pml-dist:
	cd admin && ./compile-treex-pml-dist.sh

build-treex-pml-ppm:
	cd admin && ./build-treex-pml-ppm.sh

install-treex-pml:
	cd admin && ./install-treex-pml.sh


# Testing and publishing operations
test:
	echo "NOT IMPLEMENTED YET!"

publish:
	echo "NOT IMPLEMENTED YET!"

