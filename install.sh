#!/bin/bash

# Script to install stow and apply all stow modules in the dotfiles repo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install stow
install_stow() {
  echo -e "${YELLOW}Installing stow...${NC}"

  if command_exists "apt-get"; then
    # Debian/Ubuntu-based systems
    sudo apt-get update
    sudo apt-get install -y stow
  elif command_exists "brew"; then
    # macOS with Homebrew
    brew install stow
  elif command_exists "pacman"; then
    # Arch-based systems
    sudo pacman -S --noconfirm stow
  elif command_exists "dnf"; then
    # Fedora-based systems
    sudo dnf install -y stow
  elif command_exists "zypper"; then
    # openSUSE-based systems
    sudo zypper install -y stow
  else
    echo -e "${RED}Could not detect a supported package manager. Please install stow manually.${NC}"
    exit 1
  fi

  if ! command_exists "stow"; then
    echo -e "${RED}Failed to install stow. Please install it manually and try again.${NC}"
    exit 1
  fi

  echo -e "${GREEN}stow installed successfully!${NC}"
}

install_zellij() {
  echo -e "${YELLOW}Installing zellij...${NC}"
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
  tar -xf "$filename"

  # Move the Zellij binary to the /bin directory
  echo "Moving Zellij binary to /bin directory..."

  sudo mkdir -p /opt/zellij/
  sudo mv "./zellij" /opt/zellij/zellij
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
      stow -v "$module" --adopt || { echo -e "${RED}Failed to apply module: $module${NC}"; exit 1; }
    fi
  done

  echo -e "${GREEN}All stow modules applied successfully!${NC}"
}


# Main script logic
main() {
  # install zellij
  install_zellij

  # Check if stow is installed
  if ! command_exists "stow"; then
    install_stow
  else
    echo -e "${GREEN}stow is already installed.${NC}"
  fi

  # Apply all stow modules
  apply_stow_modules
}

# Run the script
main
