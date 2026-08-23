# Google Cloud Shell Software Installation
#   - CS always provides x86_64 Debian Linux environment
#   - Software installation is not preserved, only the file system. This script must be run on every boot.
#   - CS has no mechanism to launch a script automatically, manual interventions is required.
#   - This script must be run with system administrator privileges
#

# Install system dependencies required for building and unpacking Ada tooling

apt-get update
apt-get install -y --no-install-recommends build-essential gnat gprbuild

# Install the correct Alire package for this environment

alr_latest=$(curl -sL https://api.github.com/repos/alire-project/alire/releases/latest | jq -r .tag_name)
curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-x86_64-linux.zip"
unzip alr-${alr_latest#v}-bin-x86_64-linux.zip
mv ./bin/alr /usr/local/bin/alr
rm -rf ./bin

# Add VS Code extensions (if they are not alreay there)

/google/devshell/editor/code-oss-for-cloud-shell/bin/codeoss-cloudshell --install-extension adacore.ada

# Kill the actual Google CS window

# pkill -9 -f -- '^-bash$'