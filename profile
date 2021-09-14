# XDG - set defaults as they may not be set
# See https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# and https://wiki.archlinux.org/index.php/XDG_Base_Directory_support
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
export PATH=$PATH;$XDB_BIN_HOME

if [ ! -w ${XDG_RUNTIME_DIR:="/run/user/$UID"} ]; then
    echo "\$XDG_RUNTIME_DIR ($XDG_RUNTIME_DIR) not writable. Unsetting." >&2
    unset XDG_RUNTIME_DIR
else
    export XDG_RUNTIME_DIR
fi

# XDG: aws-cli
# https://archlinux.org/packages/?name=aws-cli
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config

# XGD: azure-cli
# https://aur.archlinux.org/packages/python-azure-cli/
export AZURE_CONFIG_DIR=$XDG_DATA_HOME/azure

# XDG: rust cargo
# https://wiki.archlinux.org/title/Rust#Cargo
export CARGO_HOME="$XDG_DATA_HOME"/cargo

# XDG: docker
# https://wiki.archlinux.org/title/Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

# XDG: go
# https://wiki.archlinux.org/title/Go
# export GOPATH="$XDG_DATA_HOME"/go

# XDG: jupyter
# https://wiki.archlinux.org/title/Jupyter
# export IPYTHONDIR="$XDG_CONFIG_HOME"/jupyter
# export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter

# XDG: terraform
# https://www.terraform.io/docs/cli/config/environment-variables.html
# https://www.terraform.io/docs/cli/config/config-file.html
# https://www.terraform.io/docs/cli/config/config-file.html#provider-plugin-cache
export TF_LOG_PATH="$XDG_CACHE_HOME"/terraform/terraform.log
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME"/terraform/terraformrc
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME"/terraform/plugin-cache

# XDG: vim
# https://wiki.archlinux.org/title/XDG_Base_Directory
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'

# XDG: inputrc
ln -s $XDG_CONFIG_HOME/inputrc $HOME/.inputrc


# iterm2 TMUX
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES

# Enable mouse scrolling in less
export LESS='--mouse --wheel-lines=3'
