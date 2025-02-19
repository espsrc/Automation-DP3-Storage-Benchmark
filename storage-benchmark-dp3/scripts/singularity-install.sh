#!/bin/bash
# Install singularity on Debian or Fedora written by Babatunde Oyewo
go_workspace=~/go_workspace
singularity_install_debian() {
    cd ~
    echo "Updating Software..."
    sudo apt-get update -y
    echo "installing build essentials..."
    sudo apt-get install build-essential -y

    sudo apt-get install -y \
        autoconf \
        automake \
        cryptsetup \
        fuse \
        fuse2fs \
        git \
        libfuse-dev \
        libglib2.0-dev \
        libseccomp-dev \
        libtool \
        pkg-config \
        runc \
        squashfs-tools \
        uidmap \
        wget \
        zlib1g-dev

    echo "updating ..."
    sudo apt-get update -y
    echo "installing squashfs-tools-ng.."
    git clone https://github.com/AgentD/squashfs-tools-ng.git
    cd squashfs-tools-ng
    ./autogen.sh
    ./configure
    sudo apt-get install autoconf automake libtool
    make
    sudo make install
    
    if [[ $? -eq 0 ]]; then
      echo "squashfs-tools-ng installed correctly"
    else
      echo "squashfs-tools-ng did not install correctly"
    exit 1
    fi
    cd ~
    echo "Downloading Go..."
    wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
    echo "extracting go..."
    sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
    if [[ $? -eq 0 ]]; then
      echo "Go extracted successfully"
    else
      echo "Go did not extract successfully"
      exit 1
    fi

    echo "Creating go workspace..."
    if [[ ! -d "$go_workspace" ]]; then
        echo "Folder $go_workspace does not exit creating it..."
        mkdir -p "$go_workspace"
    echo "Folder $go_workspace created successfully"
    else
      echo "Folder $go_workspace already exits continuing.."
    fi

    echo "Updating bashrc file..."

    lines_to_add=(
        "export PATH=\$PATH:/usr/local/go/bin"
        "export GOPATH=~/go_workspace"
        "export PATH=\$PATH:\$GOPATH/bin"
        "export PATH=\$PATH:/usr/local/bin"
    )

    for line in "${lines_to_add[@]}"; do
        if ! grep -qxF "$line" ~/.bashrc; then
            echo "$line" >> ~/.bashrc
            echo "Added '$line' to ~/.bashrc"
        else
            echo "'$line' already in ~/.bashrc"
        fi 
    done

    # Source the .bashrc file or directly export the variables for the current session
    for line in "${lines_to_add[@]}"; do
        eval "$line"
    done

    # # check go version
    go version



    # if [[ $? -eq 0 ]]; then
    #   echo "Go installed correctly"
    # else
    #   echo "Go did not install correctly" 
    #   exit 1
    # fi 

        # Verify that Go is installed and accessible
    if ! command -v go &> /dev/null; then
        echo "Go is not installed or not found in PATH"
        exit 1
    fi


    echo "Installing Singularity..."
    cd ~
    git clone --recurse-submodules https://github.com/sylabs/singularity.git
    cd singularity
    git submodule update --init --recursive
    echo "Running mconfig..."
    ./mconfig
    cd builddir/
    make
    sudo make install

    singularity --version
    if [[ $? -eq 0 ]]; then
        echo "Singularity installed successfully"
    else
        echo "Singularity did not install correctly"
        exit 1
    fi

    # clean up 
echo "Cleaning up..."
    cd ~
    rm -rf singularity
    rm -rf squashfs-tools-ng
    rm -f go1.22.5.linux-amd64.tar.gz
}

singularity_install_fedora()
{
    cd ~
    echo "Updating Software..."
    sudo dnf update -y
    # Install basic tools for compiling
    sudo dnf groupinstall -y 'Development Tools'
    # Install RPM packages for dependencies
    sudo dnf install -y \
    autoconf \
    automake \
    crun \
    cryptsetup \
    fuse \
    fuse3 \
    fuse3-devel \
    git \
    glib2-devel \
    libseccomp-devel \
    libtool \
    squashfs-tools \
    wget \
    zlib-devel

    echo "Downloading Go..."
    wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
    echo "extracting go..."
    sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
    if [[ $? -eq 0 ]]; then
      echo "Go extracted successfully"
    else
      echo "Go did not extract successfully"
      exit 1
    fi

    echo "Creating go workspace..."
    if [[ ! -d "$go_workspace" ]]; then
        echo "Folder $go_workspace does not exit creating it..."
        mkdir -p "$go_workspace"
    echo "Folder $go_workspace created successfully"
    else
      echo "Folder $go_workspace already exits continuing.."
    fi

    echo "Updating bashrc file..."

    lines_to_add=(
        "export PATH=\$PATH:/usr/local/go/bin"
        "export GOPATH=~/go_workspace"
        "export PATH=\$PATH:\$GOPATH/bin"
        "export PATH=\$PATH:/usr/local/bin"
    )
    for line in "${lines_to_add[@]}"; do
        if ! grep -qxF "$line" ~/.bashrc; then
            echo "$line" >> ~/.bashrc
            echo "Added '$line' to ~/.bashrc"
        else
            echo "'$line' already in ~/.bashrc"
        fi 
    done

    # Source the .bashrc file 
    for line in "${lines_to_add[@]}"; do
        eval "$line"
    done

    # # check go version
    go version

        # Verify that Go is installed and accessible
    if ! command -v go &> /dev/null; then
        echo "Go is not installed or not found in PATH"
        exit 1
    fi
    echo "Installing Singularity..."
    cd ~
    git clone --recurse-submodules https://github.com/sylabs/singularity.git
    cd singularity
    git submodule update --init --recursive
    echo "Running mconfig..."
    ./mconfig
    cd builddir/
    make
    sudo make install

    if ! sudo grep -q "^Defaults secure_path" /etc/sudoers; then
      echo "Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin" | sudo tee -a /etc/sudoers > /dev/null
    fi

    if ! sudo grep -q '^Defaults env_keep += "PATH"' /etc/sudoers; then
      echo 'Defaults env_keep += "PATH"' | sudo tee -a /etc/sudoers > /dev/null
    fi

    singularity --version
    if [[ $? -eq 0 ]]; then
        echo "Singularity installed successfully"
    else
        echo "Singularity did not install correctly"
        exit 1
    fi

    # clean up 
echo "Cleaning up..."
    cd ~
    rm -rf singularity
    rm -rf squashfs-tools-ng
    rm -f go1.22.5.linux-amd64.tar.gz

}



    if [ ! -f /etc/os-release ]; then
    echo "OS-release file not found"
    exit 1
    fi
    os_name=$(grep -oP '^ID_LIKE=\K.*' /etc/os-release)
    echo $os_name

    # check the os type
    if [[ "$os_name" == *"debian"* ]]; then
    echo "The OS family is Debian"
    singularity_install_debian
    elif [[ "$os_name" == *"rhel"* || "$os_name" == *"fedora"* ]]; then
    echo "The OS family is rhel fedora"
    singularity_install_fedora
    else
    echo "The OS family is not debian or rhel fedora: $os_name"
    fi