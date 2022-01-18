#!/bin/bash 

###################################################################
# .SH NAME
# Ubuntu Setup Automation Tool (USAT)
#
# .SH DESCRIPTION
# Automated process to install & setup applications for Ubuntu.
#
# .SH OPTIONS
# Argument structure: -FLAG FILE
# 1. -a: Installs applications & packages from APT
#        Requires: Path to the file contains the APT package list
# 2. -c: Configures applications & packages (from APT)
#        Requires: Configuration file (.sh or text file) with bash commands
# 3. -d: Installs .deb files included in a specified directory. This files 
#        usually do not exist in the apt repository (eg. anydesk etc.)
#        Requires: Path to directory containing .deb files
#
# Wrong flags are reported. Duplicate flags are overwritten.
#
# Usage: ./usat.sh -a APT_PACKAGE_LIST -c CONFIG_FILE -d DEB_DIRECTORY
# (in any order).
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
if [ $# -lt 2 ]; then
    echo -e "$RED[ERR]$RESET $USAGE"
    exit 1
fi

# Check for proper argument format
for (( i=1; i <= $#; ((i=i+2)) ))
do
  # Resolve structure -FLAG PARAM
  FLAG="${!i}"
  NEXT_NUMBER=$((i+1))
  PARAM="${!NEXT_NUMBER}"

  if [[ $FLAG == "-a" ]] && [[ -f $PARAM ]]; then
    APT_PACKAGE_LIST="$PARAM"
  elif [[ $FLAG == "-c" ]] && [[ -f $PARAM ]]; then
    CONFIG_FILE="$PARAM"
  elif [[ $FLAG == "-d" ]] && [[ -d $PARAM ]]; then
    DEB_DIRECTORY="$PARAM"
  else
    echo -e "$RED[ERR] Wrong flag or file/directory $PARAM does not exist $RESET"
    exit
  fi
done


############################################
# Install applications & packages from APT 
############################################

if [ ! -z "$APT_PACKAGE_LIST" ]; then

  echo -e "$MAGENTA[APT] Installing applications & packages from APT $RESET"
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

fi

##############################################
# Configure applications & packages from APT 
##############################################

if [ ! -z "$CONFIG_FILE" ]; then

  echo -e "$MAGENTA[CON] Configuring installed applications & packages $RESET"
  sleep 1

  while read config
  do
    echo -e "$YELLOW[INF] Configuring $RESET $config"
    command $config
  done < $CONFIG_FILE

fi

##########################################################
# Install .deb files included in the specified directory
##########################################################

if [ ! -z "$DEB_DIRECTORY" ]; then

  echo -e "$MAGENTA[DEB] Installing .deb files $RESET"
  sleep 1

  for file in "$DEB_DIRECTORY"/*
  do
    # Install only .deb files
    if [[ $file == *.deb ]]; then
      echo -e "$YELLOW[INF] Installing $RESET $file"
      dpkg -i "$file"
    fi
  done

fi

goodbye
