#!/bin/bash

id
su -s <<EOF

echo "Entering Root Mode"
echo "---------------"
echo " "
echo "Now i am root"
id
echo "yes!"

echo " "
echo "Installing sudo"
echo "---------------"
echo " "
sudo apt install sudo
dpkg -l | grep sudo

echo " "
echo "Adding user to sudo"
echo "---------------"
echo " "
adduser $LOGNAME sudo
getent group sudo

EOF
