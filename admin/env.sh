#!/bin/bash

# Installation prefix -- documentation goes to $INSTALL_BASE/doc, 
# binaries go to $INSTALL_BASE/exec, 
# libraries go to $INSTALL_BASE/lib,
# extensions to $INSTALL_BASE/share
INSTALL_BASE=~/ufal_work/ms.mff.cuni.cz/f_common

# Local (source) web tree
WWW=~/ufal_work/ms.mff.cuni.cz/pajas_WWW
# Remote web tree
REMOTE_WWW="" # ufal.mff.cuni.cz:/home/pajas/WWW

# TrEd project direcotry (from which Makefile is executed)
PROJECT_DIR=~/ufal_work/ms.mff.cuni.cz/net_work_projects_tred

# Log for svn checkouts and exports during make
LOG=~/ufal_work/ms.mff.cuni.cz/net_work_projects_tred/make_log

#########################################################
##### Do not change variables below this comment ########
##### (unless you know what you are doing) ##############
#########################################################
# SHELL=/bin/bash
TMP=/tmp


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
TRED_SVN_REPO=${TRED_SVN}/trunk
TRED_SVN_EXT=${TRED_SVN}/extensions
TREEX_PML_REPO=https://svn.ms.mff.cuni.cz/svn/perl_libs/distribution/Treex-PML
WIN32_DIST_REPO=https://svn.ms.mff.cuni.cz/svn/perl_libs/distribution/win32_build_script

# PROJECT_DIR=/net/work/projects/tred
ADMIN_DIR=${PROJECT_DIR}/admin
DIST_DIR=${PROJECT_DIR}/dist
TRED_SRC_DIR=${PROJECT_DIR}/tred
TRED_EXT_DIR=${PROJECT_DIR}/extensions
TRED_DIST_DIR=${DIST_DIR}/tred

TREEX_PML_DIR=${PROJECT_DIR}/Treex-PML

TRED_UNIXINST_DIR=${PROJECT_DIR}/unix_install
TRED_WININST_DIR=${PROJECT_DIR}/win32_install
TRED_PPM_DIR=${PROJECT_DIR}/win32_ppm

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

