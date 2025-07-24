#!/bin/bash

# add-devcontainer.sh - Add Python dev container to any repository
# Usage: ./add-devcontainer.sh /path/to/target/repo [template-name]

set -e

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/.devcontainer"
DEFAULT_TEMPLATE="python"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <target-directory> [template-name]"
    echo ""
    echo "Arguments:"
    echo "  target-directory    Path to the repository where you want to add the dev container"
    echo "  template-name       Template to use (default: python)"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/my-project"
    echo "  $0 /path/to/my-project python"
    echo "  $0 . # Add to current directory"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Missing required argument: target directory"
    show_usage
    exit 1
fi

TARGET_DIR="$1"
TEMPLATE_NAME="${2:-$DEFAULT_TEMPLATE}"

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TARGET_DEVCONTAINER_DIR="$TARGET_DIR/.devcontainer"

print_status "Adding dev container to: $TARGET_DIR"

# Check if .devcontainer already exists
if [ -d "$TARGET_DEVCONTAINER_DIR" ]; then
    print_warning ".devcontainer directory already exists in target"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Aborted by user"
        exit 0
    fi
    rm -rf "$TARGET_DEVCONTAINER_DIR"
fi

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    print_error "Template directory not found: $TEMPLATE_DIR"
    exit 1
fi

print_status "Copying dev container template..."

# Copy the entire .devcontainer directory
cp -r "$TEMPLATE_DIR" "$TARGET_DEVCONTAINER_DIR"

print_status "Customizing for target repository..."

# Get the repository name for container naming
REPO_NAME="$(basename "$TARGET_DIR")"
CONTAINER_NAME="${REPO_NAME,,}-dev-container"  # Convert to lowercase

# Update container name in docker-compose.yml
if [ -f "$TARGET_DEVCONTAINER_DIR/docker-compose.yml" ]; then
    sed -i "s/python-dev-container/$CONTAINER_NAME/g" "$TARGET_DEVCONTAINER_DIR/docker-compose.yml"
    print_status "Updated container name to: $CONTAINER_NAME"
fi

# Create a basic requirements.txt if it doesn't exist
if [ ! -f "$TARGET_DIR/requirements.txt" ]; then
    print_status "Creating basic requirements.txt..."
    cat > "$TARGET_DIR/requirements.txt" << EOF
# Add your Python dependencies here
# Example:
# requests>=2.28.0
# pandas>=1.5.0
# numpy>=1.21.0
EOF
fi

# Create .gitignore entries for dev container (if .gitignore exists)
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q ".devcontainer" "$TARGET_DIR/.gitignore"; then
        print_status "Adding dev container entries to .gitignore..."
        cat >> "$TARGET_DIR/.gitignore" << EOF

# Dev container logs and cache
.devcontainer/.env
.devcontainer/docker-compose.override.yml
EOF
    fi
fi

# Create a project-specific README section
README_SECTION="
## Development Environment

This project uses a dev container for consistent development environment setup.

### Prerequisites
- Docker
- Visual Studio Code with Dev Containers extension

### Getting Started
1. Open this repository in VS Code
2. When prompted, click \"Reopen in Container\" or use Ctrl+Shift+P and select \"Dev Containers: Reopen in Container\"
3. Wait for the container to build (first time may take a few minutes)
4. Start developing!

### Container Features
- Python 3.11 with data science and cybersecurity tools
- Jupyter Lab available on port 8888
- Pre-installed packages for data analysis and security research
- Persistent volumes for pip cache and VS Code extensions

### Manual Container Commands
\`\`\`bash
# Build the container
docker compose -f .devcontainer/docker-compose.yml build

# Start the container
docker compose -f .devcontainer/docker-compose.yml up -d

# Access the container shell
docker compose -f .devcontainer/docker-compose.yml exec python-dev bash
\`\`\`
"

# Offer to add README section
if [ -f "$TARGET_DIR/README.md" ]; then
    print_warning "README.md already exists"
    read -p "Do you want to append dev container instructions to README.md? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$README_SECTION" >> "$TARGET_DIR/README.md"
        print_success "Added dev container section to README.md"
    fi
else
    print_status "Creating README.md with dev container instructions..."
    echo "# $(basename "$TARGET_DIR")" > "$TARGET_DIR/README.md"
    echo "$README_SECTION" >> "$TARGET_DIR/README.md"
fi

print_success "Dev container successfully added to $TARGET_DIR"
print_status "Next steps:"
echo "  1. Open the repository in VS Code"
echo "  2. Install the Dev Containers extension if not already installed"
echo "  3. Click 'Reopen in Container' when prompted"
echo "  4. Customize .devcontainer/requirements.txt for your project needs"

print_status "Happy coding! 🚀"
