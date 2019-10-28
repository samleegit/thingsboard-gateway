if [ "$1" = "clean" ] || [ "$1" = "only_clean" ] ; then
  sudo rm -rf /var/log/thingsboard-gateway/
  sudo rm -rf deb_dist/
  sudo rm -rf dist/
  sudo rm -rf thingsboard-gateway.egg-info/
  sudo rm -rf /etc/thingsboard-gateway/
  sudo rm -rf thingsboard-gateway-2.0.0.tar.gz
  sudo rm -rf /home/zenx/rpmbuild/BUILDROOT/*
  sudo rm -rf build/
  sudo apt remove python3-thingsboard-gateway -y
fi

#IFS=':' read -ra env_path <<< "$PATH"


if [ "$1" != "only_clean" ] ; then
  # Create sources for DEB package
  python3 setup.py --command-packages=stdeb.command bdist_deb
  # Adding the files, scripts and permissions
  sudo cp -r temp/etc deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway
  sudo cp -r temp/var deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway
  sudo cp -r -a temp/DEBIAN deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway
  sudo chown root:root deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway/ -R
  sudo chown root:root deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway/var/ -R
  sudo chmod 775 deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway/DEBIAN/preinst
  sudo chown root:root deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway/DEBIAN/preinst
  # Bulding Deb package
  dpkg-deb -b deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway/
  cp deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway.deb .
  # Create sources for RPM Package
  echo 'Building sources RPM package'
  python3 setup.py --command-packages=stdeb.command bdist_rpm
  cp build/bdist.linux-x86_64/rpm/* /home/$USER/rpmbuild/ -r
  # Adding the file, scripts and permissions
  cp temp/etc/systemd/system/thingsboard-gateway.service /home/$USER/rpmbuild/SOURCES/
  cd temp/etc/thingsboard-gateway/
  tar -zcvf configs.tar.gz .*
  cp configs.tar.gz /home/$USER/rpmbuild/SOURCES/
  cd ../../../
  # Bulding RPM Package
  cp thingsboard-gateway.spec /home/$USER/rpmbuild/SPECS/
  rpmbuild -ba thingsboard-gateway.spec
  cp /home/$USER/rpmbuild/RPMS/noarch/*.rpm .
#  sudo apt install ./deb_dist/thingsboard-gateway-2.0.0/debian/python3-thingsboard-gateway.deb -y
fi
