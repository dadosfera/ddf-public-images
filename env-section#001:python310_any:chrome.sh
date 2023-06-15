#!/bin/bash

# AI > File name
FILE_NAME="env-section#001:python310_any:chrome.sh"
SUB_ENV_SECTION_001_SCRIPT_ID='<SUB SCRIPT ENV_SECTION_001>'
# Define ChromeDriver Directory
CHROMEDRIVER_DIRS = [
    "/usr/local/bin/",
    "/usr/bin/",
    "/usr/sbin/",
    "/bin/",
    "/sbin/"
]


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
sudo apt-get -q -y --no-install-recommends install libasound2 libdrm2 libgbm1 libu2f-udev libvulkan1 xdg-utils curl jq gdebi-core || exit_on_error "Unable to install packages"

log_env_section_001 "SUCCESS: necessary dependencies"

# Get the latest stable version of Google Chrome for Linux
log_env_section_001 "Finding last chrome version"
CHROME_VERSION=$(curl -s https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os=="linux") | .versions[] | select(.channel=="stable") | .current_version') || exit_on_error "Unable to get Chrome version"

log_env_section_001 "Chrome version is $CHROME_VERSION"


# Set chrome drive variables
CHROME_URL=https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb
CHROME_FILE="$(basename "$CHROME_URL")"


# Download and install Google Chrome
wget -q $CHROME_URL || exit_on_error "Unable to download Google Chrome"
sudo gdebi -n $CHROME_FILE || exit_on_error "Unable to depackage Google Chrome"

# fix broken dependencies
sudo apt-get install -f -y

# Set Chrome Variables
chrome_path=$(which google-chrome || true)
if [ -z "$chrome_path" ]; then
    exit_on_error "ERROR: Chrome binary not found"
fi
CHROME_VERSION_SHORT=${CHROME_VERSION%%.*}
CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION_SHORT")



# Set chrome drive variables
CHROMEDRIVER_URL="https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
CHROMEDRIVER_FILE="$(basename "$CHROMEDRIVER_URL")"
CHROMEDRIVER_PATH="$CHROMEDRIVER_DIR/$CHROMEDRIVER_FILE"


# Try installing ChromeDriver in each directory
for directory in "${CHROMEDRIVER_DIRS[@]}"; do
    log_env_section_001 "Trying to install ChromeDriver in $directory"
    
    # Checking and creating directory if not exists
    log_env_section_001 "Checking chromedriver dir"
    [ ! -d "$directory" ] && sudo mkdir -p "$directory" || exit_on_error "Unable to create directory for chromedriver: $directory"
    

    # Download, unzip and set permissions for ChromeDriver
    log_env_section_001 "Download current chrome driver"
    curl -o "$CHROMEDRIVER_FILE.zip" "$CHROMEDRIVER_URL" || exit_on_error "ERROR: Failed to download ChromeDriver"
    
    unzip "$CHROMEDRIVER_FILE.zip" -d "$CHROMEDRIVER_DIR" || exit_on_error "ERROR: Failed to unzip ChromeDriver"

    sudo chown root:root "$CHROMEDRIVER_PATH" || exit_on_error "ERROR: Failed to set executable permissions for ChromeDriver"

    sudo chmod -R +x "$directory" || exit_on_error "ERROR: Failed to set executable permissions for dir, subdirs and ChromeDriver file"

    sudo mv chromedriver "$CHROMEDRIVER_PATH" || exit_on_error "ERROR: Failed move chromedriver to specified path $CHROMEDRIVER_PATH"
    
    # Check if ChromeDriver exists at the specified path
    if [ ! -f "$CHROMEDRIVER_PATH" ]; then
        exit_on_error "ERROR: ChromeDriver not found at $CHROMEDRIVER_PATH"
    fi





# Add ChromeDriver to the PATH in a persistent way
echo "export PATH=\$PATH:$CHROMEDRIVER_DIR" >> ~/.bashrc
export PATH=$PATH:$CHROMEDRIVER_DIR


# Adding an alias for google-chrome command
echo "alias google-chrome='command google-chrome --headless --disable-gpu --remote-debugging-port=9222'" >> ~/.bashrc
source ~/.bashrc

log_env_section_001 "INFO: Chrome and ChromeDriver installed successfully!"
log_env_section_001 "Installed Chrome version: $CHROME_VERSION"
log_env_section_001 "Installed ChromeDriver version: $CHROMEDRIVER_VERSION"
log_env_section_001 "Finished Chrome and ChromeDriver installation."
exit 0
# AI> You need to always ensure that chrome and chrome driver are in the same version