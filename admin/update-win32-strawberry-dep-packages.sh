#!/bin/bash
# Downloads cpan packages and prepares dpan repository

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating win32-strawberry dependency packages" && \

echo "Updating DPAN repository" && \
cd $TRED_DPAN_DIR && ./update_dpan.pl && \

echo "Applying patches" && \
cd "$TRED_DPAN_DIR/patches" && \
for SCRIPT in *.sh; do
	if [ -f $SCRIPT -a -x $SCRIPT ]; then
		./$SCRIPT
	fi
done && \

echo "Generating new index (takes a couple of minutes)" && \
cd $TRED_DPAN_DIR/dpan && \
dpan -f config && \


echo "Updating win32 dependency packages done."
