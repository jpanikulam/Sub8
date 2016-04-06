GOODCOLOR='\033[1;36m'
WARNCOLOR='\e[31m'
NC='\033[0m' # No Color
GOODPREFIX="${GOODCOLOR}INSTALLER:"
WARNPREFIX="${WARNCOLOR}INSTALLER:"

instlog() {
    printf "$GOODPREFIX $@ $NC\n"
}

instwarn() {
    printf "$WARNPREFIX $@ $NC\n"
}

ros_git_get() {
    # Check if it already exists
    # ex: ros_git_get git@github.com:jpanikulam/ROS-Boat.git
    # Also checks https automatically!

    NEEDS_INSTALL=true;
    INSTALL_URL=$1;
    builtin cd $INSTALL_FOLDER
    for folder in "$INSTALL_FOLDER"/*; do
        if ! [ -d $folder ]; then
            continue;
        fi

        builtin cd $folder
        if ! [ -d .git ]; then
            # instlog "$folder not a git repository"
            continue;
        fi
        LOCAL_BRANCH=`git name-rev --name-only HEAD`
        TRACKING_BRANCH=`git config branch.$LOCAL_BRANCH.merge`
        TRACKING_REMOTE=`git config branch.$LOCAL_BRANCH.remote`
        REMOTE_URL=`git config remote.$TRACKING_REMOTE.url`
        if python -c "import re; _, have_url = re.split('https://github.com|git@github.com:', '$REMOTE_URL');_, want_url = re.split('https://github.com|git@github.com:', '$INSTALL_URL'); exit(have_url != want_url)"; then
            instlog "Already have package at url $INSTALL_URL"
            NEEDS_INSTALL=false;
            break;
        fi
        builtin cd $INSTALL_FOLDER
    done
    if $NEEDS_INSTALL; then
        instlog "Installing $INSTALL_URL in $INSTALL_FOLDER"
        git clone -q $INSTALL_URL --depth=1
    fi
}

python_from_git() {
    # ex: python_from_git https://github.com/noamraph/tqdm.git tqdm
    # 3rd argument is path to setup.py
    # ex: python_from_git https://github.com/txros/txros.git txros txros/txros
    PKG_URL=$1
    PKG_NAME=$2
    if [ $# -lt 3 ]; then
        SETUP_PATH="$PKG_NAME"
    else
        SETUP_PATH=$3
    fi
    if pip freeze | grep -i $PKG_NAME; then
        instlog "Already have python package $PKG_NAME"
        return
    else
        instlog "Installing package $PKG_NAME"
    fi

    cd $DEPS_DIR
    git clone -q $PKG_URL
    cd $SETUP_PATH
    if [ $# -eq 4 ]; then
        COMMIT=$4
        git checkout $COMMIT
    fi
    sudo python setup.py install
}