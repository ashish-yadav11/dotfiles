#!/bin/sh
 dconf dump / >dconf-user
#dconf load / <dconf-user
 sudo dconf dump / >dconf-root
#sudo dconf load / <dconf-root
