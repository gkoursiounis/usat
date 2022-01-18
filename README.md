# Ubuntu Setup Automation Tool (USAT)

Simple bash script that facilitates the installation of applications & packages in Ubuntu, using the Advanced Package Tool (APT) and its repositories.
Furthermore, it installs a list of locally stored .deb files for applications that do cannot be downloaded through APT. Lastly, it offers the possibility to execute a list of shell commands contained in .txt or .sh files that aim in the configuration of installed applications (eg. ssh etc.).

# Arguments
Argument structure: -FLAG FILE
- -a: Installs applications & packages from APT. Requires: Path to the file contains the APT package list
- -c: Configures applications & packages (from APT). Requires: Configuration file (.sh or text file) with bash commands
- -d: Installs .deb files included in a specified directory. This files usually do not exist in the apt repository (eg. anydesk etc.). Requires: Path to directory containing .deb files

Wrong flags are reported. Duplicate flags are overwritten.

Usage: `./usat.sh -a APT_PACKAGE_LIST -c CONFIG_FILE -d DEB_DIRECTORY` (flags in any order).
