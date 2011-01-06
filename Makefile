## TrEd Makefile

SHELL=/bin/bash

##TODO netreba nejak tak, aby sa make mohlo spustit aj z ineho adresara...?
include admin/env.sh


all: help

help:
	@echo "Please, set proper paths in admin/env.sh before running make."
	@echo 
	@echo "You can:"
	@echo 
	@echo "  make install-tred        - install TrEd and extensions into $(INSTALL_BASE)"
	@echo "  make release-tred        - install-tred + build distribution packages and upload to remote server ($(REMOTE_WWW))"
	@echo 
	@echo "  make release-tred-qcmd   - like release-tred but uses non-interactive SGE jobs rather than qrsh"
	@echo "  make update-dist-dir     - only update TrEd distribution tree in $(DIST_DIR)"
	@echo "  make update-dep-packages - fetch latest versions of required modules and libraries"
	@echo "  make release-dep-package - only release tred dependency package to remote server ($(REMOTE_WWW))"
	@echo "  make new-treex-pml       - create and install new Treex::PML packages"
	@echo 
	@echo "  make sync-www            - rsync WWW source tree to remote server ($(REMOTE_WWW))"
	

prereq:
	cd admin && ./prereq.sh

sync-www:
	cd admin && ./sync-www.sh

# make a fresh release of TrEd
# NOTE: this also includes 'install-tred'
release-tred:
	cd admin && ./release-tred.sh
# 	cd admin && ./test-release-tred.sh #not yet implemenTrEd

# Same as release-tred, but uses qcmd+qtop instead of interactive qrsh
release-tred-qcmd:
	cd admin && ./release-tred-qcmd.sh

# Same as 'release-tred' but without 'install-tred'
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
update-dist-dir: $(TRED_SRC_DIR) $(TRED_SRC_DIR)/tred make-changelog
	cd admin && ./update-dist-dir.sh

# UFAL installation: update pre-installed extensions pdt20 and pdt_vallex
install-tred-extensions:
	cd admin && ./install-tred-extensions.sh

# UFAL installation: install TrEd and pre-installed extensions
# - updates and uses the source distribution tree
# - implemented as 'almost atomic' operation:
#   (new versions created as %.new, then old versions moved to %.old
#   and %.new renamed to %)
install-tred: prereq update-dist-dir install-tred-extensions
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
prepare-tred-web-release:
	cd admin && ./prepare-tred-web-release.sh

update-dep-packages: update-unix-dep-packages update-win32-dep-packages

# Fetch fresh dependency packages from CPAN and other sources
# (in the unix_install/packages_unix directory)
update-unix-dep-packages:
	cd admin && ./update-unix-dep-packages.sh

update-win32-dep-packages:
	cd admin && ./update-win32-dep-packages.sh

# Try to compile the dependencies (testing)
test-dep-packages:
	cd admin && ./test-dep-packages.sh

#
# Targets that need to run on the SGE cluster are implemented as 
# SGE jobs which usually just call
#   make 'job-TARGET'
# on the allocated cluster node. (where TARGET is the original name of the target).
#
job-tred-release: install-tred new-treex-pml build-dep-package pack-extensions prepare-tred-web-release

#hm, this is kindof weird (look also at next target)
job-tred-pkg-release:
	

job-tred-pkg-no-release: build-dep-package prepare-tred-web-release

# netreba tu pridat dalsie ciele, aby to ozaj bolo len bez instalacie...?
job-tred-release-no-install: update-dist-dir build-dep-package prepare-tred-web-release

job-test-packages:
	cd admin && ./job-test-packages.sh

#### Treex::PML section
new-treex-pml: prereq compile-treex-pml-dist build-treex-pml-ppm install-treex-pml

compile-treex-pml-dist:
	cd admin && ./compile-treex-pml-dist.sh

build-treex-pml-ppm:
	cd admin && ./build-treex-pml-ppm.sh

install-treex-pml:
	cd admin && ./install-treex-pml.sh
