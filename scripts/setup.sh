# Google Cloud Shell Software Installation
#   - CS always provides x86_64 Debian Linux environment
#   - Software installation is not preserved, only the file system. This script must be run on every boot.
#   - CS has no mechanism to launch a script automatically, manual interventions is required.
#   - This script must be run with system administrator privileges
#

# Create dependencies and prepare for the download

mkdir -p ~/Downloads ~/.cloudshell
touch ~/.cloudshell/no-apt-get-warning  # Suppress the CS ephemeral environment warning
rm ~/setup.log

# Install the correct Alire package for this environment

echo "Installing the latest Alire package..." | tee -a ~/setup.log
cd ~/Downloads
alr_latest=$(curl -sL https://api.github.com/repos/alire-project/alire/releases/latest | jq -r .tag_name)
if ! curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-x86_64-linux.zip" > ~/setup.log 2>&1; then
    echo "Failed to download Alire package." | tee -a ~/setup.log
    exit 1
fi
unzip -j alr-${alr_latest#v}-bin-x86_64-linux.zip bin/alr -d /usr/local/bin

# Install system dependencies required for building and unpacking Ada tooling

echo "Installing the build dependencies..." | tee -a ~/setup.log
apt-get update > ~/setup.log 2>&1
if ! apt-get install -y --no-install-recommends build-essential gnat gprbuild > ~/setup.log 2>&1; then
    echo "Failed to install build dependencies." | tee -a ~/setup.log
    exit 1
fi

# Add VS Code extensions (if they are not alreay there)

echo "Installing Visual Studio Code extensions..." | tee -a ~/setup.log
if ! /google/devshell/editor/code-oss-for-cloud-shell/bin/codeoss-cloudshell --install-extension adacore.ada > ~/setup.log 2>&1; then
    echo "Failed to install Visual Studio Code extension." | tee -a ~/setup.log
    exit 1
fi

echo "Setup completed successfully." | tee -a ~/setup.log

# Kill the initial Google CS window at the bottom of the screen

# pkill -9 -f -- '^-bash$'