#!/bin/bash

# Bidirectional sync script for Gitea and GitHub repositories
# Shell script version that works in any environment with git and curl

set -euo pipefail

# Default configuration
CONFIG_FILE="${CONFIG_FILE:-sync_config.json}"
SYNC_WORKSPACE="${SYNC_WORKSPACE:-./sync_workspace}"
LOG_FILE="${LOG_FILE:-sync.log}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${BLUE}INFO${NC}: $1"
}

log_warn() {
    log "${YELLOW}WARN${NC}: $1"
}

log_error() {
    log "${RED}ERROR${NC}: $1"
}

log_success() {
    log "${GREEN}SUCCESS${NC}: $1"
}

# Check if required tools are installed
check_dependencies() {
    local missing_deps=()
    
    for dep in git curl jq; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 1
    fi
}

# Create configuration template
create_config_template() {
    local config_file="$1"
    
    cat > "$config_file" << 'EOF'
{
  "gitea": {
    "url": "https://your-gitea-instance.com",
    "username": "your-gitea-username",
    "token": "your-gitea-api-token"
  },
  "github": {
    "username": "your-github-username",
    "token": "your-github-personal-access-token"
  },
  "repositories": [
    {
      "gitea_repo": "owner/repo-name",
      "github_repo": "owner/repo-name",
      "sync_direction": "bidirectional",
      "sync_issues": true,
      "sync_pull_requests": true
    }
  ],
  "sync_settings": {
    "dry_run": false,
    "sync_interval": 300,
    "conflict_resolution": "manual"
  }
}
EOF
    
    log_info "Created configuration template at $config_file"
    log_info "Please edit the configuration file with your actual credentials and repository settings"
}

# Load and validate configuration
load_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file $config_file not found"
        create_config_template "$config_file"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! jq empty "$config_file" 2>/dev/null; then
        log_error "Invalid JSON in configuration file $config_file"
        exit 1
    fi
    
    # Check required fields
    local required_fields=(
        ".gitea.url"
        ".gitea.username"
        ".gitea.token"
        ".github.username"
        ".github.token"
    )
    
    for field in "${required_fields[@]}"; do
        if [ "$(jq -r "$field" "$config_file")" = "null" ]; then
            log_error "Missing required configuration field: $field"
            exit 1
        fi
    done
}

# Get repository information from Gitea
get_gitea_repo_info() {
    local repo="$1"
    local gitea_url gitea_token
    
    gitea_url=$(jq -r '.gitea.url' "$CONFIG_FILE")
    gitea_token=$(jq -r '.gitea.token' "$CONFIG_FILE")
    
    curl -s -H "Authorization: token $gitea_token" \
         -H "Content-Type: application/json" \
         "$gitea_url/api/v1/repos/$repo"
}

# Get repository information from GitHub
get_github_repo_info() {
    local repo="$1"
    local github_token
    
    github_token=$(jq -r '.github.token' "$CONFIG_FILE")
    
    curl -s -H "Authorization: token $github_token" \
         -H "Accept: application/vnd.github.v3+json" \
         -H "Content-Type: application/json" \
         "https://api.github.com/repos/$repo"
}

# Setup repository remotes
setup_remotes() {
    local local_path="$1"
    local gitea_url="$2"
    local github_url="$3"
    
    cd "$local_path"
    
    # Remove existing remotes (ignore errors)
    git remote remove gitea 2>/dev/null || true
    git remote remove github 2>/dev/null || true
    
    # Add new remotes
    if ! git remote add gitea "$gitea_url"; then
        log_error "Failed to add Gitea remote"
        return 1
    fi
    
    if ! git remote add github "$github_url"; then
        log_error "Failed to add GitHub remote"
        return 1
    fi
    
    return 0
}

# Clone or update repository
clone_or_update_repo() {
    local repo_url="$1"
    local local_path="$2"
    
    if [ -d "$local_path" ]; then
        log_info "Updating existing repository at $local_path"
        cd "$local_path"
        if ! git fetch --all; then
            log_error "Failed to fetch updates"
            return 1
        fi
    else
        log_info "Cloning repository to $local_path"
        if ! git clone "$repo_url" "$local_path"; then
            log_error "Failed to clone repository"
            return 1
        fi
    fi
    
    return 0
}

# Sync repository code
sync_repository_code() {
    local gitea_repo="$1"
    local github_repo="$2"
    local sync_direction="$3"
    
    log_info "Syncing repository code: $gitea_repo <-> $github_repo"
    
    # Get configuration values
    local gitea_url gitea_username gitea_token github_username github_token
    gitea_url=$(jq -r '.gitea.url' "$CONFIG_FILE")
    gitea_username=$(jq -r '.gitea.username' "$CONFIG_FILE")
    gitea_token=$(jq -r '.gitea.token' "$CONFIG_FILE")
    github_username=$(jq -r '.github.username' "$CONFIG_FILE")
    github_token=$(jq -r '.github.token' "$CONFIG_FILE")
    
    # Construct repository URLs with authentication
    local gitea_clone_url="$gitea_url/$gitea_repo.git"
    local github_clone_url="https://$github_username:$github_token@github.com/$github_repo.git"
    
    # Create local working directory
    local local_path="$SYNC_WORKSPACE/${gitea_repo//\//_}"
    mkdir -p "$(dirname "$local_path")"
    
    # Clone or update local repository
    if ! clone_or_update_repo "$gitea_clone_url" "$local_path"; then
        return 1
    fi
    
    # Setup remotes
    if ! setup_remotes "$local_path" "$gitea_clone_url" "$github_clone_url"; then
        return 1
    fi
    
    cd "$local_path"
    
    # Perform sync based on direction
    if [ "$sync_direction" = "bidirectional" ] || [ "$sync_direction" = "gitea_to_github" ]; then
        log_info "Syncing from Gitea to GitHub"
        if [ "$DRY_RUN" = "true" ]; then
            log_info "[DRY RUN] Would push all branches to GitHub"
        else
            if ! git push github --all; then
                log_warn "Failed to push some branches to GitHub (this might be expected for protected branches)"
            fi
            if ! git push github --tags; then
                log_warn "Failed to push some tags to GitHub"
            fi
        fi
    fi
    
    if [ "$sync_direction" = "bidirectional" ] || [ "$sync_direction" = "github_to_gitea" ]; then
        log_info "Syncing from GitHub to Gitea"
        if [ "$DRY_RUN" = "true" ]; then
            log_info "[DRY RUN] Would fetch from GitHub and push to Gitea"
        else
            if git fetch github; then
                if ! git push gitea --all; then
                    log_warn "Failed to push some branches to Gitea"
                fi
                if ! git push gitea --tags; then
                    log_warn "Failed to push some tags to Gitea"
                fi
            else
                log_error "Failed to fetch from GitHub"
                return 1
            fi
        fi
    fi
    
    log_success "Successfully synced repository code for $gitea_repo"
    return 0
}

# Sync issues (basic implementation)
sync_issues() {
    local gitea_repo="$1"
    local github_repo="$2"
    local sync_issues="$3"
    
    if [ "$sync_issues" != "true" ]; then
        return 0
    fi
    
    log_info "Issue synchronization requested for $gitea_repo <-> $github_repo"
    log_warn "Issue synchronization is not fully implemented in shell version"
    log_info "Consider using the Python version for full issue synchronization"
    
    return 0
}

# Process single repository
process_repository() {
    local repo_config="$1"
    
    local gitea_repo github_repo sync_direction sync_issues
    gitea_repo=$(echo "$repo_config" | jq -r '.gitea_repo')
    github_repo=$(echo "$repo_config" | jq -r '.github_repo')
    sync_direction=$(echo "$repo_config" | jq -r '.sync_direction // "bidirectional"')
    sync_issues=$(echo "$repo_config" | jq -r '.sync_issues // false')
    
    log_info "Starting sync for $gitea_repo <-> $github_repo"
    
    # Verify repositories exist
    local gitea_info github_info
    gitea_info=$(get_gitea_repo_info "$gitea_repo")
    github_info=$(get_github_repo_info "$github_repo")
    
    if echo "$gitea_info" | jq -e '.message' > /dev/null 2>&1; then
        log_error "Failed to access Gitea repository $gitea_repo: $(echo "$gitea_info" | jq -r '.message')"
        return 1
    fi
    
    if echo "$github_info" | jq -e '.message' > /dev/null 2>&1; then
        log_error "Failed to access GitHub repository $github_repo: $(echo "$github_info" | jq -r '.message')"
        return 1
    fi
    
    # Sync repository code
    if ! sync_repository_code "$gitea_repo" "$github_repo" "$sync_direction"; then
        log_error "Failed to sync repository code for $gitea_repo <-> $github_repo"
        return 1
    fi
    
    # Sync issues
    if ! sync_issues "$gitea_repo" "$github_repo" "$sync_issues"; then
        log_error "Failed to sync issues for $gitea_repo <-> $github_repo"
        return 1
    fi
    
    log_success "Completed sync for $gitea_repo <-> $github_repo"
    return 0
}

# Sync all repositories
sync_all_repositories() {
    local success=true
    local repo_count
    
    repo_count=$(jq -r '.repositories | length' "$CONFIG_FILE")
    
    if [ "$repo_count" -eq 0 ]; then
        log_warn "No repositories configured for synchronization"
        return 0
    fi
    
    log_info "Starting synchronization of $repo_count repositories"
    
    for i in $(seq 0 $((repo_count - 1))); do
        local repo_config
        repo_config=$(jq -c ".repositories[$i]" "$CONFIG_FILE")
        
        if ! process_repository "$repo_config"; then
            success=false
        fi
    done
    
    if [ "$success" = true ]; then
        log_success "All repositories synchronized successfully"
        return 0
    else
        log_error "Some repositories failed to synchronize"
        return 1
    fi
}

# Run continuous sync
run_continuous_sync() {
    local interval
    interval=$(jq -r '.sync_settings.sync_interval // 300' "$CONFIG_FILE")
    
    log_info "Starting continuous sync with $interval second intervals"
    log_info "Press Ctrl+C to stop"
    
    while true; do
        log_info "Starting sync cycle..."
        
        if sync_all_repositories; then
            log_info "Sync cycle completed successfully"
        else
            log_error "Sync cycle completed with errors"
        fi
        
        log_info "Waiting $interval seconds before next sync..."
        sleep "$interval"
    done
}

# Show help
show_help() {
    cat << EOF
Bidirectional sync script for Gitea and GitHub repositories

Usage: $0 [OPTIONS]

Options:
    -c, --config FILE       Configuration file path (default: sync_config.json)
    -r, --repo REPO         Sync specific repository (format: gitea_owner/repo:github_owner/repo)
    -d, --dry-run          Perform dry run without making changes
    -C, --continuous       Run continuous sync
    -i, --init             Create configuration template
    -h, --help             Show this help message

Environment Variables:
    CONFIG_FILE             Configuration file path
    SYNC_WORKSPACE          Workspace directory for cloned repositories
    LOG_FILE                Log file path
    DRY_RUN                 Set to 'true' for dry run mode

Examples:
    $0 --init                                   # Create configuration template
    $0                                          # Sync all configured repositories
    $0 --repo myorg/myrepo                     # Sync specific repository
    $0 --repo myorg/myrepo:otherorg/myrepo     # Sync with different names
    $0 --continuous                            # Run continuous sync
    $0 --dry-run                              # Perform dry run

EOF
}

# Main function
main() {
    local continuous=false
    local specific_repo=""
    local init_config=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -r|--repo)
                specific_repo="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -C|--continuous)
                continuous=true
                shift
                ;;
            -i|--init)
                init_config=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Initialize configuration if requested
    if [ "$init_config" = true ]; then
        create_config_template "$CONFIG_FILE"
        exit 0
    fi
    
    # Check dependencies
    check_dependencies
    
    # Load and validate configuration
    load_config "$CONFIG_FILE"
    
    # Set dry run from config if not set via command line
    if [ "$DRY_RUN" = "false" ]; then
        local config_dry_run
        config_dry_run=$(jq -r '.sync_settings.dry_run // false' "$CONFIG_FILE")
        if [ "$config_dry_run" = "true" ]; then
            DRY_RUN="true"
        fi
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "Running in dry-run mode"
    fi
    
    # Create workspace directory
    mkdir -p "$SYNC_WORKSPACE"
    
    # Handle specific repository sync
    if [ -n "$specific_repo" ]; then
        local gitea_repo github_repo
        
        if [[ "$specific_repo" == *":"* ]]; then
            gitea_repo="${specific_repo%%:*}"
            github_repo="${specific_repo##*:}"
        else
            gitea_repo="$specific_repo"
            github_repo="$specific_repo"
        fi
        
        log_info "Syncing specific repository: $gitea_repo <-> $github_repo"
        
        local repo_config
        repo_config=$(jq -n \
            --arg gitea_repo "$gitea_repo" \
            --arg github_repo "$github_repo" \
            '{
                gitea_repo: $gitea_repo,
                github_repo: $github_repo,
                sync_direction: "bidirectional",
                sync_issues: true,
                sync_pull_requests: true
            }')
        
        if process_repository "$repo_config"; then
            log_success "Repository sync completed successfully"
            exit 0
        else
            log_error "Repository sync failed"
            exit 1
        fi
    fi
    
    # Handle continuous sync
    if [ "$continuous" = true ]; then
        run_continuous_sync
        exit 0
    fi
    
    # Default: sync all repositories
    if sync_all_repositories; then
        log_success "All repositories synchronized successfully"
        exit 0
    else
        log_error "Some repositories failed to synchronize"
        exit 1
    fi
}

# Run main function with all arguments
main "$@" 