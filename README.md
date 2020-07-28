# Bytepath Clone

Follows [this tutorial](https://github.com/a327ex/blog/issues/30)

## Setup

1. Install Love2D 10.2

    ```bash
    # download Love2D 0.10.2 and the liblove dependency (links are for x64 architecture)
    wget https://bitbucket.org/rude/love/downloads/love_0.10.2ppa1_amd64.deb
    wget https://bitbucket.org/rude/love/downloads/liblove0_0.10.2ppa1_amd64.deb

    # required dependency for liblove
    wget http://security.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1.2_amd64.deb
    sudo apt-get install ./multiarch-support_2.27-3ubuntu1.2_amd64.deb

    # install Love2D 0.10.2
    sudo apt install libphysfs1   # required dependency
    sudo apt --fix-broken install # may or may not be required
    sudo dpkg -i love_0.10.2ppa1_amd64.deb
    sudo dpkg -i liblove0_0.10.2ppa1_amd64.deb
    ```

2. Test Love

    ```bash
    # The love window should open
    love
    ```