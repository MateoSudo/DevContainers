# Gitea-GitHub Bidirectional Sync Scripts

This directory contains bidirectional synchronization scripts for Gitea and GitHub repositories. These scripts enable you to keep repositories synchronized between your Gitea instance and GitHub, supporting both code and metadata synchronization.

## Available Scripts

### 1. Node.js Version (`gitea-github-sync.js`)
A modern Node.js implementation with:
- Native JavaScript async/await support
- Built-in HTTP client for API calls
- Repository code synchronization
- Detailed logging and error handling
- Configuration validation
- Dry-run mode
- Promise-based architecture

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
# Using Node.js version
node scripts/gitea-github-sync.js --init

# Using shell version
./scripts/gitea-github-sync.sh --init
```

### 2. Edit Configuration

Edit the generated `sync_config.json` file with your actual credentials:

```json
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
```

### 3. Run Synchronization

```bash
# Sync all configured repositories
node scripts/gitea-github-sync.js
# or
./scripts/gitea-github-sync.sh

# Sync specific repository
node scripts/gitea-github-sync.js --repo myorg/myrepo
./scripts/gitea-github-sync.sh --repo myorg/myrepo

# Dry run (see what would be synced without making changes)
node scripts/gitea-github-sync.js --dry-run
./scripts/gitea-github-sync.sh --dry-run

# Continuous sync (runs at intervals)
node scripts/gitea-github-sync.js --continuous
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
node scripts/gitea-github-sync.js --repo gitea-org/repo-name:github-org/different-name
```

### Environment Variables
- `CONFIG_FILE`: Path to configuration file (default: `sync_config.json`)
- `SYNC_WORKSPACE`: Directory for temporary repository clones (default: `./sync_workspace`)
- `LOG_FILE`: Path to log file (default: `sync.log`)
- `DRY_RUN`: Set to 'true' for dry-run mode

## Dependencies

### Node.js Requirements
- Node.js 18.0.0 or higher
- Built-in modules: `fs`, `path`, `child_process`, `https`, `http`
- No external npm packages required

### System Requirements
- Git (for repository operations)
- Network access to both Gitea and GitHub

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

1. **Node.js Version**
   ```bash
   # Check Node.js version
   node --version
   # Should be 18.0.0 or higher
   ```

2. **Authentication Errors**
   ```bash
   # Test API access
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   curl -H "Authorization: token YOUR_TOKEN" https://your-gitea.com/api/v1/user
   ```

3. **Git Push Failures**
   - Check for protected branches
   - Verify force-push permissions
   - Ensure tokens have push access

4. **Missing Dependencies**
   ```bash
   # For shell version
   sudo apt-get install git curl jq
   
   # Node.js version uses built-in modules only
   ```

### Debug Mode
Enable verbose logging:
```bash
# Set environment variable for more detailed logs
export LOG_LEVEL=DEBUG
node scripts/gitea-github-sync.js
```

### Log Analysis
Check the log file for detailed information:
```bash
tail -f sync.log
```

## Advanced Usage

### Package.json Integration
Add sync scripts to your package.json:
```json
{
  "scripts": {
    "sync": "node scripts/gitea-github-sync.js",
    "sync:dry": "node scripts/gitea-github-sync.js --dry-run",
    "sync:continuous": "node scripts/gitea-github-sync.js --continuous",
    "sync:init": "node scripts/gitea-github-sync.js --init"
  }
}
```

Then run with npm:
```bash
npm run sync
npm run sync:dry
npm run sync:continuous
```

### PM2 Process Manager
Use PM2 for production continuous sync:
```bash
# Install PM2
npm install -g pm2

# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'gitea-github-sync',
    script: './scripts/gitea-github-sync.js',
    args: '--continuous',
    cwd: '/path/to/project',
    env: {
      NODE_ENV: 'production'
    }
  }]
}
EOF

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Docker Integration
The scripts work seamlessly in the DevContainer environment:
```bash
# Run in container
docker exec -it container_name node /workspace/scripts/gitea-github-sync.js
```

### Automated Sync with Cron
```bash
# Edit crontab
crontab -e

# Add entry for sync every 5 minutes
*/5 * * * * cd /path/to/project && node scripts/gitea-github-sync.js > /dev/null 2>&1
```

## Development

### Script Architecture
- **Configuration Management**: JSON-based configuration with validation
- **API Clients**: Native Node.js HTTP clients for Gitea and GitHub APIs
- **Git Operations**: Child process execution of git commands
- **Error Handling**: Comprehensive error handling with detailed logging
- **Async/Await**: Modern JavaScript patterns for clean asynchronous code

### Module Structure
The script exports key functions for programmatic use:
```javascript
const sync = require('./scripts/gitea-github-sync.js');

// Load configuration
const config = sync.loadConfig('config.json');

// Sync all repositories
await sync.syncAllRepositories(config);

// Sync specific repository
const repoConfig = { /* ... */ };
await sync.processRepository(repoConfig, config);
```

### Extending Functionality
To add new features:
1. Add new configuration options to the schema
2. Implement new async functions for specific operations
3. Update CLI argument parsing in the main function
4. Add appropriate error handling and logging

### Testing
```bash
# Test configuration creation
node scripts/gitea-github-sync.js --init

# Test with dry run
node scripts/gitea-github-sync.js --dry-run

# Test specific repository
node scripts/gitea-github-sync.js --repo test-org/test-repo --dry-run
```

### Contributing
When contributing improvements:
1. Follow JavaScript ES6+ standards
2. Use async/await for asynchronous operations
3. Maintain compatibility with Node.js 18+
4. Add comprehensive error handling
5. Update documentation

## Performance Considerations

### Memory Usage
- The script processes repositories sequentially to manage memory usage
- Large repositories may require more system memory for git operations
- Monitor memory usage during continuous sync operations

### Network Efficiency
- API calls are made only when necessary
- Git operations use existing clones when possible
- Implements proper rate limiting for API calls

### Concurrency
- Sequential processing prevents git conflicts
- Can be safely run multiple times (idempotent operations)
- Includes proper cleanup of temporary files

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review log files for detailed error messages
3. Test API access manually
4. Verify Node.js version compatibility
5. Ensure configuration syntax is valid JSON 