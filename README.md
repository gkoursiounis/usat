# Ubuntu Setup Automation Tool (USAT)

Simple bash script that facilitates the installation of applications & packages in Ubuntu, using the Advanced Package Tool (APT) and its repositories.
Furthermore, it installs a list of locally stored .deb files for applications that do cannot be downloaded through APT. Lastly, it offers the possibility to execute a list of shell commands contained in .txt or .sh files that aim in the configuration of installed applications (eg. ssh etc.).

# Arguments
- Path to the file contains the APT package list (required)
- Configuration file for APT packages & applications (optional)
- Path to directory containing .deb files that don'ts exist in APT (eg. anydesk etc.) (optional)
# Usage 
`./usat.sh APT_PACKAGE_LIST CONFIG_FILE DEB_DIRECTORY`

Example: `./usat.sh apt_list.txt config.sh (or .txt) ../debs`
