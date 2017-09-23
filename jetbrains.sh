#!/bin/bash

# Echo the word Error in red followed by $1
error() {
  echo -e "\e[1;31mError: \e[0m$1"
  exit $2
}

# Echo $1 with color $2
color() {
  echo -e "\e[1;$2m$1\e[0m"
}

clear
# if [ "$(whoami)" != "root" ]; then
#   error "Please run this script as root!" 1
# fi

# Get the name of the porgam
color "What application would you like to update?" 32
select app in WebStorm PhpStorm PyCharm Idea; do
  if [[ -n $app ]]; then
    break
  else
    echo 'Please input a valid option!'
  fi
done

# Get version of the program to install
color "What version of $app would you like to install?" 32
read version
color "Installing $app $version..." 34

#Generate url and store name of the program
base=https://download.jetbrains.com
case $app in
  "PhpStorm")
    program=phpstorm
    base=$base/webide/PhpStorm
    ;;
  "WebStorm")
    program=webstorm
    base=$base/webstorm/WebStorm
    ;;
  "PyCharm")
    program=pycharm
    base=$base/python/pycharm-professional
    ;;
  "Idea")
    program=idea
    base=$base/idea/ideaIU
    ;;
esac

# Setup vars for the installation
tmp=/tmp/$program
dir=/opt/$program
tar=$base-$version-no-jdk.tar.gz
sha=$tar.sha256

# Create temporary directory
if [ -d $tmp ]; then
  rm -rf $tmp
fi
mkdir $tmp
cd $tmp

# Download the tarball and sha file
color "Beginning Download..." 34
wget $tar $sha
if [ $? != 0 ]; then
  error "Download failed!" $?
fi
color "Download completed!" 32

# Verify the sha
color "Verifying File.." 34
sha256sum -c ./*.sha256
if [ $? != 0 ]; then
  error "The SHA256 hash does not match the file!" $?
fi
color "File verified!" 32

# Delete the current installation
if [ -d $dir ]; then
  rm -rf $dir
fi
mkdir $dir

# Unpack the tar
color "Unpacking the Tarball.." 34
tar -xf ./*.tar.gz -C $dir
if [ $? != 0 ]; then
  error "Could not unpack the tarball!" $?
fi
rm -rf $tmp
color "Tar unpacked!" 32

# Start application
cd $dir/*/bin
(./$program.sh &) # wrapping creates a cp, & creates grandcp which gets inherited by init
