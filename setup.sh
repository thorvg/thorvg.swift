#!/bin/bash

# Update submodules
echo "Updating submodules..."
git submodule update --init --recursive

# Run the copy_config.sh script to copy the config.h file
echo "Setting up config files..."
./copy_config.sh

echo "Setup complete. 🎉"