#!/bin/bash
set -euo pipefail

vers_maj_min_rel=$(head -n1 debian/changelog | awk '{print $2}' | tr -d '()')
vers_maj_min=$(echo $vers_maj_min_rel | cut -d- -f1)
tmpdir=$(mktemp -d --tmpdir 'mle.XXXXXXXXXX')
srcdir="$tmpdir/mle-$vers_maj_min"
mkdir $srcdir
cp -aT $(pwd) $srcdir
pushd $srcdir
git clean -fdx
git submodule foreach 'rm -rf *'
find . -name '.git*' | xargs rm -rf
dh_make -s -y -c apache --createorig || true
debuild -i -us -uc -sa -S
debsign ../mle*.dsc
sudo pbuilder --build ../mle*.dsc
popd
debsign --re-sign *.changes
lintian -i -I --show-overrides *.changes

set -x
ls -l $tmpdir
