#!/usr/bin/env bash

ARCH=$(uname -m)
case $ARCH in
  x86_64)
    APPIMAGE="nvim-linux-x86_64.appimage"
    ;;
  aarch64)
    APPIMAGE="nvim-linux-arm64.appimage"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

curl -LO "https://github.com/neovim/neovim/releases/latest/download/$APPIMAGE"
chmod +x "$APPIMAGE"
sudo cp "$APPIMAGE" /bin/nvim
