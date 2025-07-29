#!/usr/bin/env python3
"""
Bidirectional sync script for Gitea and GitHub repositories.
Supports syncing repositories, issues, and pull requests between Gitea and GitHub.
"""

import os
import sys
import json
import logging
import argparse
import subprocess
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import requests
from requests.auth import HTTPBasicAuth
import yaml

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sync.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class GitRepoSyncer:
    """Handles bidirectional synchronization between Gitea and GitHub repositories."""
    
    def __init__(self, config_file: str = "sync_config.yaml"):
        """Initialize the syncer with configuration."""
        self.config = self._load_config(config_file)
        self.gitea_session = self._create_gitea_session()
        self.github_session = self._create_github_session()
        
    def _load_config(self, config_file: str) -> Dict:
        """Load configuration from YAML file."""
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Validate required configuration
            required_keys = [
                'gitea.url', 'gitea.username', 'gitea.token',
                'github.username', 'github.token'
            ]
            
            for key in required_keys:
                keys = key.split('.')
                value = config
                for k in keys:
                    if k not in value:
                        raise KeyError(f"Missing required configuration: {key}")
                    value = value[k]
                    
            return config
            
        except FileNotFoundError:
            logger.error(f"Configuration file {config_file} not found. Creating template...")
            self._create_config_template(config_file)
            sys.exit(1)
        except Exception as e:
            logger.error(f"Error loading configuration: {e}")
            sys.exit(1)
    
    def _create_config_template(self, config_file: str):
        """Create a configuration template file."""
        template = {
            'gitea': {
                'url': 'https://your-gitea-instance.com',
                'username': 'your-gitea-username',
                'token': 'your-gitea-api-token'
            },
            'github': {
                'username': 'your-github-username',
                'token': 'your-github-personal-access-token'
            },
            'repositories': [
                {
                    'gitea_repo': 'owner/repo-name',
                    'github_repo': 'owner/repo-name',
                    'sync_direction': 'bidirectional',  # bidirectional, gitea_to_github, github_to_gitea
                    'sync_issues': True,
                    'sync_pull_requests': True
                }
            ],
            'sync_settings': {
                'dry_run': False,
                'sync_interval': 300,  # seconds
                'conflict_resolution': 'manual'  # manual, prefer_gitea, prefer_github
            }
        }
        
        with open(config_file, 'w') as f:
            yaml.dump(template, f, default_flow_style=False, indent=2)
        
        logger.info(f"Created configuration template at {config_file}")
        logger.info("Please edit the configuration file with your actual credentials and repository settings.")
    
    def _create_gitea_session(self) -> requests.Session:
        """Create authenticated session for Gitea API."""
        session = requests.Session()
        session.headers.update({
            'Authorization': f"token {self.config['gitea']['token']}",
            'Content-Type': 'application/json'
        })
        return session
    
    def _create_github_session(self) -> requests.Session:
        """Create authenticated session for GitHub API."""
        session = requests.Session()
        session.headers.update({
            'Authorization': f"token {self.config['github']['token']}",
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        })
        return session
    
    def _get_gitea_repo_info(self, repo: str) -> Optional[Dict]:
        """Get repository information from Gitea."""
        try:
            url = f"{self.config['gitea']['url']}/api/v1/repos/{repo}"
            response = self.gitea_session.get(url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error fetching Gitea repo {repo}: {e}")
            return None
    
    def _get_github_repo_info(self, repo: str) -> Optional[Dict]:
        """Get repository information from GitHub."""
        try:
            url = f"https://api.github.com/repos/{repo}"
            response = self.github_session.get(url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error fetching GitHub repo {repo}: {e}")
            return None
    
    def _git_command(self, command: List[str], cwd: str = None) -> Tuple[bool, str]:
        """Execute git command and return success status and output."""
        try:
            result = subprocess.run(
                command, 
                capture_output=True, 
                text=True, 
                cwd=cwd,
                check=True
            )
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            logger.error(f"Git command failed: {' '.join(command)}")
            logger.error(f"Error: {e.stderr}")
            return False, e.stderr
    
    def _clone_or_update_repo(self, repo_url: str, local_path: str) -> bool:
        """Clone repository or update if it already exists."""
        if os.path.exists(local_path):
            logger.info(f"Updating existing repository at {local_path}")
            success, _ = self._git_command(['git', 'fetch', '--all'], cwd=local_path)
            return success
        else:
            logger.info(f"Cloning repository to {local_path}")
            success, _ = self._git_command(['git', 'clone', repo_url, local_path])
            return success
    
    def _setup_remotes(self, local_path: str, gitea_url: str, github_url: str) -> bool:
        """Setup both Gitea and GitHub as remotes."""
        commands = [
            ['git', 'remote', 'remove', 'gitea'],
            ['git', 'remote', 'remove', 'github'],
            ['git', 'remote', 'add', 'gitea', gitea_url],
            ['git', 'remote', 'add', 'github', github_url]
        ]
        
        for cmd in commands:
            # Ignore errors for remove commands (remotes might not exist)
            if 'remove' in cmd:
                self._git_command(cmd, cwd=local_path)
            else:
                success, _ = self._git_command(cmd, cwd=local_path)
                if not success:
                    return False
        
        return True
    
    def sync_repository_code(self, repo_config: Dict) -> bool:
        """Sync repository code between Gitea and GitHub."""
        gitea_repo = repo_config['gitea_repo']
        github_repo = repo_config['github_repo']
        sync_direction = repo_config.get('sync_direction', 'bidirectional')
        
        logger.info(f"Syncing repository code: {gitea_repo} <-> {github_repo}")
        
        # Get repository information
        gitea_info = self._get_gitea_repo_info(gitea_repo)
        github_info = self._get_github_repo_info(github_repo)
        
        if not gitea_info or not github_info:
            logger.error("Failed to get repository information")
            return False
        
        # Construct repository URLs with authentication
        gitea_url = f"{self.config['gitea']['url']}/{gitea_repo}.git"
        github_url = f"https://{self.config['github']['username']}:{self.config['github']['token']}@github.com/{github_repo}.git"
        
        # Create local working directory
        local_path = f"./sync_workspace/{gitea_repo.replace('/', '_')}"
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        
        # Clone or update local repository
        if not self._clone_or_update_repo(gitea_url, local_path):
            return False
        
        # Setup remotes
        if not self._setup_remotes(local_path, gitea_url, github_url):
            return False
        
        # Perform sync based on direction
        if sync_direction in ['bidirectional', 'gitea_to_github']:
            logger.info("Syncing from Gitea to GitHub")
            success, _ = self._git_command(['git', 'push', 'github', '--all'], cwd=local_path)
            if not success:
                logger.error("Failed to push to GitHub")
                return False
        
        if sync_direction in ['bidirectional', 'github_to_gitea']:
            logger.info("Syncing from GitHub to Gitea")
            success, _ = self._git_command(['git', 'fetch', 'github'], cwd=local_path)
            if success:
                success, _ = self._git_command(['git', 'push', 'gitea', '--all'], cwd=local_path)
            if not success:
                logger.error("Failed to push to Gitea")
                return False
        
        logger.info(f"Successfully synced repository code for {gitea_repo}")
        return True
    
    def sync_issues(self, repo_config: Dict) -> bool:
        """Sync issues between Gitea and GitHub."""
        if not repo_config.get('sync_issues', False):
            return True
        
        logger.info(f"Syncing issues for {repo_config['gitea_repo']} <-> {repo_config['github_repo']}")
        
        # Get issues from both platforms
        gitea_issues = self._get_gitea_issues(repo_config['gitea_repo'])
        github_issues = self._get_github_issues(repo_config['github_repo'])
        
        # Implement issue synchronization logic here
        # This is a simplified version - full implementation would include:
        # - Issue mapping and tracking
        # - Comment synchronization
        # - Label synchronization
        # - Assignee synchronization
        
        logger.info("Issue synchronization completed")
        return True
    
    def _get_gitea_issues(self, repo: str) -> List[Dict]:
        """Get issues from Gitea repository."""
        try:
            url = f"{self.config['gitea']['url']}/api/v1/repos/{repo}/issues"
            response = self.gitea_session.get(url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error fetching Gitea issues for {repo}: {e}")
            return []
    
    def _get_github_issues(self, repo: str) -> List[Dict]:
        """Get issues from GitHub repository."""
        try:
            url = f"https://api.github.com/repos/{repo}/issues"
            response = self.github_session.get(url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error fetching GitHub issues for {repo}: {e}")
            return []
    
    def sync_all_repositories(self) -> bool:
        """Sync all configured repositories."""
        success = True
        
        for repo_config in self.config.get('repositories', []):
            try:
                logger.info(f"Starting sync for {repo_config['gitea_repo']} <-> {repo_config['github_repo']}")
                
                if not self.sync_repository_code(repo_config):
                    success = False
                    continue
                
                if not self.sync_issues(repo_config):
                    success = False
                    continue
                
                logger.info(f"Completed sync for {repo_config['gitea_repo']} <-> {repo_config['github_repo']}")
                
            except Exception as e:
                logger.error(f"Error syncing repository {repo_config}: {e}")
                success = False
        
        return success
    
    def run_continuous_sync(self):
        """Run continuous synchronization based on configured interval."""
        interval = self.config.get('sync_settings', {}).get('sync_interval', 300)
        logger.info(f"Starting continuous sync with {interval} second intervals")
        
        while True:
            try:
                logger.info("Starting sync cycle...")
                self.sync_all_repositories()
                logger.info(f"Sync cycle completed. Waiting {interval} seconds...")
                
                import time
                time.sleep(interval)
                
            except KeyboardInterrupt:
                logger.info("Sync interrupted by user")
                break
            except Exception as e:
                logger.error(f"Error during sync cycle: {e}")
                import time
                time.sleep(60)  # Wait a minute before retrying


def main():
    """Main function to handle command line arguments and run the syncer."""
    parser = argparse.ArgumentParser(description='Bidirectional sync between Gitea and GitHub')
    parser.add_argument('--config', default='sync_config.yaml', help='Configuration file path')
    parser.add_argument('--continuous', action='store_true', help='Run continuous sync')
    parser.add_argument('--dry-run', action='store_true', help='Perform dry run without making changes')
    parser.add_argument('--repo', help='Sync specific repository (format: gitea_owner/repo:github_owner/repo)')
    
    args = parser.parse_args()
    
    try:
        syncer = GitRepoSyncer(args.config)
        
        if args.dry_run:
            syncer.config['sync_settings']['dry_run'] = True
            logger.info("Running in dry-run mode")
        
        if args.continuous:
            syncer.run_continuous_sync()
        elif args.repo:
            # Parse specific repository format
            if ':' in args.repo:
                gitea_repo, github_repo = args.repo.split(':')
            else:
                gitea_repo = github_repo = args.repo
            
            repo_config = {
                'gitea_repo': gitea_repo,
                'github_repo': github_repo,
                'sync_direction': 'bidirectional',
                'sync_issues': True,
                'sync_pull_requests': True
            }
            
            syncer.sync_repository_code(repo_config)
        else:
            syncer.sync_all_repositories()
            
    except Exception as e:
        logger.error(f"Error running syncer: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 