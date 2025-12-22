#/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TARGET_DIR="${1:-${HOME}/dotfiles/}"

echo -e "${GREEN}dotfiles will be stored under ${TARGET_DIR}${NC}"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

clone() {
  if ! command_exists git; then
    echo -e "${RED}git not installed...${NC}"
    return 1
  fi
  

  if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}${TARGET_DIR} already exists ...${NC}"
    return 1
  fi

  git clone --recursive https://github.com/stefanbildl/dotfiles.git "$TARGET_DIR"
}

if ! clone; then
  echo -e "${RED}could not clone repo...${NC}"
  exit 1
fi

current_dir=$(pwd)
echo -e "changing to target directory"
cd $TARGET_DIR

./install.sh
if [ ! "$?" ]; then
  echo -e "${RED}Installation failed$NC"
  cd $current_dir
  exit 1
fi


echo -e "changing back to initial directory"
cd $current_dir
exit 0
