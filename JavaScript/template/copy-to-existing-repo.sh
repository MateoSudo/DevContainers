#!/bin/bash

# T3 Stack Template Copy Script
# This script copies the T3 stack dev container setup to an existing repository

set -e

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

# Check if target directory is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <target-directory>"
    print_status "Example: $0 /path/to/your/existing/repo"
    exit 1
fi

TARGET_DIR="$1"
SOURCE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Check if target is a git repository
if [ ! -d "$TARGET_DIR/.git" ]; then
    print_warning "Target directory is not a git repository. Proceeding anyway..."
fi

print_status "Copying T3 Stack dev container to: $TARGET_DIR"
print_status "Source: $SOURCE_DIR"

# Create .devcontainer directory
print_status "Creating .devcontainer directory..."
mkdir -p "$TARGET_DIR/.devcontainer"

# Copy dev container files
print_status "Copying dev container configuration..."
cp "$SOURCE_DIR/.devcontainer/devcontainer.json" "$TARGET_DIR/.devcontainer/"
cp "$SOURCE_DIR/.devcontainer/Dockerfile" "$TARGET_DIR/.devcontainer/"
cp "$SOURCE_DIR/.devcontainer/docker-compose.yml" "$TARGET_DIR/.devcontainer/"
cp "$SOURCE_DIR/.devcontainer/.dockerignore" "$TARGET_DIR/.devcontainer/"

# Copy package.json if it doesn't exist
if [ ! -f "$TARGET_DIR/package.json" ]; then
    print_status "Copying package.json..."
    cp "$SOURCE_DIR/package.json" "$TARGET_DIR/"
else
    print_warning "package.json already exists. Check template/package.json for dependencies to add."
fi

# Copy template files
print_status "Copying template configuration files..."

# TypeScript config
if [ ! -f "$TARGET_DIR/tsconfig.json" ]; then
    cp "$SOURCE_DIR/template/tsconfig.json" "$TARGET_DIR/" 2>/dev/null || print_warning "tsconfig.json template not found"
fi

# Tailwind config
if [ ! -f "$TARGET_DIR/tailwind.config.js" ]; then
    cp "$SOURCE_DIR/template/tailwind.config.js" "$TARGET_DIR/" 2>/dev/null || print_warning "tailwind.config.js template not found"
fi

# PostCSS config
if [ ! -f "$TARGET_DIR/postcss.config.js" ]; then
    cp "$SOURCE_DIR/template/postcss.config.js" "$TARGET_DIR/" 2>/dev/null || print_warning "postcss.config.js template not found"
fi

# Next.js config
if [ ! -f "$TARGET_DIR/next.config.js" ]; then
    cp "$SOURCE_DIR/template/next.config.js" "$TARGET_DIR/" 2>/dev/null || print_warning "next.config.js template not found"
fi

# ESLint config
if [ ! -f "$TARGET_DIR/.eslintrc.json" ]; then
    cp "$SOURCE_DIR/template/.eslintrc.json" "$TARGET_DIR/" 2>/dev/null || print_warning ".eslintrc.json template not found"
fi

# Prettier config
if [ ! -f "$TARGET_DIR/.prettierrc.json" ]; then
    cp "$SOURCE_DIR/template/.prettierrc.json" "$TARGET_DIR/" 2>/dev/null || print_warning ".prettierrc.json template not found"
fi

# Environment template
if [ ! -f "$TARGET_DIR/.env.example" ]; then
    cp "$SOURCE_DIR/template/.env.example" "$TARGET_DIR/" 2>/dev/null || print_warning ".env.example template not found"
fi

# Prisma schema
if [ ! -f "$TARGET_DIR/prisma/schema.prisma" ]; then
    mkdir -p "$TARGET_DIR/prisma"
    cp "$SOURCE_DIR/template/prisma/schema.prisma" "$TARGET_DIR/prisma/" 2>/dev/null || print_warning "Prisma schema template not found"
fi

# Copy .gitignore additions
if [ -f "$SOURCE_DIR/template/.gitignore" ]; then
    if [ -f "$TARGET_DIR/.gitignore" ]; then
        print_status "Appending to existing .gitignore..."
        echo "" >> "$TARGET_DIR/.gitignore"
        echo "# T3 Stack additions" >> "$TARGET_DIR/.gitignore"
        cat "$SOURCE_DIR/template/.gitignore" >> "$TARGET_DIR/.gitignore"
    else
        cp "$SOURCE_DIR/template/.gitignore" "$TARGET_DIR/"
    fi
fi

# Create VS Code settings directory
mkdir -p "$TARGET_DIR/.vscode"

# Copy VS Code settings if they don't exist
if [ ! -f "$TARGET_DIR/.vscode/settings.json" ]; then
    cp "$SOURCE_DIR/template/.vscode/settings.json" "$TARGET_DIR/.vscode/" 2>/dev/null || print_warning "VS Code settings template not found"
else
    print_warning ".vscode/settings.json already exists. Check template/.vscode/settings.json for recommended settings."
fi

# Copy launch configuration
if [ ! -f "$TARGET_DIR/.vscode/launch.json" ]; then
    cp "$SOURCE_DIR/template/.vscode/launch.json" "$TARGET_DIR/.vscode/" 2>/dev/null || print_warning "VS Code launch.json template not found"
fi

print_success "T3 Stack dev container setup copied successfully!"

print_status "Next steps:"
echo "1. Navigate to your repository: cd \"$TARGET_DIR\""
echo "2. Open in VS Code: code ."
echo "3. When prompted, click 'Reopen in Container'"
echo "4. Copy .env.example to .env.local and configure your environment variables"
echo "5. Run: npm install (if package.json was not copied)"
echo "6. Run: npx prisma db push (to set up the database)"
echo "7. Start developing: npm run dev"

print_warning "Important notes:"
echo "- Review the copied package.json for dependencies you may need to merge"
echo "- Configure your environment variables in .env.local"
echo "- Update database URL and other settings as needed"
echo "- The dev container includes PostgreSQL and Redis services"

print_success "Happy coding with the T3 Stack! 🚀" 