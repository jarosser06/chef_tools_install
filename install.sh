#!/bin/bash

VIRTUALBOX_VER="4.3.8"
VIRTUALBOX_FULL_VER="4.3.6-91406"
VIRTUALBOX_BASE_URL="http://download.virtualbox.org/virtualbox/4.3.6"

VAGRANT_BASE_URL="https://dl.bintray.com/mitchellh/vagrant"
VAGRANT_VER="1.5.2"

CHEFDK_BASE_URL="https://opscode-omnibus-packages.s3.amazonaws.com"
CHEFDK_VER="0.1.0"

platform='unkown'
unamestr=`uname`

install_vbox=true
install_vagrant=true
install_chefdk=true

# Get sudo password at the beginning
echo "Sudo is required to run this script"
sudo ls &> /dev/null

if [ -a "/usr/bin/vagrant" ]; then
  echo -e "Vagrant already exists... \t\t\t\tskipping"
  install_vagrant=false
fi

if [ -a "/usr/bin/virtualbox" ]; then
  vbox_installed_version=`vboxmanage --version | sed s/r/-/`

  if [ "$vbox_installed_version" == $VIRTUALBOX_FULL_VER ]; then
    echo -e "Virtualbox already exists and is correct version... \tskipping"
    install_vbox=false
  fi
fi

if [ -a "/opt/chefdk/bin/chef" ]; then
  chefdk_installed_version=`chef --version | awk '{print $5}'`
  if [ "$chefdk_installed_version" == $CHEFDK_VER ]; then
    echo -e "ChefDK already installed and is correct version... \tskipping"
    install_chefdk=false
  fi
fi

if [[ "$unamestr" == "Linux" ]]; then
  platform='linux'
  source /etc/os-release

  distro=${NAME}
  version=${VERSION_ID}

  if [ "$distro" == "Ubuntu" ]; then
    chef_dk_avail=false
    case $version in
      "12.04")
        version_name='precise'
        chef_dk_avail=true
        ;;
      "12.10")
        version_name='quantal'
        ;;
      "13.04")
        version_name='raring'
        ;;
      "13.10")
        version_name='raring'
        chef_dk_avail=true
        ;;
      "14.04")
        version_name='raring'
        ;;
      *)
        echo "Version name not found"
    esac

    if [ "$install_vbox" == true ]; then
      echo "Installing Virtualbox..."
      virtualbox_pkg="virtualbox-4.3_${VIRTUALBOX_FULL_VER}~Ubuntu~${version_name}_amd64.deb"
      curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} > /tmp/${virtualbox_pkg}
      sudo dpkg -i /tmp/${virtualbox_pkg}
    fi

    if [ "$install_vagrant" == true ]; then
      echo "Installing Vagrant..."
      vagrant_pkg="vagrant_${VAGRANT_VER}_x86_64.deb"
      curl -L ${VAGRANT_BASE_URL}/${vagrant_pkg} > /tmp/${vagrant_pkg}
      sudo dpkg -i /tmp/${vagrant_pkg}
    fi

    if [ "$install_chefdk" == true ]; then
      if [ "$chef_dk_avail" == true ]; then
        echo "Installing ChefDK..."
        chefdk_pkg="chefdk_${CHEFDK_VER}-1_amd64.deb"
        curl -L ${CHEFDK_BASE_URL}/ubuntu/${version}/x86_64/${chefdk_pkg} > /tmp/${chefdk_pkg}
        sudo dpkg -i /tmp/${chefdk_pkg}
      else
        echo "Oops no ChefDK package currently avilable for this version"
      fi
    fi

  elif [ "$distro" == "Fedora" ]; then
    if [ "$install_vbox" == true ]; then
      echo "Installing Virtualbox..."
      if [ "$version" == "17" ]; then
        virtualbox_pkg="VirtualBox-4.3-4.3.6_91406_fedora17-1.x86_64.rpm"
      else
        virtualbox_pkg="VirtualBox-4.3-4.3.6_91406_fedora18-1.x86_64.rpm"
      fi
      curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} > /tmp/${virtualbox_pkg}
      sudo yum install /tmp/${virtualbox_pkg}
    fi

    if [ "$install_vagrant" == true ]; then
      echo "Installing Vagrant..."
      vagrant_pkg="vagrant_${VAGRANT_VER}_x86_64.rpm"
      curl -L ${VAGRANT_BASE_URL}/${vagrant_pkg} > /tmp/${vagrant_pkg}
      sudo yum install /tmp/${vagrant_pkg}
    fi

    if [ "$install_chefdk" == true ]; then
      echo "Installing ChefDK..."
      chefdk_pkg="chefdk-${CHEFDK_VER}-1.el6.x86_64.rpm"
      curl -L ${CHEFDK_BASE_URL}/el/6/x86_64/${chefdk_pkg} > /tmp/${chefdk_pkg}
      sudo yum install /tmp/${chefdk_pkg}
    fi
  else
    echo "Not yet supported"
  fi
elif [[ "$unamestr" == "Darwin" ]]; then

  if [ "$install_vbox" == true ]; then
    echo "Installing Virtualbox"
    virtualbox_pkg="VirtualBox-${VIRTUALBOX_FULL_VER}-OSX.dmg"
    curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} > /tmp/${virtualbox_pkg}
    hdiutil attach /tmp/${virtualbox_pkg}
    sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
    hdiutil detach /Volumes/VirtualBox
  fi

  if [ "$install_vagrant" == true ]; then
    echo "Installing Vagrant"
    vagrant_pkg="vagrant_${VAGRANT_VER}.dmg"
    curl -L ${VAGRANT_BASE_URL}/${vagrant_pkg} > /tmp/${vagrant_pkg}
    hdiutil attach /tmp/${vagrant_pkg}
    sudo installer -pkg /Volumes/Vagrant/Vagrant.pkg -target /
    hdiutil detach /Volumes/Vagrant
  fi

  if [ "$install_chefdk" == true ]; then
    echo "Installing ChefDK..."
    chefdk_pkg="chefdk-${CHEFDK_VER}-1.dmg"
    curl -L ${CHEFDK_BASE_URL}/mac_os_x/10.9/x86_64/${chefdk_pkg} > /tmp/${chefdk_pkg}
    hdiutil attach /tmp/${chefdk_pkg}
    sudo installer -pkg /Volumes/chefdk/chefdk.pkg -target /
    hdiutil detach /Volumes/chefdk
  fi
fi

if [ "$install_vbox" == true ]; then
  echo "Installing vagrant plugins"
  vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
  vagrant plugin install vagrant-omnibus
fi

echo "Enjoy!!"
