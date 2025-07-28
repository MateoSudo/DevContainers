#!/usr/bin/env node

/**
 * Bidirectional sync script for Gitea and GitHub repositories
 * Node.js/JavaScript version for JavaScript development environments
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');
const https = require('https');
const http = require('http');

// Configuration
const CONFIG_FILE = process.env.CONFIG_FILE || 'sync_config.json';
const SYNC_WORKSPACE = process.env.SYNC_WORKSPACE || './sync_workspace';
const LOG_FILE = process.env.LOG_FILE || 'sync.log';
let DRY_RUN = process.env.DRY_RUN === 'true';

// Colors for console output
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m'
};

// Logging functions
function log(level, message) {
    const timestamp = new Date().toISOString().replace('T', ' ').substr(0, 19);
    const logMessage = `[${timestamp}] ${level}: ${message}`;

    console.log(logMessage);

    // Append to log file
    try {
        fs.appendFileSync(LOG_FILE, logMessage + '\n');
    } catch (err) {
        // Ignore log file errors
    }
}

function logInfo(message) {
    log(`${colors.blue}INFO${colors.reset}`, message);
}

function logWarn(message) {
    log(`${colors.yellow}WARN${colors.reset}`, message);
}

function logError(message) {
    log(`${colors.red}ERROR${colors.reset}`, message);
}

function logSuccess(message) {
    log(`${colors.green}SUCCESS${colors.reset}`, message);
}

// Check dependencies
function checkDependencies() {
    const deps = ['git', 'node'];
    const missing = [];

    for (const dep of deps) {
        try {
            execSync(`which ${dep}`, { stdio: 'ignore' });
        } catch (err) {
            missing.push(dep);
        }
    }

    if (missing.length > 0) {
        logError(`Missing required dependencies: ${missing.join(', ')}`);
        logInfo('Please install missing dependencies and try again');
        process.exit(1);
    }
}

// Create configuration template
function createConfigTemplate(configFile) {
    const template = {
        gitea: {
            url: 'https://your-gitea-instance.com',
            username: 'your-gitea-username',
            token: 'your-gitea-api-token'
        },
        github: {
            username: 'your-github-username',
            token: 'your-github-personal-access-token'
        },
        repositories: [
            {
                gitea_repo: 'owner/repo-name',
                github_repo: 'owner/repo-name',
                sync_direction: 'bidirectional',
                sync_issues: true,
                sync_pull_requests: true
            }
        ],
        sync_settings: {
            dry_run: false,
            sync_interval: 300,
            conflict_resolution: 'manual'
        }
    };

    fs.writeFileSync(configFile, JSON.stringify(template, null, 2));
    logInfo(`Created configuration template at ${configFile}`);
    logInfo('Please edit the configuration file with your actual credentials and repository settings');
}

// Load and validate configuration
function loadConfig(configFile) {
    if (!fs.existsSync(configFile)) {
        logError(`Configuration file ${configFile} not found`);
        createConfigTemplate(configFile);
        process.exit(1);
    }

    try {
        const config = JSON.parse(fs.readFileSync(configFile, 'utf8'));

        // Validate required fields
        const requiredFields = [
            'gitea.url', 'gitea.username', 'gitea.token',
            'github.username', 'github.token'
        ];

        for (const field of requiredFields) {
            const keys = field.split('.');
            let value = config;
            for (const key of keys) {
                if (!value || !value.hasOwnProperty(key)) {
                    logError(`Missing required configuration field: ${field}`);
                    process.exit(1);
                }
                value = value[key];
            }
        }

        return config;
    } catch (err) {
        logError(`Error parsing configuration file: ${err.message}`);
        process.exit(1);
    }
}

// HTTP request helper
function makeRequest(url, options = {}) {
    return new Promise((resolve, reject) => {
        const requestModule = url.startsWith('https:') ? https : http;

        const req = requestModule.request(url, options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const response = {
                        statusCode: res.statusCode,
                        data: data ? JSON.parse(data) : null
                    };
                    resolve(response);
                } catch (err) {
                    resolve({
                        statusCode: res.statusCode,
                        data: data
                    });
                }
            });
        });

        req.on('error', reject);

        if (options.body) {
            req.write(options.body);
        }

        req.end();
    });
}

// Get repository information from Gitea
async function getGiteaRepoInfo(repo, config) {
    const url = `${config.gitea.url}/api/v1/repos/${repo}`;
    const options = {
        method: 'GET',
        headers: {
            'Authorization': `token ${config.gitea.token}`,
            'Content-Type': 'application/json'
        }
    };

    try {
        const response = await makeRequest(url, options);
        return response.data;
    } catch (err) {
        logError(`Error fetching Gitea repo ${repo}: ${err.message}`);
        return null;
    }
}

// Get repository information from GitHub
async function getGithubRepoInfo(repo, config) {
    const url = `https://api.github.com/repos/${repo}`;
    const options = {
        method: 'GET',
        headers: {
            'Authorization': `token ${config.github.token}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
    };

    try {
        const response = await makeRequest(url, options);
        return response.data;
    } catch (err) {
        logError(`Error fetching GitHub repo ${repo}: ${err.message}`);
        return null;
    }
}

// Execute git command
function gitCommand(command, cwd = process.cwd()) {
    try {
        const result = execSync(command, {
            cwd: cwd,
            stdio: 'pipe',
            encoding: 'utf8'
        });
        return { success: true, output: result };
    } catch (err) {
        logError(`Git command failed: ${command}`);
        logError(`Error: ${err.message}`);
        return { success: false, output: err.message };
    }
}

// Clone or update repository
function cloneOrUpdateRepo(repoUrl, localPath) {
    if (fs.existsSync(localPath)) {
        logInfo(`Updating existing repository at ${localPath}`);
        const result = gitCommand('git fetch --all', localPath);
        return result.success;
    } else {
        logInfo(`Cloning repository to ${localPath}`);
        // Ensure parent directory exists
        const parentDir = path.dirname(localPath);
        if (!fs.existsSync(parentDir)) {
            fs.mkdirSync(parentDir, { recursive: true });
        }
        const result = gitCommand(`git clone ${repoUrl} ${localPath}`);
        return result.success;
    }
}

// Setup repository remotes
function setupRemotes(localPath, giteaUrl, githubUrl) {
    // Remove existing remotes (ignore errors)
    gitCommand('git remote remove gitea', localPath);
    gitCommand('git remote remove github', localPath);

    // Add new remotes
    const giteaResult = gitCommand(`git remote add gitea ${giteaUrl}`, localPath);
    if (!giteaResult.success) {
        logError('Failed to add Gitea remote');
        return false;
    }

    const githubResult = gitCommand(`git remote add github ${githubUrl}`, localPath);
    if (!githubResult.success) {
        logError('Failed to add GitHub remote');
        return false;
    }

    return true;
}

// Sync repository code
async function syncRepositoryCode(giteaRepo, githubRepo, syncDirection, config) {
    logInfo(`Syncing repository code: ${giteaRepo} <-> ${githubRepo}`);

    // Get repository information
    const [giteaInfo, githubInfo] = await Promise.all([
        getGiteaRepoInfo(giteaRepo, config),
        getGithubRepoInfo(githubRepo, config)
    ]);

    if (!giteaInfo || !githubInfo) {
        logError('Failed to get repository information');
        return false;
    }

    if (giteaInfo.message || githubInfo.message) {
        logError(`Repository access error - Gitea: ${giteaInfo.message || 'OK'}, GitHub: ${githubInfo.message || 'OK'}`);
        return false;
    }

    // Construct repository URLs with authentication
    const giteaUrl = `${config.gitea.url}/${giteaRepo}.git`;
    const githubUrl = `https://${config.github.username}:${config.github.token}@github.com/${githubRepo}.git`;

    // Create local working directory
    const localPath = path.join(SYNC_WORKSPACE, giteaRepo.replace('/', '_'));

    // Clone or update local repository
    if (!cloneOrUpdateRepo(giteaUrl, localPath)) {
        return false;
    }

    // Setup remotes
    if (!setupRemotes(localPath, giteaUrl, githubUrl)) {
        return false;
    }

    // Perform sync based on direction
    if (syncDirection === 'bidirectional' || syncDirection === 'gitea_to_github') {
        logInfo('Syncing from Gitea to GitHub');
        if (DRY_RUN) {
            logInfo('[DRY RUN] Would push all branches to GitHub');
        } else {
            const pushAllResult = gitCommand('git push github --all', localPath);
            if (!pushAllResult.success) {
                logWarn('Failed to push some branches to GitHub (this might be expected for protected branches)');
            }
            const pushTagsResult = gitCommand('git push github --tags', localPath);
            if (!pushTagsResult.success) {
                logWarn('Failed to push some tags to GitHub');
            }
        }
    }

    if (syncDirection === 'bidirectional' || syncDirection === 'github_to_gitea') {
        logInfo('Syncing from GitHub to Gitea');
        if (DRY_RUN) {
            logInfo('[DRY RUN] Would fetch from GitHub and push to Gitea');
        } else {
            const fetchResult = gitCommand('git fetch github', localPath);
            if (fetchResult.success) {
                const pushAllResult = gitCommand('git push gitea --all', localPath);
                if (!pushAllResult.success) {
                    logWarn('Failed to push some branches to Gitea');
                }
                const pushTagsResult = gitCommand('git push gitea --tags', localPath);
                if (!pushTagsResult.success) {
                    logWarn('Failed to push some tags to Gitea');
                }
            } else {
                logError('Failed to fetch from GitHub');
                return false;
            }
        }
    }

    logSuccess(`Successfully synced repository code for ${giteaRepo}`);
    return true;
}

// Sync issues (basic implementation)
async function syncIssues(giteaRepo, githubRepo, syncIssues, config) {
    if (!syncIssues) {
        return true;
    }

    logInfo(`Issue synchronization requested for ${giteaRepo} <-> ${githubRepo}`);
    logWarn('Issue synchronization is not fully implemented in Node.js version');
    logInfo('Consider using the Python version for full issue synchronization');

    return true;
}

// Process single repository
async function processRepository(repoConfig, config) {
    const {
        gitea_repo: giteaRepo,
        github_repo: githubRepo,
        sync_direction: syncDirection = 'bidirectional',
        sync_issues: syncIssues = false
    } = repoConfig;

    logInfo(`Starting sync for ${giteaRepo} <-> ${githubRepo}`);

    // Sync repository code
    const codeSuccess = await syncRepositoryCode(giteaRepo, githubRepo, syncDirection, config);
    if (!codeSuccess) {
        logError(`Failed to sync repository code for ${giteaRepo} <-> ${githubRepo}`);
        return false;
    }

    // Sync issues
    const issuesSuccess = await syncIssues(giteaRepo, githubRepo, syncIssues, config);
    if (!issuesSuccess) {
        logError(`Failed to sync issues for ${giteaRepo} <-> ${githubRepo}`);
        return false;
    }

    logSuccess(`Completed sync for ${giteaRepo} <-> ${githubRepo}`);
    return true;
}

// Sync all repositories
async function syncAllRepositories(config) {
    const repositories = config.repositories || [];

    if (repositories.length === 0) {
        logWarn('No repositories configured for synchronization');
        return true;
    }

    logInfo(`Starting synchronization of ${repositories.length} repositories`);

    let success = true;
    for (const repoConfig of repositories) {
        try {
            const repoSuccess = await processRepository(repoConfig, config);
            if (!repoSuccess) {
                success = false;
            }
        } catch (err) {
            logError(`Error syncing repository ${repoConfig.gitea_repo}: ${err.message}`);
            success = false;
        }
    }

    if (success) {
        logSuccess('All repositories synchronized successfully');
    } else {
        logError('Some repositories failed to synchronize');
    }

    return success;
}

// Run continuous sync
async function runContinuousSync(config) {
    const interval = (config.sync_settings?.sync_interval || 300) * 1000; // Convert to milliseconds

    logInfo(`Starting continuous sync with ${interval / 1000} second intervals`);
    logInfo('Press Ctrl+C to stop');

    // Handle graceful shutdown
    process.on('SIGINT', () => {
        logInfo('Sync interrupted by user');
        process.exit(0);
    });

    while (true) {
        try {
            logInfo('Starting sync cycle...');
            const success = await syncAllRepositories(config);

            if (success) {
                logInfo('Sync cycle completed successfully');
            } else {
                logError('Sync cycle completed with errors');
            }

            logInfo(`Waiting ${interval / 1000} seconds before next sync...`);
            await new Promise(resolve => setTimeout(resolve, interval));

        } catch (err) {
            logError(`Error during sync cycle: ${err.message}`);
            // Wait a minute before retrying
            await new Promise(resolve => setTimeout(resolve, 60000));
        }
    }
}

// Show help
function showHelp() {
    console.log(`
Bidirectional sync script for Gitea and GitHub repositories

Usage: node ${path.basename(__filename)} [OPTIONS]

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
    node ${path.basename(__filename)} --init                                   # Create configuration template
    node ${path.basename(__filename)}                                          # Sync all configured repositories
    node ${path.basename(__filename)} --repo myorg/myrepo                     # Sync specific repository
    node ${path.basename(__filename)} --repo myorg/myrepo:otherorg/myrepo     # Sync with different names
    node ${path.basename(__filename)} --continuous                            # Run continuous sync
    node ${path.basename(__filename)} --dry-run                              # Perform dry run
`);
}

// Main function
async function main() {
    // Parse command line arguments
    const args = process.argv.slice(2);
    let configFile = CONFIG_FILE;
    let continuous = false;
    let specificRepo = '';
    let initConfig = false;

    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '-c':
            case '--config':
                configFile = args[++i];
                break;
            case '-r':
            case '--repo':
                specificRepo = args[++i];
                break;
            case '-d':
            case '--dry-run':
                DRY_RUN = true;
                break;
            case '-C':
            case '--continuous':
                continuous = true;
                break;
            case '-i':
            case '--init':
                initConfig = true;
                break;
            case '-h':
            case '--help':
                showHelp();
                process.exit(0);
                break;
            default:
                logError(`Unknown option: ${args[i]}`);
                showHelp();
                process.exit(1);
        }
    }

    // Initialize configuration if requested
    if (initConfig) {
        createConfigTemplate(configFile);
        process.exit(0);
    }

    // Check dependencies
    checkDependencies();

    // Load and validate configuration
    const config = loadConfig(configFile);

    // Set dry run from config if not set via command line
    if (!DRY_RUN && config.sync_settings?.dry_run) {
        DRY_RUN = true;
    }

    if (DRY_RUN) {
        logInfo('Running in dry-run mode');
    }

    // Create workspace directory
    if (!fs.existsSync(SYNC_WORKSPACE)) {
        fs.mkdirSync(SYNC_WORKSPACE, { recursive: true });
    }

    try {
        // Handle specific repository sync
        if (specificRepo) {
            let giteaRepo, githubRepo;

            if (specificRepo.includes(':')) {
                [giteaRepo, githubRepo] = specificRepo.split(':');
            } else {
                giteaRepo = githubRepo = specificRepo;
            }

            logInfo(`Syncing specific repository: ${giteaRepo} <-> ${githubRepo}`);

            const repoConfig = {
                gitea_repo: giteaRepo,
                github_repo: githubRepo,
                sync_direction: 'bidirectional',
                sync_issues: true,
                sync_pull_requests: true
            };

            const success = await processRepository(repoConfig, config);
            process.exit(success ? 0 : 1);
        }

        // Handle continuous sync
        if (continuous) {
            await runContinuousSync(config);
            process.exit(0);
        }

        // Default: sync all repositories
        const success = await syncAllRepositories(config);
        process.exit(success ? 0 : 1);

    } catch (err) {
        logError(`Error running syncer: ${err.message}`);
        process.exit(1);
    }
}

// Run the main function
if (require.main === module) {
    main().catch(err => {
        logError(`Unhandled error: ${err.message}`);
        process.exit(1);
    });
}

module.exports = {
    loadConfig,
    syncAllRepositories,
    processRepository,
    syncRepositoryCode,
    logInfo,
    logError,
    logSuccess,
    logWarn
}; 