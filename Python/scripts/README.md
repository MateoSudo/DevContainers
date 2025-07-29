# Gitea-GitHub Bidirectional Sync Scripts

This directory contains bidirectional synchronization scripts for Gitea and GitHub repositories. These scripts enable you to keep repositories synchronized between your Gitea instance and GitHub, supporting both code and metadata synchronization.

## Available Scripts

### 1. Python Version (`gitea_github_sync.py`)
A comprehensive Python implementation with full API support for:
- Repository code synchronization
- Issue synchronization (basic implementation)
- Pull request synchronization (planned)
- Detailed logging and error handling
- Configuration validation
- Dry-run mode

### 2. Shell Script Version (`gitea-github-sync.sh`)
A lightweight shell script implementation that:
- Works in any Unix-like environment
- Requires only `git`, `curl`, and `jq`
- Focuses on repository code synchronization
- Provides colored output and logging
- Supports all sync directions

## Quick Start

### 1. Create Configuration

```bash
# Using Python version
python3 scripts/gitea_github_sync.py --config sync_config.yaml

# Using shell version
./scripts/gitea-github-sync.sh --init
```

### 2. Edit Configuration

Edit the generated configuration file with your actual credentials:

```yaml
# For Python version (sync_config.yaml)
gitea:
  url: "https://your-gitea-instance.com"
  username: "your-gitea-username"
  token: "your-gitea-api-token"
github:
  username: "your-github-username"
  token: "your-github-personal-access-token"
repositories:
  - gitea_repo: "owner/repo-name"
    github_repo: "owner/repo-name"
    sync_direction: "bidirectional"
    sync_issues: true
```

```json
# For shell version (sync_config.json)
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
      "sync_issues": true
    }
  ]
}
```

### 3. Run Synchronization

```bash
# Sync all configured repositories
python3 scripts/gitea_github_sync.py
# or
./scripts/gitea-github-sync.sh

# Sync specific repository
python3 scripts/gitea_github_sync.py --repo myorg/myrepo
./scripts/gitea-github-sync.sh --repo myorg/myrepo

# Dry run (see what would be synced without making changes)
python3 scripts/gitea_github_sync.py --dry-run
./scripts/gitea-github-sync.sh --dry-run

# Continuous sync (runs at intervals)
python3 scripts/gitea_github_sync.py --continuous
./scripts/gitea-github-sync.sh --continuous
```

## Configuration Options

### Sync Directions
- `bidirectional`: Sync changes in both directions
- `gitea_to_github`: Only push changes from Gitea to GitHub
- `github_to_gitea`: Only push changes from GitHub to Gitea

### Repository Mapping
You can sync repositories with different names:
```bash
./scripts/gitea-github-sync.sh --repo gitea-org/repo-name:github-org/different-name
```

### Environment Variables
- `CONFIG_FILE`: Path to configuration file
- `SYNC_WORKSPACE`: Directory for temporary repository clones
- `LOG_FILE`: Path to log file
- `DRY_RUN`: Set to 'true' for dry-run mode

## Security Considerations

### API Tokens
1. **Gitea Token**: Create a personal access token in Gitea with repository permissions
2. **GitHub Token**: Create a Personal Access Token in GitHub with `repo` scope

### Token Storage
- Store tokens securely (consider using environment variables)
- Never commit configuration files with real tokens to version control
- Use different tokens for different environments

### Repository Access
- Ensure tokens have appropriate permissions for all configured repositories
- Test with a single repository before configuring multiple repos

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   # Test API access
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   curl -H "Authorization: token YOUR_TOKEN" https://your-gitea.com/api/v1/user
   ```

2. **Git Push Failures**
   - Check for protected branches
   - Verify force-push permissions
   - Ensure tokens have push access

3. **Missing Dependencies**
   ```bash
   # For shell version
   sudo apt-get install git curl jq
   
   # For Python version
   pip install -r requirements.txt
   ```

### Debug Mode
Add verbose logging by setting environment variables:
```bash
export LOG_LEVEL=DEBUG
python3 scripts/gitea_github_sync.py
```

### Log Analysis
Check the log file for detailed information:
```bash
tail -f sync.log
```

## Advanced Usage

### Automated Sync with Cron
```bash
# Edit crontab
crontab -e

# Add entry for sync every 5 minutes
*/5 * * * * cd /path/to/project && ./scripts/gitea-github-sync.sh > /dev/null 2>&1
```

### Docker Integration
The scripts work seamlessly in the DevContainer environment:
```bash
# Run in container
docker exec -it container_name /workspace/scripts/gitea-github-sync.sh
```

### Systemd Service
Create a systemd service for continuous sync:
```ini
[Unit]
Description=Gitea-GitHub Sync Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/project
ExecStart=/path/to/project/scripts/gitea-github-sync.sh --continuous
Restart=always

[Install]
WantedBy=multi-user.target
```

## Development

### Script Structure
- Configuration loading and validation
- API client setup for both Gitea and GitHub
- Git operations for repository synchronization
- Error handling and logging
- CLI argument parsing

### Extending Functionality
To add new features:
1. Update configuration schema
2. Add new functions for specific operations
3. Update CLI argument parsing
4. Add appropriate tests

### Contributing
When contributing improvements:
1. Test with both Python and shell versions
2. Ensure backward compatibility
3. Update documentation
4. Add appropriate error handling

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review log files for detailed error messages
3. Test API access manually
4. Verify configuration syntax 