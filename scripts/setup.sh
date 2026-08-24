# Google Cloud Shell Software Installation
#   - CS always provides x86_64 Debian Linux environment
#   - Software installation is not preserved, only the file system. This script must be run on every boot.
#   - CS has no mechanism to launch a script automatically, manual interventions is required.
#   - This script must be run with system administrator privileges
#

# Create dependencies and prepare for the download

echo "Initializing setup..." | tee scripts/setup.log
mkdir -p ~/Downloads ~/.cloudshell
touch ~/.cloudshell/no-apt-get-warning  # Suppress the CS ephemeral environment warning

# Install the correct Alire package for this environment

echo "Installing the latest Alire package..." | tee -a scripts/setup.log
cd ~/Downloads
alr_latest=$(curl -sL https://api.github.com/repos/alire-project/alire/releases/latest | jq -r .tag_name)
echo "Alire version ${alr_latest}" | tee -a scripts/setup.log
if ! curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-x86_64-linux.zip" >> scripts/setup.log 2>&1; then
    echo "Failed to download Alire package." | tee -a scripts/setup.log
    exit 1
fi
sudo unzip -o -j alr-${alr_latest#v}-bin-x86_64-linux.zip bin/alr -d /usr/local/bin >> scripts/setup.log 2>&1

# Install system dependencies required for building and unpacking Ada tooling

echo "Installing the build dependencies..." | tee -a scripts/setup.log
sudo apt-get update >> scripts/setup.log 2>&1
if ! sudo apt-get install -y --no-install-recommends build-essential gnat gprbuild >> scripts/setup.log 2>&1; then
    echo "Failed to install build dependencies." | tee -a scripts/setup.log
    exit 1
fi

# Add VS Code extensions (if they are not alreay there)

echo "Installing Visual Studio Code extensions..." | tee -a scripts/setup.log
if ! /google/devshell/editor/code-oss-for-cloud-shell/bin/remote-cli/codeoss --install-extension adacore.ada >> scripts/setup.log 2>&1; then
    echo "Failed to install Visual Studio Code extension." | tee -a scripts/setup.log
    exit 1
fi

echo "Setup completed successfully." | tee -a scripts/setup.log