#!/bin/bash 

###################################################################
# .SH NAME
# Ubuntu Setup Automation Tool (USAT)
#
# .SH DESCRIPTION
# Automated process to install & setup applications for Ubuntu.
#
# .SH OPTIONS
# Arguments:
# 1. Path to the file contains the APT package list (required)
# 2. Configuration file for APT packages & applications (optional)
# 3. Path to directory containing .deb files that don'ts exist
# in the apt repository (eg. anydesk etc.) (optional)
# Usage: ./usat.sh APT_PACKAGE_LIST CONFIG_FILE DEB_DIRECTORY
# Example: ./usat.sh apt_list.txt config.sh (or .txt) ../debs
#
# .SH BUGS
# No known bugs.
#
# .SH AUTHOR
# Giorgos.
###################################################################

GREEN="\033[92m"
RED="\033[91m"
YELLOW="\033[93m"
BLUE="\033[94m"
MAGENTA="\033[95m"
CYAN="\033[96m"
RESET="\033[0m"
USAGE="Usage: $0 APT_PACKAGE_LIST CONFIG_FILE DEB_DIRECTORY"

APT_PACKAGE_LIST=$1
CONFIG_FILE=$2
DEB_DIRECTORY=$3

function completed() { echo -e "$GREEN[ COMPLETED ]  $RESET"; }
function exists()  { echo -e "$CYAN[ ALREADY INSTALLED ] $RESET"; }
function error()  { echo -e "$RED[ CANNOT INSTALL ] $RESET"; }

# For completely silent apt install:
# function install() { apt-get install -qq $1 > /dev/null && completed || error; }
function install() { apt-get install -qq $1 && completed || error; }
function execute() { $1 && completed || error; }
function updates() { add-apt-repository multiverse -y; apt-add-repository universe -y; apt-get update; }
function goodbye() { echo -e "$CYAN[END] Ubuntu Setup Automation Tool (USAT) completed successfully. Goodbye! $RESET"; exit 0; }

echo -e "$CYAN[APP] Ubuntu Setup Automation Tool (USAT) started $RESET"

######################
# Input verification 
######################

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "$RED[ERR] Please run as root $RESET"
  exit 1
fi


# Check for proper arguments
if [ $# -lt 1 ]; then
    echo -e "$RED[ERR]$RESET $USAGE"
    exit 1
fi

# Check if APT package list exists
if [ ! -f "$APT_PACKAGE_LIST" ]; then
  echo -e "$RED[ERR] File $APT_PACKAGE_LIST does not exist $RESET"
  exit 1
fi

# Check if configuration file exists
if [ $# -eq 2 ] && [ ! -f "$CONFIG_FILE" ]; then
  echo -e "$RED[ERR] File $CONFIG_FILE does not exist $RESET"
  exit 1
fi

# Check if .deb repository directory exists
if [ $# -eq 3 ] && [ ! -d "$DEB_DIRECTORY" ]; then
  echo -e "$RED[ERR] Directory $DEB_DIRECTORY does not exist $RESET"
  exit 1
fi

############################################
# Install applications & packages from APT 
############################################

echo -e "$MAGENTA[S01] Installing applications & packages from APT $RESET"
sleep 1

# Update APT
echo -e "$YELLOW[INF] Updating ATP repositories $RESET"
updates

# Install APT packages
while read package
do
  echo -en "$YELLOW[INF] Installing $RESET $package "
  ( dpkg -l "$package" &> /dev/null && exists ) || install $package
done < $APT_PACKAGE_LIST

##############################################
# Configure applications & packages from APT 
##############################################

if [ $# -lt 2 ]; then
  goodbye
fi

echo -e "$MAGENTA[S02] Configuring installed applications & packages $RESET"
sleep 1

while read config
do
  echo -e "$YELLOW[INF] Configuring $RESET $config"
  command $config
done < $CONFIG_FILE

##########################################################
# Install .deb files included in the specified directory
##########################################################

if [ $# -lt 3 ]; then
  goodbye
fi

echo -e "$MAGENTA[S03] Installing .deb files $RESET"
sleep 1

for file in "$DEB_DIRECTORY"/*
do
  # Install only .deb files
  if [[ $file == *.deb ]]; then
    echo -e "$YELLOW[INF] Installing $RESET $file"
    dpkg -i "$file"
  fi
done

goodbye
