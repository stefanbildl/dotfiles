#!/usr/bin/env bash
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install() {
  if command_exists "$1"; then
    echo -e "${GREEN}$1 is already installed.${NC}"
    return 0
  fi

  if command_exists "apt-get"; then
    # Debian/Ubuntu-based systems
    sudo apt-get update
    sudo apt-get install -y "$1"
  elif command_exists "brew"; then
    # macOS with Homebrew
    brew install "$1"
  elif command_exists "pacman"; then
    # Arch-based systems
    sudo pacman -S --noconfirm "$1"
  elif command_exists "dnf"; then
    # Fedora-based systems
    sudo dnf install -y "$1"
  elif command_exists "zypper"; then
    # openSUSE-based systems
    sudo zypper install -y "$1"
  else
    echo -e "${RED}Could not detect a supported package manager. Please install stow manually.${NC}"
    return 1
  fi

  if ! command_exists "$1"; then
    echo -e "${RED}Failed to install $1 via package manager.${NC}"
    return 1
  fi

  return 0
}


install_zellij() {
  if command_exists zellij; then
    echo -e "${GREEN}zellij is already installed.${NC}"
    return 0
  fi

  # try to install zellij with package manager
  if install zellij; then
    return 0
  fi

  echo -e "${YELLOW}Install via package manager failed - installing zellij via script...${NC}"
  # Get the architecture of the machine
  arch=$(uname -m)
  os=$(uname -s)

  # Download the Zellij binary
  if [ "$os" == "Darwin" ]; then
    filename="zellij-${arch}-apple-darwin.tar.gz"
    url="https://github.com/zellij-org/zellij/releases/latest/download/$filename"
    echo "Downloading Zellij binary for macOS..."
    curl -LO "$url"
  else
    if [ "$os" == "Linux" ]; then
      filename="zellij-${arch}-unknown-linux-musl.tar.gz"
      url="https://github.com/zellij-org/zellij/releases/latest/download/$filename"
      echo "Downloading Zellij binary for Linux..."
      curl -LO "$url"
    else
      echo "Unsupported OS: $os"
    fi
  fi

  # Uncompress the Zellij binary
  echo "Uncompressing Zellij binary..."
  mkdir -p zellij_download
  tar -xf "$filename" -C zellij_download
  target="./zellij_download/zellij"

  # Move the Zellij binary to the /bin directory
  echo "Moving Zellij binary to /bin directory..."

  sudo rm -rf /opt/zellij
  sudo mkdir -p /opt/zellij/
  chmod +x "$target"
  sudo mv "$target" /opt/zellij/
  rm /bin/zellij
  sudo ln -s /opt/zellij/zellij /bin/zellij

  # Remove the .tar.gz file
  echo "Removing .tar.gz file..."
  rm "$filename"

  # Check if the Zellij binary exists
  if [ -f "/bin/zellij" ]; then
    echo "Zellij binary installed successfully!"
  else
    echo "Zellij binary not installed successfully!"
  fi
}

# Function to apply all stow modules
apply_stow_modules() {
  echo -e "${YELLOW}Applying stow modules...${NC}"
  # Change to the directory where this script is located
  cd "$(dirname "${BASH_SOURCE[0]}")" || { echo -e "${RED}Failed to change to script directory.${NC}"; exit 1; }

  # Find all directories (modules) in the current directory, excluding hidden files and the script itself
  for module in */; do
    if [ -d "$module" ]; then
      echo -e "${GREEN}Applying module: $module${NC}"
      stow --adopt -v "$module"  || { echo -e "${RED}Failed to apply module: $module${NC}"; }
    fi
  done

  echo -e "${GREEN}All stow modules applied successfully!${NC}"
}


install_fish() {
  set -e
  install fish
  if [ "$SHELL" == "/bin/fish" ]; then
    echo -e "${GREEN}fish 🐟 is already your default shell...${NC}"
    return 0
  fi

  if [ "$SHELL" == "$(which fish)" ]; then
    echo -e "${GREEN}fish 🐟 is already your default shell...${NC}"
    return 0
  fi

  echo -e "${YELLOW}changing your shell to fish 🐟...${NC}"
  sudo chsh -s "$(which fish)" "$USER"
}

prepare_git() {
  set -e
  install git
  # ensure git submodules are setup correctly
  git submodule init
  git submodule update
}

install_starship() {
  if ! command_exists starship; then 
    curl -sS https://starship.rs/install.sh | sh
  else
    echo -e "${GREEN}starship is already installed.${NC}"
  fi
}

install_eza() {
  if command_exists eza; then
    echo -e "${GREEN}eza is already installed.${NC}"
    return 0
  fi

  if command_exists pacman; then
    sudo pacman -S --noconfirm eza
    return
  fi

  echo -e "${YELLOW}Installing eza...${NC}"
  set -e

  arch=$(uname -m)
  wget -c https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-unknown-linux-gnu.tar.gz -O - | tar xz
  sudo chmod +x eza
  sudo chown root:root eza
  sudo mv eza /usr/local/bin/eza
}

# Main script logic
main() {
  if ! install wget; then exit 1; fi

  if ! prepare_git; then 
    echo "${RED}initialization failed for this repo...$NC"
    exit 1
  fi

  if ! install fzf; then 
    echo "${RED}fzf could not be installed...$NC"
    exit 1
  fi

  if ! install_eza; then 
    echo "${RED}eza could not be installed...$NC"
    exit 1
  fi

  if ! install_fish; then
    echo "${RED}fish could not be installed...$NC"
    exit 1
  fi

  if ! install_starship; then
    echo "${RED}starship could not be installed...$NC"
    exit 1
  fi

  if ! install_zellij; then
    echo "${RED}zellij could not be installed...$NC"
    exit 1
  fi

  if ! install zoxide; then
    echo "${RED}zoxide could not be installed...$NC"
    exit 1
  fi

  if install stow; then
    apply_stow_modules
  fi
}

# Run the script
main
