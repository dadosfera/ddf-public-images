# !/usr/bin/env bash

# TODO always use TODO to show uncomplete work or future work that is not assigned to a GIT Issue
# AI > File name is a parameter from a standard header's Dadosfera

# Dadosfera Standard Header
FILE_NAME="env-section#001:python310_any:chrome.sh"
SCRIPT_ID="<script env-section#001 log msg>"
ENV_NAME="none"
# Define paths for Conda and Mamba initialization scriptsc considering Orchest
CONDA_PATH="/opt/conda/etc/profile.d/conda.sh"
MAMBA_PATH="/opt/conda/etc/profile.d/mamba.sh"
CURRENT_USER=$(whoami)
HOME_DIR="/home/${CURRENT_USER}"
BASHRC_PATH="${HOME_DIR}/.bashrc"
ORCHESTRC_PATH="${HOME_DIR}/.orchestrc"


# Log function for consistent formatting
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - PID:$$ - ${SCRIPT_ID} - $*"
}

FILE_NAME="env-section#001:python310_any:chrome.sh"
SUB_ENV_SECTION_001_SCRIPT_ID='<SUB SCRIPT ENV_SECTION_001>'
# Define ChromeDriver Directory
CHROMEDRIVER_DIRS=(
    "/usr/local/bin/",
    "/usr/bin/",
    "/usr/sbin/",
    "/bin/",
    "/sbin/"
)


# Function to log messages with consistent formatting
log_env_section_001() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - PID:$$ - ${SUB_ENV_SECTION_001_SCRIPT_ID} - $* "
}

exit_on_error() {
    log_env_section_001 "$1"
    exit 1
}

break_flag=false

break_on_error() {
    log_env_section_001 "$1"
    break_flag=true
    continue
}

handle_break_flag() {
    if $break_flag ; then
        break_flag=false
        continue
    fi
}

# Update package list
log_env_section_001 "Updating Package List"
sudo apt-get update -q -y || exit_on_error "Unable to update package list"

log_env_section_001 "SUCCESS: Updated Package List"


# Install necessary dependencies
log_env_section_001 "Install necessary dependencies"
sudo apt-get -q -y --no-install-recommends install libasound2 libdrm2 libgbm1 libu2f-udev libvulkan1 xdg-utils curl jq gdebi-core unzip || exit_on_error "Unable to install packages"
sudo apt-get install libappindicator1 xvfb -y

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
CHROMEDRIVER_PATH="" # Variable to hold the successful installation path



# Try installing ChromeDriver in each directory
for directory in "${CHROMEDRIVER_DIRS[@]}"; do
    log_env_section_001 "Trying to install ChromeDriver in $directory"
    
    CHROMEDRIVER_PATH="$directory"
    # Checking and creating directory if not exists
    log_env_section_001 "Checking chromedriver dir"
    [ ! -d "$directory" ] && sudo mkdir -p "$directory" || break_on_error "Unable to create directory for chromedriver: $directory"
    
    handle_break_flag

    # Download, unzip and set permissions for ChromeDriver
    log_env_section_001 "Download current chrome driver"
    curl -o "$CHROMEDRIVER_FILE.zip" "$CHROMEDRIVER_URL" || break_on_error "ERROR: Failed to download ChromeDriver"

    handle_break_flag
    
    log_env_section_001 "unziping ChromeDriver"
    sudo unzip "$CHROMEDRIVER_FILE.zip" -d "$CHROMEDRIVER_PATH" || break_on_error "ERROR: Failed to unzip ChromeDriver"

    handle_break_flag

    log_env_section_001 "changing ChromeDriver dir"
    sudo mv $CHROMEDRIVER_FILE "$CHROMEDRIVER_PATH" || break_on_error "ERROR: Failed move chromedriver to specified path $CHROMEDRIVER_PATH"

    handle_break_flag

    log_env_section_001 "setting executable permissions for ChromeDriver"
    sudo chown root:root "$CHROMEDRIVER_PATH" || break_on_error "ERROR: Failed to set executable permissions for ChromeDriver"

    handle_break_flag

    log_env_section_001 "set executable permissions for dir, subdirs and ChromeDriver file"
    sudo chmod -R +x "$directory" || break_on_error "ERROR: Failed to set executable permissions for dir, subdirs and ChromeDriver file"

    handle_break_flag

    
    
    # Check if ChromeDriver exists at the specified path
    if [ ! -f "$CHROMEDRIVER_PATH/$CHROMEDRIVER_FILE" ]; then
        break_on_error "ERROR: ChromeDriver not found at $CHROMEDRIVER_PATH" 

        handle_break_flag
    fi

    if $break_flag ; then
        continue
    else
        break_flag=false
        break
    fi

done


if $break_flag ; then
    exit_on_error "ERROR: Failed to install ChromeDriver in all directories"
else
    log_env_section_001 "SUCCESS: ChromeDriver installed in $CHROMEDRIVER_PATH"
fi



CHROMEDRIVER_FULL_PATH="$CHROMEDRIVER_PATH$CHROMEDRIVER_FILE"

# Add ChromeDriver to the PATH in a persistent way
if ! grep -q "export PATH=\$PATH:$CHROMEDRIVER_FULL_PATH" ~/.bashrc; then
    echo "export PATH=\$PATH:$CHROMEDRIVER_FULL_PATH" >> ~/.bashrc
fi

export PATH=$PATH:$CHROMEDRIVER_PATH


# Adding an alias for google-chrome command
CHROME_COMMAND="alias google-chrome='command google-chrome --headless --disable-gpu --remote-debugging-port=9222'"

if ! grep -q "$CHROME_COMMAND" ~/.bashrc; then
    echo "$CHROME_COMMAND" >> ~/.bashrc
fi


source ~/.bashrc

log_env_section_001 "INFO: Chrome and ChromeDriver installed successfully!"
log_env_section_001 "Installed Chrome version: $CHROME_VERSION"
log_env_section_001 "Installed ChromeDriver version: $CHROMEDRIVER_VERSION"
log_env_section_001 "Finished Chrome and ChromeDriver installation."
exit 0
# AI> You need to always ensure that chrome and chrome driver are in the same version
