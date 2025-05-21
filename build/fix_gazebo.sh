#!/bin/bash

echo "Installing gazebo fix."
echo "Installing DART 6.10"

# Install DART 6.10
sudo mkdir -p /usr/local/lib
git clone https://github.com/gazebo-forks/dart -b release-6.10
mkdir dart/build
cd dart/build
#sudo apt install coinor-libipopt-dev libnlopt-cxx-dev -y
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/dart6.10 -DCMAKE_BUILD_TYPE=Release
make -j12 && sudo make -j12 install
for f in dart dart-collision-bullet dart-collision-ode dart-external-odelcpsolver; do sudo ln -s /opt/dart6.10/lib/lib${f}.so.6.10 /usr/local/lib/lib${f}.so.6.10; done;
sudo ldconfig

echo "Installing ign-physics5"
# Install ign-physics5
cd ../..
git clone https://github.com/gazebosim/gz-physics -b ign-physics5
mkdir gz-physics/build
cd gz-physics/build
CMAKE_PREFIX_PATH=/opt/dart6.10/share/dart/cmake:$CMAKE_PREFIX_PATH cmake .. -DCMAKE_INSTALL_PREFIX=/opt/ign-physics5 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_DOCS=OFF -DBUILD_TESTING=OFF -DSKIP_bullet=ON -DSKIP_tpe=ON
make -j12 && sudo make -j12 install 
# Now this is ugly hack but there is no way to convince gz::common::SystemPaths to prefer a custom engine named the same as a preinstalled one.
sudo ln -sf /opt/ign-physics5/lib/ign-physics-5/engine-plugins/libignition-physics-dartsim-plugin.so /usr/lib/$(uname -m)-linux-gnu/ign-physics-5/engine-plugins/libignition-physics-dartsim-plugin.so
