#!/usr/bin/env python3
"""
Unit tests for Gitea-GitHub sync scripts.
Tests the functionality of both Python and shell script versions.
"""

import unittest
import tempfile
import os
import json
import yaml
import subprocess
from unittest.mock import patch, MagicMock
import sys

# Add the scripts directory to Python path for testing
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

try:
    from gitea_github_sync import GitRepoSyncer
except ImportError:
    # Handle case where dependencies aren't installed
    GitRepoSyncer = None


class TestGiteaGithubSync(unittest.TestCase):
    """Test cases for the Gitea-GitHub sync functionality."""
    
    def setUp(self):
        """Set up test environment."""
        self.test_dir = tempfile.mkdtemp()
        self.config_file = os.path.join(self.test_dir, 'test_config.yaml')
        self.shell_config_file = os.path.join(self.test_dir, 'test_config.json')
    
    def tearDown(self):
        """Clean up test environment."""
        import shutil
        shutil.rmtree(self.test_dir, ignore_errors=True)
    
    def test_config_template_creation_yaml(self):
        """Test YAML configuration template creation."""
        if GitRepoSyncer is None:
            self.skipTest("GitRepoSyncer not available")
        
        # Create a syncer instance that should generate config template
        with self.assertRaises(SystemExit):
            GitRepoSyncer(self.config_file)
        
        # Verify config file was created
        self.assertTrue(os.path.exists(self.config_file))
        
        # Verify config file is valid YAML
        with open(self.config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        # Check required sections exist
        self.assertIn('gitea', config)
        self.assertIn('github', config)
        self.assertIn('repositories', config)
        self.assertIn('sync_settings', config)
    
    def test_shell_script_config_creation(self):
        """Test shell script configuration template creation."""
        script_path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea-github-sync.sh')
        
        if not os.path.exists(script_path):
            self.skipTest("Shell script not available")
        
        # Test that the script can create a config template
        result = subprocess.run(
            [script_path, '--init'],
            cwd=self.test_dir,
            capture_output=True,
            text=True
        )
        
        # Should exit with 0 when creating config
        self.assertEqual(result.returncode, 0)
        
        # Check that config file was created
        config_file = os.path.join(self.test_dir, 'sync_config.json')
        self.assertTrue(os.path.exists(config_file))
        
        # Verify config file is valid JSON
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        # Check required sections exist
        self.assertIn('gitea', config)
        self.assertIn('github', config)
        self.assertIn('repositories', config)
        self.assertIn('sync_settings', config)
    
    def test_shell_script_help(self):
        """Test that shell script shows help correctly."""
        script_path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea-github-sync.sh')
        
        if not os.path.exists(script_path):
            self.skipTest("Shell script not available")
        
        # Test help flag
        result = subprocess.run(
            [script_path, '--help'],
            capture_output=True,
            text=True
        )
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('Bidirectional sync script', result.stdout)
        self.assertIn('Usage:', result.stdout)
    
    def test_python_script_help(self):
        """Test that Python script shows help correctly."""
        script_path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea_github_sync.py')
        
        if not os.path.exists(script_path):
            self.skipTest("Python script not available")
        
        # Test help flag
        result = subprocess.run(
            [sys.executable, script_path, '--help'],
            capture_output=True,
            text=True
        )
        
        self.assertEqual(result.returncode, 0)
        self.assertIn('Bidirectional sync between Gitea and GitHub', result.stdout)
    
    @unittest.skipIf(GitRepoSyncer is None, "GitRepoSyncer not available")
    def test_config_validation(self):
        """Test configuration validation."""
        # Create a valid config
        config = {
            'gitea': {
                'url': 'https://gitea.example.com',
                'username': 'testuser',
                'token': 'testtoken'
            },
            'github': {
                'username': 'testuser',
                'token': 'testtoken'
            },
            'repositories': [
                {
                    'gitea_repo': 'test/repo',
                    'github_repo': 'test/repo',
                    'sync_direction': 'bidirectional'
                }
            ],
            'sync_settings': {
                'dry_run': True
            }
        }
        
        with open(self.config_file, 'w') as f:
            yaml.dump(config, f)
        
        # Should create syncer without error
        syncer = GitRepoSyncer(self.config_file)
        self.assertIsNotNone(syncer)
        self.assertEqual(syncer.config['gitea']['url'], 'https://gitea.example.com')
    
    @unittest.skipIf(GitRepoSyncer is None, "GitRepoSyncer not available")
    def test_invalid_config_validation(self):
        """Test that invalid configuration raises appropriate errors."""
        # Create an invalid config (missing required fields)
        config = {
            'gitea': {
                'url': 'https://gitea.example.com'
                # Missing username and token
            }
        }
        
        with open(self.config_file, 'w') as f:
            yaml.dump(config, f)
        
        # Should raise SystemExit due to missing required fields
        with self.assertRaises(SystemExit):
            GitRepoSyncer(self.config_file)
    
    def test_scripts_are_executable(self):
        """Test that scripts have executable permissions."""
        script_paths = [
            os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea-github-sync.sh'),
            os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea_github_sync.py')
        ]
        
        for script_path in script_paths:
            if os.path.exists(script_path):
                # Check if file is executable
                self.assertTrue(os.access(script_path, os.X_OK), 
                              f"Script {script_path} should be executable")
    
    def test_container_environment_awareness(self):
        """Test that scripts are aware of container environment."""
        # This test checks for container-specific environment handling
        
        # Set container-like environment variables
        test_env = os.environ.copy()
        test_env['DATABASE_URL'] = 'postgresql://postgres:postgres@db:5432/devdb'
        test_env['REDIS_URL'] = 'redis://redis:6379'
        
        script_path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea-github-sync.sh')
        
        if os.path.exists(script_path):
            # Test that script can handle container environment
            result = subprocess.run(
                [script_path, '--help'],
                env=test_env,
                capture_output=True,
                text=True
            )
            
            # Should still work with container environment
            self.assertEqual(result.returncode, 0)


class TestSyncScriptIntegration(unittest.TestCase):
    """Integration tests for sync script functionality."""
    
    def test_dry_run_functionality(self):
        """Test that dry run mode works correctly."""
        script_path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'gitea-github-sync.sh')
        
        if not os.path.exists(script_path):
            self.skipTest("Shell script not available")
        
        with tempfile.TemporaryDirectory() as test_dir:
            # Create a test config
            config = {
                "gitea": {
                    "url": "https://gitea.example.com",
                    "username": "testuser",
                    "token": "testtoken"
                },
                "github": {
                    "username": "testuser",
                    "token": "testtoken"
                },
                "repositories": [
                    {
                        "gitea_repo": "test/repo",
                        "github_repo": "test/repo",
                        "sync_direction": "bidirectional"
                    }
                ],
                "sync_settings": {
                    "dry_run": True
                }
            }
            
            config_file = os.path.join(test_dir, 'sync_config.json')
            with open(config_file, 'w') as f:
                json.dump(config, f)
            
            # Test dry run mode
            result = subprocess.run(
                [script_path, '--config', config_file, '--dry-run'],
                cwd=test_dir,
                capture_output=True,
                text=True
            )
            
            # Dry run should indicate what would be done
            self.assertIn('DRY RUN', result.stdout + result.stderr)


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2) 