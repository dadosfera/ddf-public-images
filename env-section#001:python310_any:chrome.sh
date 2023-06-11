#!/bin/bash

# AI > File name
FILE_NAME="env-section#001:python310_any:chrome.sh"

# Log function for consistent formatting
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - PID:$$ - $* - SCRIPT PROMPT"
}

### Section 02 Start: Installation of Chrome 
log "${SCRIPT_OUTPUT} Starting Chrome and ChromeDriver installation..."

# Get the latest stable version of Google Chrome for Linux
CHROME_VERSION=$(curl -s https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os=="linux") | .versions[] | select(.channel=="stable") | .current_version')

log "${SCRIPT_OUTPUT} Find last chrome version"
# install necessary dependencies
sudo apt-get update --q -y
sudo apt-get install -q -y --no-install-recommends libasound2 libdrm2 libgbm1 libu2f-udev libvulkan1 xdg-utils

log "${SCRIPT_OUTPUT} Install chrome dependencies"
# TODO REMOVE wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# TODO REMOVE sudo dpkg -i google-chrome-stable_current_amd64.deb
# TODO REMOVE sudo apt-get install -y google-chrome-stable

# Download and install Google Chrome
wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb
sudo dpkg --quiet -i google-chrome-stable_${CHROME_VERSION}-1_amd64.deb
# Check for broken dependencies
sudo apt-get -q -y install -f

log "${SCRIPT_OUTPUT} Download current chrome"


# Get the ChromeDriver matching the installed Chrome version
chrome_path=$(which google-chrome || true)
CHROME_VERSION_SHORT=${CHROME_VERSION%%.*}
CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION_SHORT")
CHROME_INSTALLED_VERSION=$(google-chrome-stable --version | grep -oP '(\d+\.){3}\K\d+')



if [ -z "$chrome_path" ]; then
    log "${SCRIPT_OUTPUT} ERROR: Chrome binary not found"
    exit 1
else
    # Install and run ChromeDriver
    # TODO REMOVE wget "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"


    log "${SCRIPT_OUTPUT} Download current chrome driver"
    # Chromedriver download handling
    curl -o "chromedriver.zip" "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip">>"$stdall_log_file" 2>&1 || {
        log "${SCRIPT_OUTPUT} ERROR: Failed to download ChromeDriver"
        exit 1
    }

    log "${SCRIPT_OUTPUT} Checking chrome dir"
    # Check if the directory exists and create if it doesn't
    if [ ! -d "$CHROMEDRIVER_DIR" ]; then
    sudo mkdir -p "$CHROMEDRIVER_DIR"
    fi

    CHROMEDRIVER_PATH="$CHROMEDRIVER_DIR/chromedriver"
    log "${SCRIPT_OUTPUT} Unzip chrome to ${CHROMEDRIVER_PATH}"
    # Unzip ChromeDriver handling
    unzip chromedriver.zip -d "$CHROMEDRIVER_DIR" >>"$stdall_log_file" 2>&1 || {
        log "${SCRIPT_OUTPUT} ERROR: Failed to unzip ChromeDriver"
        exit 1
    }


    sudo mv chromedriver "$CHROMEDRIVER_PATH"
    sudo chown root:root "$CHROMEDRIVER_PATH"

    
    sudo chmod +x "$CHROMEDRIVER_PATH" || {
        log "${SCRIPT_OUTPUT} ERROR: Failed to set executable permissions for ChromeDriver"
        exit 1
    }

    # Add ChromeDriver to the PATH in a persistent way
    log "${SCRIPT_OUTPUT} export PATH=\$PATH:$CHROMEDRIVER_DIR" >> ~/.bashrc
    log "${SCRIPT_OUTPUT} INFO: Chrome and ChromeDriver installed successfully!"
    log "${SCRIPT_OUTPUT} Installed Chrome version: $CHROME_VERSION"
    log "${SCRIPT_OUTPUT} Installed ChromeDriver version: $CHROMEDRIVER_VERSION"
    export PATH=$PATH:$CHROMEDRIVER_DIR
fi

log "${SCRIPT_OUTPUT} Finished Chrome and ChromeDriver installation."
### Section 02 End: Installation of Chrome 
