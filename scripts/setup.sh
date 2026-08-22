# Cloud Shell Setup Script
#

# Install system dependencies required for building and unpacking Ada tooling

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    jq \
    unzip \
    gnat \
    gprbuild \
    ca-certificates
rm -rf /var/lib/apt/lists/*

# Install the correct Alire package for this environment

alr_latest=$(curl -sL https://api.github.com/repos/alire-project/alire/releases/latest | jq -r .tag_name)
curl -L -o vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
dpkg -i vscode.deb || apt-get install -y --fix-broken
rm vscode.deb
curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-x86_64-linux.zip"
unzip alr-${alr_latest#v}-bin-x86_64-linux.zip
mv ./bin/alr /usr/local/bin/alr
rm -rf ./bin