#!/bin/bash

# DevContainers Setup Script
# This script allows you to set up either dev containers or virtual environments
# for Python and Java development in any repository

set -e

# Color functions for better output
print_info() {
    echo -e "\033[1;34mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[1;32m✅ $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m⚠️  $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m❌ $1\033[0m"
}

print_header() {
    echo -e "\033[1;36m$1\033[0m"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists docker; then
        missing_deps+=("docker")
    fi
    
    if ! command_exists python3; then
        missing_deps+=("python3")
    fi
    
    if ! command_exists pip3; then
        missing_deps+=("pip3")
    fi
    
    if ! command_exists java; then
        missing_deps+=("java")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        print_info "Some features may not work without these dependencies."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "All prerequisites found!"
    fi
}

# Function to setup Python environment
setup_python() {
    local env_type="$1"
    local target_dir="$2"
    
    print_header "Setting up Python $env_type environment..."
    
    if [ "$env_type" = "devcontainer" ]; then
        # Copy dev container files
        cp -r "$SCRIPT_DIR/Python/.devcontainer" "$target_dir/"
        cp "$SCRIPT_DIR/Python/requirements.txt" "$target_dir/"
        
        # Create .vscode directory if it doesn't exist
        mkdir -p "$target_dir/.vscode"
        
        # Copy VS Code settings
        if [ ! -f "$target_dir/.vscode/settings.json" ]; then
            cp "$SCRIPT_DIR/Python/.vscode/settings.json" "$target_dir/.vscode/"
        fi
        
        print_success "Python dev container setup complete!"
        print_info "Next steps:"
        echo "1. Open the repository in VS Code: code ."
        echo "2. When prompted, click 'Reopen in Container'"
        echo "3. Wait for the container to build and start"
        
    elif [ "$env_type" = "venv" ]; then
        # Create virtual environment
        cd "$target_dir"
        python3 -m venv .venv
        
        # Activate virtual environment and install packages
        source .venv/bin/activate
        pip install --upgrade pip
        pip install -r "$SCRIPT_DIR/Python/requirements.txt"
        
        # Create .vscode directory and settings
        mkdir -p .vscode
        cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./.venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.sortImports.args": ["--profile", "black"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": "explicit"
    }
}
EOF
        
        print_success "Python virtual environment setup complete!"
        print_info "Next steps:"
        echo "1. Activate the virtual environment: source .venv/bin/activate"
        echo "2. Open in VS Code: code ."
        echo "3. VS Code should automatically detect the virtual environment"
        
    else
        print_error "Invalid environment type: $env_type"
        exit 1
    fi
}

# Function to setup Java environment
setup_java() {
    local env_type="$1"
    local target_dir="$2"
    
    print_header "Setting up Java JDK 21 FX $env_type environment..."
    
    if [ "$env_type" = "devcontainer" ]; then
        # Copy dev container files
        cp -r "$SCRIPT_DIR/Java/.devcontainer" "$target_dir/"
        cp "$SCRIPT_DIR/Java/pom.xml" "$target_dir/"
        
        # Create .vscode directory if it doesn't exist
        mkdir -p "$target_dir/.vscode"
        
        # Copy VS Code settings
        if [ ! -f "$target_dir/.vscode/settings.json" ]; then
            cp "$SCRIPT_DIR/Java/.vscode/settings.json" "$target_dir/.vscode/"
        fi
        
        print_success "Java dev container setup complete!"
        print_info "Next steps:"
        echo "1. Open the repository in VS Code: code ."
        echo "2. When prompted, click 'Reopen in Container'"
        echo "3. Wait for the container to build and start"
        
    elif [ "$env_type" = "local" ]; then
        # Check if Java 21 is installed locally
        if ! command_exists java; then
            print_error "Java is not installed. Please install OpenJDK 21 first."
            print_info "On Ubuntu/Debian: sudo apt install openjdk-21-jdk"
            print_info "On macOS: brew install openjdk@21"
            exit 1
        fi
        
        # Check Java version
        local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$java_version" -lt 21 ]; then
            print_warning "Java version $java_version detected. Java 21 is recommended."
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        
        # Copy Maven configuration
        cp "$SCRIPT_DIR/Java/pom.xml" "$target_dir/"
        
        # Create .vscode directory and settings
        mkdir -p .vscode
        cat > .vscode/settings.json << 'EOF'
{
    "java.home": "/usr/lib/jvm/java-21-openjdk-amd64",
    "java.configuration.updateBuildConfiguration": "automatic",
    "java.compile.nullAnalysis.mode": "automatic",
    "java.format.settings.url": "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
    "java.format.settings.profile": "GoogleStyle",
    "java.saveActions.organizeImports": true,
    "java.cleanup.actionsOnSave": ["qualifyStaticMembers", "qualifyMembers", "addOverride", "addDeprecated", "stringConcatenation", "unnecessaryThis", "unnecessaryNlsTag", "unnecessaryCast", "unnecessarySemicolon", "removeTrailingWhitespace", "insertInferredTypeArguments", "insertMissingOverrideAnnotation", "insertMissingDeprecatedAnnotation"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": "explicit"
    }
}
EOF
        
        print_success "Java local environment setup complete!"
        print_info "Next steps:"
        echo "1. Install VS Code Java extensions if not already installed"
        echo "2. Open in VS Code: code ."
        echo "3. VS Code should automatically detect Java and Maven"
        
    else
        print_error "Invalid environment type: $env_type"
        exit 1
    fi
}

# Function to setup JavaScript/Next.js environment
setup_javascript() {
    local env_type="$1"
    local target_dir="$2"
    
    print_header "Setting up JavaScript/Next.js T3 Stack $env_type environment..."
    
    if [ "$env_type" = "devcontainer" ]; then
        # Copy dev container files
        cp -r "$SCRIPT_DIR/JavaScript/.devcontainer" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/package.json" "$target_dir/"
        
        # Create .vscode directory if it doesn't exist
        mkdir -p "$target_dir/.vscode"
        
        # Copy VS Code settings
        if [ ! -f "$target_dir/.vscode/settings.json" ]; then
            cp "$SCRIPT_DIR/JavaScript/.vscode/settings.json" "$target_dir/.vscode/"
        fi
        
        print_success "JavaScript/Next.js dev container setup complete!"
        print_info "Next steps:"
        echo "1. Open the repository in VS Code: code ."
        echo "2. When prompted, click 'Reopen in Container'"
        echo "3. Wait for the container to build and start"
        
    elif [ "$env_type" = "local" ]; then
        # Check if Node.js is installed locally
        if ! command_exists node; then
            print_error "Node.js is not installed. Please install Node.js 18+ first."
            print_info "On Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
            print_info "On macOS: brew install node@18"
            print_info "Or download from: https://nodejs.org/"
            exit 1
        fi
        
        # Check Node.js version
        local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -lt 18 ]; then
            print_warning "Node.js version $node_version detected. Node.js 18+ is recommended."
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        
        # Copy package.json and other config files
        cp "$SCRIPT_DIR/JavaScript/package.json" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/tsconfig.json" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/next.config.js" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/tailwind.config.js" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/postcss.config.js" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/.eslintrc.json" "$target_dir/"
        cp "$SCRIPT_DIR/JavaScript/.prettierrc.json" "$target_dir/"
        
        # Create directories
        mkdir -p "$target_dir/src"
        mkdir -p "$target_dir/prisma"
        
        # Copy Prisma schema
        cp "$SCRIPT_DIR/JavaScript/prisma/schema.prisma" "$target_dir/prisma/"
        
        # Create .vscode directory and settings
        mkdir -p .vscode
        cat > .vscode/settings.json << 'EOF'
{
    "typescript.preferences.importModuleSpecifier": "relative",
    "typescript.suggest.autoImports": true,
    "typescript.updateImportsOnFileMove.enabled": "always",
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit",
        "source.organizeImports": "explicit"
    },
    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
    "tailwindCSS.includeLanguages": {
        "typescript": "javascript",
        "typescriptreact": "javascript"
    },
    "tailwindCSS.experimental.classRegex": [
        ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
        ["cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
    ],
    "files.associations": {
        "*.css": "tailwindcss"
    },
    "emmet.includeLanguages": {
        "typescript": "html",
        "typescriptreact": "html"
    },
    "typescript.preferences.includePackageJsonAutoImports": "auto"
}
EOF
        
        # Install dependencies
        cd "$target_dir"
        npm install
        
        print_success "JavaScript/Next.js local environment setup complete!"
        print_info "Next steps:"
        echo "1. Install VS Code extensions for TypeScript, ESLint, Prettier, Tailwind CSS"
        echo "2. Open in VS Code: code ."
        echo "3. Copy .env.example to .env.local and configure your environment variables"
        echo "4. Run: npx prisma db push (to set up the database)"
        echo "5. Start developing: npm run dev"
        
    else
        print_error "Invalid environment type: $env_type"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] <target-directory>

Setup development environment (dev container or virtual environment) for Python, Java, and JavaScript/Next.js.

OPTIONS:
    -p, --python TYPE     Setup Python environment (devcontainer|venv)
    -j, --java TYPE       Setup Java environment (devcontainer|local)
    -s, --javascript TYPE Setup JavaScript/Next.js environment (devcontainer|local)
    -a, --all TYPE        Setup all environments (devcontainer|venv|local)
    -h, --help           Show this help message

ENVIRONMENT TYPES:
    devcontainer         Use Docker dev container (requires Docker)
    venv                Use Python virtual environment (Python only)
    local               Use local installation (Java/JavaScript only)

EXAMPLES:
    $0 -p devcontainer /path/to/project    # Setup Python dev container
    $0 -p venv /path/to/project           # Setup Python virtual environment
    $0 -j devcontainer /path/to/project   # Setup Java dev container
    $0 -j local /path/to/project          # Setup Java local environment
    $0 -s devcontainer /path/to/project   # Setup JavaScript/Next.js dev container
    $0 -s local /path/to/project          # Setup JavaScript/Next.js local environment
    $0 -a devcontainer /path/to/project   # Setup all dev containers
    $0 -a venv /path/to/project           # Setup Python venv + Java/JS local

EOF
}

# Main script
main() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Parse command line arguments
    PYTHON_TYPE=""
    JAVA_TYPE=""
    JAVASCRIPT_TYPE=""
    TARGET_DIR=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--python)
                PYTHON_TYPE="$2"
                shift 2
                ;;
            -j|--java)
                JAVA_TYPE="$2"
                shift 2
                ;;
            -s|--javascript)
                JAVASCRIPT_TYPE="$2"
                shift 2
                ;;
            -a|--all)
                ALL_TYPE="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                if [ -z "$TARGET_DIR" ]; then
                    TARGET_DIR="$1"
                else
                    print_error "Unexpected argument: $1"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate target directory
    if [ -z "$TARGET_DIR" ]; then
        print_error "Target directory is required"
        show_usage
        exit 1
    fi
    
    if [ ! -d "$TARGET_DIR" ]; then
        print_error "Target directory does not exist: $TARGET_DIR"
        exit 1
    fi
    
    # Handle --all option
    if [ -n "$ALL_TYPE" ]; then
        if [ "$ALL_TYPE" = "venv" ]; then
            PYTHON_TYPE="venv"
            JAVA_TYPE="local"
            JAVASCRIPT_TYPE="local"
        else
            PYTHON_TYPE="$ALL_TYPE"
            JAVA_TYPE="$ALL_TYPE"
            JAVASCRIPT_TYPE="$ALL_TYPE"
        fi
    fi
    
    # Check if at least one environment type is specified
    if [ -z "$PYTHON_TYPE" ] && [ -z "$JAVA_TYPE" ] && [ -z "$JAVASCRIPT_TYPE" ]; then
        print_error "No environment type specified"
        show_usage
        exit 1
    fi
    
    # Validate environment types
    for type in "$PYTHON_TYPE" "$JAVA_TYPE" "$JAVASCRIPT_TYPE"; do
        if [ -n "$type" ]; then
            case $type in
                devcontainer|venv|local)
                    ;;
                *)
                    print_error "Invalid environment type: $type"
                    show_usage
                    exit 1
                    ;;
            esac
        fi
    done
    
    print_header "🚀 DevContainers Environment Setup"
    print_info "Target directory: $TARGET_DIR"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup environments
    if [ -n "$PYTHON_TYPE" ]; then
        setup_python "$PYTHON_TYPE" "$TARGET_DIR"
    fi
    
    if [ -n "$JAVA_TYPE" ]; then
        setup_java "$JAVA_TYPE" "$TARGET_DIR"
    fi
    
    if [ -n "$JAVASCRIPT_TYPE" ]; then
        setup_javascript "$JAVASCRIPT_TYPE" "$TARGET_DIR"
    fi
    
    print_success "Environment setup complete!"
    print_info "You can now start developing in your chosen environment."
}

# Run main function with all arguments
main "$@" 