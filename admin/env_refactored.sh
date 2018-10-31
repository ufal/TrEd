#!/bin/bash

# Root dir of the SVN checkout. All dirs are derived from this one
if [ -z "$SVN_DIR" ]; then
    SVN_DIR=$(dirname $(dirname $(dirname $(readlink -fen $0))))
fi


# Installation prefix -- documentation goes to $INSTALL_BASE/doc,
# binaries go to $INSTALL_BASE/exec,
# libraries go to $INSTALL_BASE/lib,
# extensions to $INSTALL_BASE/share
INSTALL_BASE=${SVN_DIR}/local_install

# Local (source) web tree
WWW=${SVN_DIR}/local_www
export TREDWWW=$WWW

# Remote web tree (of the testbed)
TESTING_SERVER=virtualbox.ufal.hide.ms.mff.cuni.cz
REMOTE_WWW=${TESTING_SERVER}:/var/www/tred/testbed

# Login name used to upload released TrEd to REMOTE_WWW.
# The selected user should log there without password (by certificate)
LOGIN_NAME=tred


# TrEd project direcotry (from which Makefile is executed)
PROJECT_DIR=${SVN_DIR}/trunk

# Log for svn checkouts and exports during make
LOG=$SVN_DIR/trunk/make_log

TRED_HOME_URL="http://ufallab.ms.mff.cuni.cz:24080/tred/testbed"
TRED_EXTENSIONS_URL=""

#########################################################
##### Do not change variables below this comment ########
##### (unless you know what you are doing) ##############
#########################################################
# SHELL=/bin/bash
TMP=/tmp

# if the desired perl version changes, it should also be changed in
# win32_strawberry/tred-installer-common-1.nsi (search for
# $DesiredPerlVersion variable)
## DESIRED_PERL_VERSION='5.16'
## DESIRED_PERL_URL="http://strawberryperl.com/download/5.16.3.1/strawberry-perl-5.16.3.1-32bit.msi"
DESIRED_PERL_VERSION='5.24'
DESIRED_PERL_URL="http://strawberryperl.com/download/5.24.0.1/strawberry-perl-5.24.0.1-32bit.msi"

# UFAL installation paths
## INSTALL_BASE=/f/common
INSTALL_BIN=${INSTALL_BASE}/exec
INSTALL_LIB=${INSTALL_BASE}/lib
INSTALL_SHARE=${INSTALL_BASE}/share
INSTALL_DOC=${INSTALL_BASE}/doc

# WEB page {source tree and rsynced target at web server}
## WWW=/net/su/h/pajas/WWW
## REMOTE_WWW=ufal.mff.cuni.cz:/home/pajas/WWW
RSS=${WWW}/tred/changelog.rss

# Basic paths
TRED_SVN=https://svn.ms.mff.cuni.cz/svn/TrEd
TRED_SVN_REPO=${TRED_SVN}/trunk/tred_refactored
TRED_SVN_EXT=${TRED_SVN}/extensions
TREEX_PML_REPO=https://svn.ms.mff.cuni.cz/svn/perl_libs/trunk/distribution/Treex-PML
WIN32_DIST_REPO=https://svn.ms.mff.cuni.cz/svn/perl_libs/trunk/distribution/win32_build_script

# PROJECT_DIR=/net/work/projects/tred
ADMIN_DIR=${PROJECT_DIR}/admin
DIST_DIR=${PROJECT_DIR}/dist
TRED_SRC_DIR=${PROJECT_DIR}/tred
TRED_EXT_DIR=${PROJECT_DIR}/extensions
TRED_DIST_DIR=${DIST_DIR}/tred

TREEX_PML_DIR=${PROJECT_DIR}/Treex-PML

TRED_UNIXINST_DIR=${PROJECT_DIR}/unix_install
TRED_WININST_DIR=${PROJECT_DIR}/REMOVE-win32_install
TRED_PPM_DIR=${PROJECT_DIR}/REMOVE-win32_ppm

TRED_STRAWBERRYPERL_DIR=${PROJECT_DIR}/win32_strawberry
TRED_DPAN_DIR=${PROJECT_DIR}/dpan

TREEX_PML_EXPORT=${PROJECT_DIR}/generated/Treex-PML

# mutli-script to run jobs on the SGE cluster
LRC_CMD=${ADMIN_DIR}/run_on_lrc

# SVN to ChangeLog conversion
SVN_TO_CHANGELOG=${ADMIN_DIR}/svn2cl/svn2cl.sh
# ChangeLog to RSS conversion
CHANGELOG_TO_RSS=${ADMIN_DIR}/changelog2rss.pl

## tu treba doriesit xsh2... (na ufale je symlink na init script + xsh)

## PATH_BEFORE=$PATH
## PATH="${ADMIN_DIR}:${PATH_BEFORE}"


## MAC OS settings
MAC_RELEASER=kopp@manfred.ms.mff.cuni.cz
MAC_TRED_INSTALLATION='~/tred_installation'
MAC_TRED_INSTALLATION_OLD='~/tred_installation_old'
MAC_SVN_DIR='~/TrEd'