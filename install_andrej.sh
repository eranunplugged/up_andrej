#!/bin/bash

# Define the installation directory and the script name
install_dir="/usr/local/bin"
script_name="andrej"

# Check if the current user has write permissions to the installation directory
if [ ! -w "$install_dir" ]; then
  echo "Error: You do not have write permissions to the installation directory ($install_dir)."
  echo "Please run this script with sudo or as a user with the necessary permissions."
  exit 1
fi

# Create the push_changes script in the installation directory
cat > "${install_dir}/${script_name}" << 'EOF'
#!/bin/bash

usage() {
  echo "Usage: $0 <local-source-dir> <destination-repo-url> <destination-branch> <commit-message>"
  echo "If <local-source-dir> is empty, the current directory will be used."
  exit 1
}

if [ $# -ne 4 ]; then
  usage
fi

source_dir="$1"
dest_repo="$2"
dest_branch="$3"
commit_msg="$4"

# Use the current directory if the source_dir is empty
if [ -z "$source_dir" ]; then
  source_dir=$(pwd)
fi

# Clone the destination repository and specified branch to a temporary directory
temp_dest_dir=$(mktemp -d)
git clone --branch "$dest_branch" "$dest_repo" "$temp_dest_dir"

# Copy the changes and new files from the source directory to the destination repository
cp -rT "$source_dir/" "$temp_dest_dir/"

# Change the directory to the destination repository
cd "$temp_dest_dir"

# Check if there are any changes in the custom files
if [ -n "$(git status --porcelain)" ]; then
  echo "Changes detected in custom files."

  # Add all the changed files to the staging area
  git add -A

  # Commit the changes with the specified commit message
  git commit -m "$commit_msg"

  # Push the changes to the remote destination repository and specified branch
  git push origin "$dest_branch"

  # Print the commit log
  echo "Commit log:"
  git log -1 --oneline
else
  echo "No changes detected in custom files."
fi

# Cleanup: Remove the temporary directory
rm -rf "$temp_dest_dir"
EOF

# Make the installed script executable
chmod +x "${install_dir}/${script_name}"

echo "The andrej tool has been installed successfully."
echo "You can now use it by running 'andrej <local-source-dir> <destination-repo-url> <destination-branch> <commit-message>'."
