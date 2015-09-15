#!/bin/bash

apt-get update
apt-get -y install git emacs24-nox

mkdir /data
cd /data
git clone git@github.com:tbronchain/vpn.git
