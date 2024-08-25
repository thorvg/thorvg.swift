#!/bin/bash

# Define the source and destination paths
SOURCE_PATH="config.h"
DESTINATION_DIR="thorvg/src/renderer"
DESTINATION_PATH="$DESTINATION_DIR/config.h"

# Ensure the destination directory exists
mkdir -p "$DESTINATION_DIR"

# Remove any existing config.h file at the destination
rm -f "$DESTINATION_PATH"

# Copy the config.h file to the destination
cp "$SOURCE_PATH" "$DESTINATION_PATH"

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "Successfully copied $SOURCE_PATH to $DESTINATION_PATH."
else
    echo "Failed to copy $SOURCE_PATH to $DESTINATION_PATH."
    exit 1
fi
