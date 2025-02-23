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

# Function to apply all stow modules
apply_stow_modules() {
  echo -e "${YELLOW}Applying stow modules...${NC}"

  # Change to the directory where this script is located
  cd "$(dirname "${BASH_SOURCE[0]}")" || { echo -e "${RED}Failed to change to script directory.${NC}"; exit 1; }

  # Find all directories (modules) in the current directory, excluding hidden files and the script itself
  for module in */; do
    if [ -d "$module" ]; then
      echo -e "${GREEN}Applying module: $module${NC}"
      stow -v "$module" || { echo -e "${RED}Failed to apply module: $module${NC}"; exit 1; }
    fi
  done

  echo -e "${GREEN}All stow modules applied successfully!${NC}"
}

# Main script logic
main() {
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
