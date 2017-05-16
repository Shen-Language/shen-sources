#!/bin/bash

TAG="${2:-HEAD}"
VERSION="${1:-$TAG}"
NAME="ShenOSKernel-${VERSION}"

git archive --format=tar --prefix="$NAME/" $TAG | (cd _dist && tar xf -)
cp -R klambda/ "_dist/${NAME}/klambda"
rm -f "_dist/${NAME}/".git*
rm "_dist/${NAME}/dist.sh"

pushd _dist

tar cvzf "${NAME}.tar.gz" "${NAME}/"
zip -r "${NAME}.zip" "${NAME}/"
rm -rf "${NAME}/"

popd

echo "Generated tarball for tag ${TAG} as _dist/${NAME}.tar.gz"
echo "Generated zip for tag ${TAG} as _dist/${NAME}.zip"
