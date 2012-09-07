## TrEd Makefile -- interface to installation, releasing, and testing scripts


# Public Targets -- documented, well known, usable by anyone
all: help

help:
	@cd admin && ./print-make-usage.sh


# UFAL installation: install TrEd and pre-installed extensions
# - updates and uses the source distribution tree
# - implemented as 'almost atomic' operation:
#   (new versions created as %.new, then old versions moved to %.old
#   and %.new renamed to %)
install: prereq update-dist-dir install-tred-extensions
	cd admin && ./install-tred.sh


# make a fresh release of TrEd and upload it to testbed web site
# NOTE: this also includes 'install'
release: check-net release-core release-mac


# Connect to testing platform and execute tests.
# Note: this task can be performed only from UFAL VLAN,
# SSH certificate for pasword-less login of user tred is recommended.
test: check-net
	ssh tred@virtualbox.ufal.hide.ms.mff.cuni.cz ~/test-tred.sh


# Check the status of the TrEd testbed.
testbed-status: check-net
	ssh tred@virtualbox.ufal.hide.ms.mff.cuni.cz ~/check-testbed.sh


# Clear testbed, remove old (previous) testing results from VMs
testbed-clear: check-net
	ssh tred@virtualbox.ufal.hide.ms.mff.cuni.cz ~/clear-testbed.sh


# Copy release from testbed (on virtualbox server) to TrEd oficial site on UFAL web server
# Note: this task can be performed only from UFAL VLAN,
# SSH certificate for pasword-less login of user tred is recommended.
publish: check-net
	ssh tred@virtualbox.ufal.hide.ms.mff.cuni.cz ~/publish-tred.sh





#
# Public targets, but only for experienced users (not described in help)
#

# Check prerequisites (libraries, tools, CPAN modules ...)
prereq:
	cd admin && ./prereq.sh


# Check we are in the UFAL VLAN, so we can access TrEd testing infrastructure
# and Mac OS X development infrastructure
check-net:
	echo "Check that the current computer is in UFAL VLAN ..."
	ping -c 1 virtualbox.ufal.hide.ms.mff.cuni.cz


# Make a fres release of TrEd (except for the Mac OS package)
# the release is uploaded to testbed web site
release-core: prereq update-dist-dir build-dep-package pack-extensions prepare-tred-web-release sync-testbed-www


# Connect to TrEd releasing and testing platform and
# build Mac OS package for TrEd and upload it to testbed web site.
# Note that core release must be performed before mac package release.
release-mac: check-net
	ssh tred@virtualbox.ufal.hide.ms.mff.cuni.cz ~/build-tred-dmg.sh


# Upload local release (made by release-core) to the testbed website.
# This target is automatically invoked by the release-core target. It should
# be re-invoked only if failed, but the release in the local directory is fresh.
sync-testbed-www:
	cd admin && ./sync-testbed-www.sh



#
# Private Targets -- not to be called from outside, except for debugging
#
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


# Update dependency packages, pack them, and move them to the release dir.
build-dep-package: update-dep-packages
	cd admin && ./build-dep-package.sh

# Update dependency packages with CPAN modules and external libraries.
update-dep-packages: update-unix-dep-packages update-win32-dep-packages

# Fetch fresh dependency packages from CPAN and other sources
# (in the unix_install/packages_unix directory)
update-unix-dep-packages:
	cd admin && ./update-unix-dep-packages.sh

update-win32-dep-packages:
	cd admin && ./update-win32-dep-packages.sh




#### Treex::PML section
# not creatig ppm any more... build-treex-pml-ppm removed from chain
new-treex-pml: prereq compile-treex-pml-dist install-treex-pml

compile-treex-pml-dist:
	cd admin && ./compile-treex-pml-dist.sh

build-treex-pml-ppm:
	cd admin && ./build-treex-pml-ppm.sh

install-treex-pml:
	cd admin && ./install-treex-pml.sh

