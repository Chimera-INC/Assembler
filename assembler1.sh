#!/bin/bash

# Get the current directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Define the directory where the repositories will be downloaded
DOWNLOAD_DIR="$DIR/github-repos"

# Create the directory if it doesn't exist
if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir "$DOWNLOAD_DIR"
fi

# Define an array of GitHub repositories to download
REPOS=(
  "https://github.com/Chimera-INC/mods"
  "https://github.com/Chimera-INC/config"
  "https://github.com/Chimera-INC/Assembler"
)

# Loop through the array and clone each repository
for REPO_URL in "${REPOS[@]}"
do
  REPO_NAME=$(basename "${REPO_URL}" .git)
  # Prompt the user to download the repository
  read -p "Do you want to download '${REPO_NAME}'? [y/n]: " CHOICE

  # If the user chooses yes, clone the repository into the destination folder
  if [[ "${CHOICE}" =~ ^[Yy]$ ]]
  then
    cd "$DOWNLOAD_DIR"
    #git clone "$repo"
    git clone "$REPOS" -q
  else
    cd "$DOWNLOAD_DIR/$REPOS"
    #git pull
    git pull -q
  fi
done

# Move the downloaded repositories to the script directory
if [ "$(ls -A $DOWNLOAD_DIR)" ]; then
  rsync -a "$DOWNLOAD_DIR"/ "$DIR"
fi
rm -f -r "$DOWNLOAD_DIR"

# Remove .git folders from downloaded repositories
find "$DIR" -name ".git" -exec rm -rf {} \;
find "$DIR" -name "README.md" -exec rm -rf {} \;
