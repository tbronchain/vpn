#!/bin/bash
#
## OSX build
## by Thibault Bronchain
#

if [ "$1" = "--clean" ]; then
    rm -rf SimpleShadowSocks.{app,pkg,plist} build dist
    exit
elif [ "$1" = "--re" ]; then
    rm -rf SimpleShadowSocks.{app,pkg,plist} build dist pkg
fi

# build app
#py2applet --make-setup --iconfile misc/ShadowSocks.png src/SimpleShadowSocks.py
python setup.py py2app
cp -r dist/SimpleShadowSocks.app SimpleShadowSocks.app

# build pkg
pkgbuild --analyze --root ./SimpleShadowSocks.app "SimpleShadowSocks.plist"
pkgbuild --root ./SimpleShadowSocks.app --scripts scripts --component-plist SimpleShadowSocks.plist --identifier "com.almaritech.simpleshadowsocks.pkg" --version 1 --install-location "/Applications/SimpleShadowSocks.app/"  SimpleShadowSocks.pkg

# bundle
mkdir -p pkg/simple-ss
cp -r SimpleShadowSocks.pkg scripts/ss-setup.sh pkg/simple-ss/
cd pkg
zip -r simple-ss.zip simple-ss
