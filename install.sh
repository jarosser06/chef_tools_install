bundle install

VIRTUALBOX_VER="4.3.6"
VIRTUALBOX_FULL_VER="4.3_4.3.6-91406"
VIRTUALBOX_BASE_URL="http://download.virtualbox.org/virtualbox/4.3.6"

platform='unkown'
unamestr=`uname`

vbox_version=`VBoxHeadless --version`
install_vbox=true


if [ "$vbox_version" != '']; then
  install_vbox=false
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
      virtualbox_pkg="virtualbox-${VIRTUALBOX_FULL_VER}~Ubuntu~${version_name}_amd64.deb"
      curl -L ${VIRTUALBOX_BASE_URL}/${virtualbox_pkg} /tmp/${virtualbox_pkg}
      sudo dpkg -i /tmp/${virtualbox_pkg}
    fi

  elif [ $distro == 'Fedora']; then
    echo "Not yet supported"
  fi
fi
