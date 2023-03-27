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

# Create the push_custom_changes.sh script in the installation directory
cat > "${install_dir}/${script_name}" << 'EOF'
#!/bin/bash

usage() {
  echo "Usage: $0 <repository-url> <branch> <commit-message>"
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

repo_url="$1"
branch="$2"
commit_msg="$3"

# Clone the specified repository and branch to a temporary directory
temp_dir=$(mktemp -d)
git clone --branch "$branch" "$repo_url" "$temp_dir"

# Change the directory to the cloned repository
cd "$temp_dir"

# Check if there are any changes in the custom files
if [ -n "$(git status --porcelain)" ]; then
  echo "Changes detected in custom files."

  # Add all the changed files to the staging area
  git add -A

  # Commit the changes with the specified commit message
  git commit -m "$commit_msg"

  # Push the changes to the remote repository and specified branch
  git push origin "$branch"

  # Print the commit log
  echo "Commit log:"
  git log -1 --oneline
else
  echo "No changes detected in custom files."
fi

# Cleanup: Remove the temporary directory
cd ..
rm -rf "$temp_dir"
EOF

# Make the installed script executable
chmod +x "${install_dir}/${script_name}"

echo "The push_custom_changes tool has been installed successfully."
echo "You can now use it by running 'push_custom_changes <repository-url> <branch> <commit-message>'."
