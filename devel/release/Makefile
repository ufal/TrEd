SHELL=/bin/bash
TMP=/tmp

# UFAL installation paths
INSTALL_BASE=/f/common
INSTALL_BIN=$(INSTALL_BASE)/exec
INSTALL_LIB=$(INSTALL_BASE)/lib
INSTALL_SHARE=$(INSTALL_BASE)/share
INSTALL_DOC=$(INSTALL_BASE)/doc

# WEB page (source tree and rsynced target at web server)
WWW=/net/su/h/pajas/WWW
REMOTE_WWW=ufal.mff.cuni.cz:/home/pajas/WWW
RSS=$(WWW)/tred/changelog.rss

# Basic paths
TRED_SVN=https://svn.ms.mff.cuni.cz/svn/TrEd
TRED_SVN_REPO=$(TRED_SVN)/trunk
TRED_SVN_EXT=$(TRED_SVN)/extensions
PROJECT_DIR=/net/work/projects/tred
ADMIN_DIR=$(PROJECT_DIR)/admin
DIST_DIR=$(PROJECT_DIR)/dist
TRED_SRC_DIR=$(PROJECT_DIR)/tred
TRED_EXT_DIR=$(PROJECT_DIR)/extensions
TRED_DIST_DIR=$(DIST_DIR)/tred

TRED_UNIXINST_DIR=$(PROJECT_DIR)/unix_install
TRED_WININST_DIR=$(PROJECT_DIR)/win32_install

TREEX_PML_EXPORT=$(PROJECT_DIR)/generated/Treex-PML

# mutli-script to run jobs on the SGE cluster
LRC_CMD=$(ADMIN_DIR)/run_on_lrc

# SVN to ChangeLog conversion 
SVN_TO_CHANGELOG=$(ADMIN_DIR)/svn2cl
# ChangeLog to RSS conversion
CHANGELOG_TO_RSS=$(ADMIN_DIR)/changelog2rss.pl

all: help

help:
	@echo "You can:"
	@echo
	@echo "  make install-tred        - install TrEd and extensions into $(INSTALL_BASE)"
	@echo "  make release-tred        - install-tred + build distribution packages and upload to $(REMOTE_WWW)"
	@echo
	@echo "  make tred-release-qcmd   - like release-tred but uses non-interactive SGE jobs rather than qrsh"
	@echo "  make update-dist-dir     - only update TrEd distribution tree in $(DIST_DIR)"
	@echo "  make update-dep-packages - fetch latest versions of required modules and libraries"
	@echo "  make release-dep-package - only release tred dependency package on $(REMOTE_WWW)"
	@echo "  make new-treex-pml       - create and install new Treex::PML packages"
	@echo
	@echo "  make sync-www            - rsync WWW source tree to ufal.mff.cuni.cz/~pajas/WWW"
	@echo

sync-www:
	echo -n "Press RETURN to start WWW server upload..."; read enter
	rsync -aHlzv --chmod=Dug+rwx,o+r,Fug+rwX,o+rX  $(WWW)/ $(REMOTE_WWW)/

# install TrEd on UFAL network
tred-install: install-tred

# make a fresh release of TrEd
tred-release: release-tred

# Update distribution tree:
# The update is implemented as "atomic" operation to avoid problems when
# applications are using the distribution tree.
# - fresh SVN export
# - updated ChangeLog
# - TrEd version number (based on SVN revision)
# - compile the documentation from DocBook and POD (tred/devel/make_manual)
# - updated extensions dir (SVN working copy)

update-dist-dir: $(TRED_SRC_DIR) $(TRED_SRC_DIR)/tred make-changelog
	test '!' -e $(TRED_DIST_DIR).new
	svn export $(TRED_SVN_REPO) $(TRED_DIST_DIR).new
	$(TRED_DIST_DIR).new/devel/update_version.pl $(TRED_SVN_REPO)
	$(TRED_EXT_DIR)/update
	cp $(TRED_SRC_DIR)/ChangeLog $(TRED_DIST_DIR).new/
	cd $(TRED_DIST_DIR).new && devel/make_manual
	chmod -R g+rwX $(TRED_DIST_DIR).new
	chmod a-w $(TRED_DIST_DIR).new/tredlib/tredrc
	if [ -e $(TRED_DIST_DIR) ]; then mv $(TRED_DIST_DIR) $(TRED_DIST_DIR).old; fi
	mv $(TRED_DIST_DIR).new $(TRED_DIST_DIR)
	if [ -e $(TRED_DIST_DIR).old ]; then chmod u+w -R $(TRED_DIST_DIR).old; rm -rf $(TRED_DIST_DIR).old; fi

# Update changelog in the working copy
make-changelog:
	@echo generating changelog
	svn update $(TRED_SRC_DIR)
	cd $(TRED_SRC_DIR) && $(SVN_TO_CHANGELOG) --include-rev -o ChangeLog

# UFAL installation: update pre-installed extensions pdt20 and pdt_vallex
install-tred-extensions:
	(cd $(TRED_EXT_DIR); ./make pdt20; ./make pdt_vallex)
	test ! -d $(INSTALL_SHARE)/tred-extensions.new/ || rm -rf $(INSTALL_SHARE)/tred-extensions.new
	mkdir $(INSTALL_SHARE)/tred-extensions.new/
	svn export $(TRED_SVN_EXT)/pdt20 $(INSTALL_SHARE)/tred-extensions.new/pdt20
	svn export $(TRED_SVN_EXT)/pdt_vallex $(INSTALL_SHARE)/tred-extensions.new/pdt_vallex
	chmod -R g+rwX $(INSTALL_SHARE)/tred-extensions.new/
	(echo pdt20; echo pdt_vallex) > $(INSTALL_SHARE)/tred-extensions.new/extensions.lst
	test ! -d $(INSTALL_SHARE)/tred-extensions.old/ || rm -rf $(INSTALL_SHARE)/tred-extensions.old
	test ! -d $(INSTALL_SHARE)/tred-extensions/ || mv $(INSTALL_SHARE)/tred-extensions $(INSTALL_SHARE)/tred-extensions.old
	mv $(INSTALL_SHARE)/tred-extensions.new $(INSTALL_SHARE)/tred-extensions
	test ! -d $(INSTALL_SHARE)/tred-extensions.old/ || rm -rf $(INSTALL_SHARE)/tred-extensions.old

# UFAL installation: install TrEd and pre-installed extensions
# - updates and uses the source distribution tree
# - implemented as 'almost atomic' operation:
#   (new versions created as %.new, then old versions moved to %.old
#   and %.new renamed to %)
#
install-tred: update-dist-dir install-tred-extensions
	for d in $(INSTALL_LIB) $(INSTALL_DOC) $(INSTALL_SHARE); do \
	  test ! -d $$d/tred.new/ || rm -rf $$d/tred.new; \
	  test ! -d $$d/tred.old/ || rm -rf $$d/tred.old; \
	  mkdir $$d/tred.new; \
	done
	cp -R $(TRED_DIST_DIR)/tredlib/* $(INSTALL_LIB)/tred.new/
	chmod -R g+rwX $(INSTALL_LIB)/tred.new/
	chmod a-w $(INSTALL_LIB)/tred.new/tredrc
	cp -R $(TRED_DIST_DIR)/documentation/* $(INSTALL_DOC)/tred.new/
	cp -R $(TRED_DIST_DIR)/examples $(INSTALL_DOC)/tred.new/
	cp -R $(TRED_DIST_DIR)/ChangeLog $(TRED_DIST_DIR)/README $(INSTALL_DOC)/tred.new/
	chmod -R g+rwX $(INSTALL_DOC)/tred.new/
	(cd $(INSTALL_DOC)/tred.new/ && (rm -rf `find . | grep '/CVS/'`;rm -rf `find . | grep '/\.svn/'`));
	find $(INSTALL_LIB)/tred.new $(INSTALL_DOC)/tred.new '(' -name '*~' -or -name '*#*' ')' -exec rm -f '{}' ';'
	cp $(TRED_DIST_DIR)/resources/* $(INSTALL_SHARE)/tred.new/
	chmod -R g+rwX $(INSTALL_SHARE)/tred.new/
	cp $(TRED_DIST_DIR)/tred $(TRED_DIST_DIR)/btred $(TRED_DIST_DIR)/ntred $(TRED_DIST_DIR)/jtred $(TRED_DIST_DIR)/any2any $(TRED_DIST_DIR)/examples/fsdiff.pl $(INSTALL_BIN)
	for d in $(INSTALL_LIB) $(INSTALL_DOC) $(INSTALL_SHARE); do \
	  test ! -d $$d/tred/ || mv $$d/tred $$d/tred.old; \
	  mv $$d/tred.new $$d/tred; \
	done
	for d in $(INSTALL_LIB) $(INSTALL_DOC) $(INSTALL_SHARE); do \
	  test ! -d $$d/tred.old/ || rm -rf $$d/tred.old; \
	done


# Build the installation on SGE cluster and rsync the updated WWW tree to the web-server
# NOTE: this also includes 'install-tred'
# 
release-tred: 
	$(LRC_CMD) qrsh -cwd $(LRC_CMD) --command make job-tred-release
	make sync-www

# Same as release-tred, but uses qcmd+qtop instead of interactive qrsh
tred-release-qcmd: 
	$(LRC_CMD) $(ADMIN_DIR)/qcmd $(LRC_CMD) --command make job-tred-release
	$(LRC_CMD) $(ADMIN_DIR)/qtop
	less make.[eo]*
	make sync-www
	rm make.[eo]*

# Same as 'release-tred' but without 'install-tred'
tred-release-no-install: 
	$(LRC_CMD) qrsh -cwd $(LRC_CMD) --command make job-tred-release-no-install

# Build latest versions of TrEd extension packages from the (working copy!)
# of the extension repository and copy them to the source WWW tree.
pack-extensions:
	cd $(TRED_EXT_DIR) && ./make

# Auxiliary: Build extensions, TrEd distributions and rsync the updated WWW tree to the web server
tred-web-release: pack-extensions tred-web-release-prepare sync-www

# Auxiliary:
# Create TrEd distribution packages, update the documentation and Changelog 
# in the source WWW tree from the source distribution tree 
# The package sizes on the main page are computed by the admin/create_tred_packages.sh script
#
tred-web-release-prepare: 
	rm -f $(WWW)/tred/ar01*.html $(WWW)/tred/ar01*.html
	cp -Rf $(TRED_DIST_DIR)/documentation/{*.html,*.css,pics} $(WWW)/tred/;
	$(ADMIN_DIR)/xsh2 -P $(WWW)/tred/index.html 'nobackups; rm //*[@class="offline"]; map :i { s{^http://ufal.mff.cuni.cz/~pajas/tred/}{./} } //@href;'
	$(ADMIN_DIR)/create_tred_packages.sh $(DIST_DIR) $(TRED_WININST_DIR) $(WWW)/tred
	echo ${HOSTNAME}
	$(CHANGELOG_TO_RSS) $(TRED_DIST_DIR)/ChangeLog > $(RSS)

update-dep-packages: update-unix-dep-packages update-win32-dep-packages


#
# Fetch fresh dependency packages from CPAN and other sources
# (in the unix_install/packages_unix directory)
#
update-unix-dep-packages:
	@echo "Updating working copy of $(TRED_SVN_REPO)/devel/unix_install unix_install"
	rm -rf unix_install/packages_unix/packages
	svn up unix_install
	svn status unix_install
	cd unix_install/packages_unix && PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b -C

update-win32-dep-packages:
	@echo "Updating PPM packages in win32_ppm"
	cd win32_ppm && ./get_packages_tred_58.sh
	cd win32_ppm && ./get_packages_tred_510.sh

# Try to compile the dependencies (testing)
test-dep-packages:
	$(LRC_CMD) qrsh -cwd $(LRC_CMD) --command make job-test-packages

# Copy updated dependency package and installation script to the WWW tree
build-dep-package:
	tar czhf "$(WWW)/tred/tred-dep-unix.tar.gz" --exclude=.svn --exclude='*~' -C $(TRED_UNIXINST_DIR) packages_unix
	svn cat $(TRED_SVN_REPO)/devel/unix_install/install_tred.bash > $(WWW)/tred/install_tred.bash

# as above, plus rsync to the web server
release-dep-package:	build-dep-package
	make sync-www

#
# Targets that need to run on the SGE cluster are implemented as 
# SGE jobs which usually just call
#   make 'job-TARGET'
# on the allocated cluster node. (where TARGET is the original name of the target).
#
job-test-packages:
	rm -rf test_build
	mkdir test_build
	p=$$PWD; cd unix_install/packages_unix && env NO_PREREQ=1 PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b --prefix $$p/test_build

job-tred-release-no-install: update-dist-dir build-dep-package tred-web-release-prepare

job-tred-pkg-release:
	$(LRC_CMD) qrsh -cwd $(LRC_CMD) --command make job-tred-pkg-no-release

job-tred-pkg-no-release: build-dep-package tred-web-release-prepare

job-tred-release: tred-install new-treex-pml build-dep-package pack-extensions tred-web-release-prepare

new-treex-pml: compile-treex-pml-dist build-treex-pml-ppm install-treex-pml

compile-treex-pml-dist:
	@echo "*** Updating from SVN"
	cd Treex-PML && !( svn status | grep -q '^[MAC]')
	@echo "*** Exporting from SVN to" $(TREEX_PML_EXPORT)
	rm -rf $(TREEX_PML_EXPORT)
	svn export https://svn.ms.mff.cuni.cz/svn/perl_libs/distribution/Treex-PML $(TREEX_PML_EXPORT)
	cd $(TREEX_PML_EXPORT) && \
	echo "*** Updating Version info in all modules" && \
	perl ./Build.PL && ./Build version && \
	echo "*** Building" && \
	perl ./Build.PL && ./Build && ./Build test && \
	echo "*** Packaging CPAN distribution" && \
	./Build dist && ./Build disttest && \
	echo "*** Copying CPAN distribution to" $(TRED_UNIXINST_DIR)/packages_unix/packages && \
	(rm -f $(TRED_UNIXINST_DIR)/packages_unix/packages/Treex-PML-*.tar.gz || true) && \
	cp Treex-PML-*.tar.gz $(TRED_UNIXINST_DIR)/packages_unix/packages
	chmod -R gu+rwX $(TRED_UNIXINST_DIR)/packages_unix/packages || true
	chmod -R gu+rwX $(TREEX_PML_EXPORT)


build-treex-pml-ppm:
	@echo "*** Packaging PPM distribution" && \
	cd $(TREEX_PML_EXPORT) && \
	rm -rf Treex-PML-*/ && \
	tar xzf Treex-PML-*.tar.gz && \
	cd Treex-PML-*/ && \
	NO_COLONS_IN_FILENAMES=1 perl ./Build.PL && ./Build && ./Build ppd --codebase Treex-PML.tar.gz && \
	perl -I$(PROJECT_DIR)/win32_ppm/win32_build_script -MBuildUtils -e 'update_ppd(shift)' Treex-PML && \
	pwd && ls && \
	tar czf Treex-PML.tar.gz blib/ && \
	echo "*** Copying PPM distribution to ppm repositories $(WWW)/{ppms,ppms510}" && \
	cat Treex-PML.ppd | sed 's/5\.8/5.10/' > Treex-PML.ppd.5.10 && \
	cp Treex-PML.tar.gz Treex-PML.ppd $(WWW)/ppms && \
	cp Treex-PML.tar.gz $(WWW)/ppms510 && \
	cp Treex-PML.ppd.5.10 $(WWW)/ppms510/Treex-PML.ppd && \
	(rm -f $(TRED_WININST_DIR)/packages58_win32/Treex-PML*; rm -f $(TRED_WININST_DIR)/packages510_win32/Treex-PML* || true) && \
	cp Treex-PML.tar.gz Treex-PML.ppd $(TRED_WININST_DIR)/packages58_win32/ && \
	cp Treex-PML.tar.gz $(TRED_WININST_DIR)/packages510_win32/ && \
	cp Treex-PML.ppd.5.10 $(TRED_WININST_DIR)/packages510_win32/Treex-PML.ppd && \
	(cd $(PROJECT_DIR)/win32_ppm/58; ../make_repo_package_list) && \
	(cd $(PROJECT_DIR)/win32_ppm/510; ../make_repo_package_list) && \
	cd $(WWW)/ppms && ./make_repo_package_list
	cd $(WWW)/ppms510 && ./make_repo_package_list
	chmod -R gu+rwX $(WWW)/ppms* $(TRED_WININST_DIR)/packages58_win32/ $(TRED_WININST_DIR)/packages510_win32/ || true
	@echo "*** Please:" && \
	echo "***   - run 'make sync-www' to rsync PPM repositories to" $(REMOTE_WWW) && \
	echo "***   - upload " Treex-PML/Treex-PML-*/Treex-PML-*.tar.gz " to CPAN (if needed)"

install-treex-pml:
	@echo "*** Unpacking CPAN distribution " && \
	cd $(TREEX_PML_EXPORT) && \
	rm -rf Treex-PML-*/ && \
	tar xzf Treex-PML-*.tar.gz && \
	echo "*** Building from clean CPAN distribution " && \
	cd Treex-PML-*/ && \
	. /net/work/projects/perl_repo/admin/bin/setup_platform && \
	perl ./Build.PL $$(/net/work/projects/perl_repo/admin/bin/perl_build_opts) && \
	./Build && ./Build test && \
	echo "*** Installing" && \
	./Build install &&  \
	echo "*** Fixing permissions" && \
	find $$PERLNETREPO -user $$USER -not -perm -g+w -print -exec chmod g+rwX '{}' '+' && \
	echo "*** Installed on architecture" $$(arch) " - don't forget to run 'make install-trex-pml' the other one as well!"

