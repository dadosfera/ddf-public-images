#!/bin/bash

# AI > File name
FILE_NAME="env-section#001:python310_any:chrome.sh"
SUB_ENV_SECTION_001_SCRIPT_ID='<SUB SCRIPT ENV_SECTION_001>'

# Function to log messages with consistent formatting
log_env_section_001() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - PID:$$ - ${SUB_ENV_SECTION_001_SCRIPT_ID} - $* "
}

exit_on_error() {
    log_env_section_001 "$1"
    exit 1
}

# Update package list
log_env_section_001 "Updating Package List"
sudo apt-get update -q -y || exit_on_error "Unable to update package list"

log_env_section_001 "SUCCESS: Updated Package List"


# Install necessary dependencies
log_env_section_001 "Install necessary dependencies"
sudo apt-get -q -y --no-install-recommends install libasound2 libdrm2 libgbm1 libu2f-udev libvulkan1 xdg-utils curl jq || exit_on_error "Unable to install packages"

log_env_section_001 "SUCCESS: necessary dependencies"

# Get the latest stable version of Google Chrome for Linux
log_env_section_001 "Finding last chrome version"
CHROME_VERSION=$(curl -s https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os=="linux") | .versions[] | select(.channel=="stable") | .current_version') || exit_on_error "Unable to get Chrome version"

log_env_section_001 "Chrome version is $CHROME_VERSION"


# Download and install Google Chrome
wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb || exit_on_error "Unable to download Google Chrome"
sudo dpkg -i google-chrome-stable_${CHROME_VERSION}-1_amd64.deb || exit_on_error "Unable to depackage Google Chrome"


# Set Chrome Variables
chrome_path=$(which google-chrome || true)
CHROME_VERSION_SHORT=${CHROME_VERSION%%.*}
CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION_SHORT")

if [ -z "$chrome_path" ]; then
    exit_on_error "ERROR: Chrome binary not found"
fi


# Set chrome drive variables
CHROMEDRIVER_URL="https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
CHROMEDRIVER_FILE="$(basename "$CHROMEDRIVER_URL")"
CHROMEDRIVER_PATH="$CHROMEDRIVER_DIR/$CHROMEDRIVER_FILE"


# Download, unzip and set permissions for ChromeDriver
log_env_section_001 "Download current chrome driver"
curl -o "$CHROMEDRIVER_FILE.zip" "$CHROMEDRIVER_URL" || exit_on_error "ERROR: Failed to download ChromeDriver"
log_env_section_001 "Checking chromedriver dir"
[ ! -d "$CHROMEDRIVER_DIR" ] && sudo mkdir -p "$CHROMEDRIVER_DIR"
unzip "$CHROMEDRIVER_FILE.zip" -d "$CHROMEDRIVER_DIR" || exit_on_error "ERROR: Failed to unzip ChromeDriver"

sudo mv chromedriver "$CHROMEDRIVER_PATH"
sudo chown root:root "$CHROMEDRIVER_PATH"
sudo chmod +x "$CHROMEDRIVER_PATH" || exit_on_error "ERROR: Failed to set executable permissions for ChromeDriver"

# Add ChromeDriver to the PATH in a persistent way
echo "export PATH=\$PATH:$CHROMEDRIVER_DIR" >> ~/.bashrc
export PATH=$PATH:$CHROMEDRIVER_DIR

log_env_section_001 "INFO: Chrome and ChromeDriver installed successfully!"
log_env_section_001 "Installed Chrome version: $CHROME_VERSION"
log_env_section_001 "Installed ChromeDriver version: $CHROMEDRIVER_VERSION"
log_env_section_001 "Finished Chrome and ChromeDriver installation."