#!/bin/bash
bundle install

VIRTUALBOX_VER="4.3.6"
VIRTUALBOX_FULL_VER="4.3.6-91406"
VIRTUALBOX_BASE_URL="http://download.virtualbox.org/virtualbox/4.3.6"

VAGRANT_BASE_URL="https://dl.bintray.com/mitchellh/vagrant"
VAGRANT_VER="1.4.3"

platform='unkown'
unamestr=`uname`

vbox_version=`VBoxHeadless --version`
install_vbox=false


if [ "$vbox_version" == "" ]; then
  install_vbox=true
fi

if [[ "$unamestr" == "Linux" ]]; then
  platform='linux'
  source /etc/os-release

  distro=${NAME}
  version=${VERSION_ID}

  if [ $distro == 'Ubuntu']; then
    case $version in
      "12.04")
        version_name='precise'
        ;;
      "12.10")
        version_name='quantal'
        ;;
      "13.04")
        version_name='raring'
        ;;
      *)
        echo "Version name not found"
    esac

    if [ install_vbox ];then
      echo "Installing Virtualbox..."
      virtualbox_pkg="virtualbox-4.3_${VIRTUALBOX_FULL_VER}~Ubuntu~${version_name}_amd64.deb"
      curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} > /tmp/${virtualbox_pkg}
      sudo dpkg -i /tmp/${virtualbox_pkg}

      echo "Installing Vagrant..."
      vagrant_pkg="vagrant_${VAGRANT_VER}_x86_64.deb"
      curl -L ${VAGRANT_BASE_URL}/${vagrant_pkg} > /tmp/${vagrant_pkg}
      sudo dpkg -i /tmp/${vagrant_pkg}
    fi

  else
    echo "Not yet supported"
  fi
elif [[ "$unamestr" == "Darwin" ]]; then

  echo "Installing Virtualbox"
  virtualbox_pkg="VirtualBox-${VIRTUALBOX_FULL_VER}-OSX.dmg"
  curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} > /tmp/${virtualbox_pkg}
  hdiutil attach /tmp/${virtualbox_pkg}
  sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
  hdiutil detach /Volumes/VirtualBox

  echo "Installing Vagrant"
  vagrant_pkg="Vagrant-${VAGRANT_VER}.dmg"
  curl -L ${VAGRANT_BASE_URL}/${vagrant_pkg} > /tmp/${vagrant_pkg}
  hdiutil attach /tmp/${vagrant_pkg}
fi
