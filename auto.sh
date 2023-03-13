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
for repo in "${REPOS[@]}"
do
  repo_name=$(basename "$repo" .git)
  if [ ! -d "$DOWNLOAD_DIR/$repo_name" ]; then
    cd "$DOWNLOAD_DIR"
    git clone "$repo" --quiet --depth 1
  else
    cd "$DOWNLOAD_DIR/$repo_name"
    git fetch --all --prune --quiet
    git reset --hard origin/master --quiet
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
