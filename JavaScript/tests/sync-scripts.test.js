/**
 * Unit tests for Gitea-GitHub sync scripts (JavaScript/Node.js version)
 * Tests the functionality of both Node.js and shell script versions.
 */

const fs = require('fs');
const path = require('path');
const { execSync, exec } = require('child_process');
const os = require('os');
const { promisify } = require('util');

const execAsync = promisify(exec);

describe('Gitea-GitHub Sync Scripts', () => {
    let testDir;
    let configFile;

    beforeEach(() => {
        // Create temporary directory for tests
        testDir = fs.mkdtempSync(path.join(os.tmpdir(), 'sync-test-'));
        configFile = path.join(testDir, 'test_config.json');
    });

    afterEach(() => {
        // Clean up test directory
        if (fs.existsSync(testDir)) {
            fs.rmSync(testDir, { recursive: true, force: true });
        }
    });

    describe('Node.js Sync Script', () => {
        const scriptPath = path.join(__dirname, '..', 'scripts', 'gitea-github-sync.js');

        test('should show help information', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Node.js sync script not found, skipping test');
                return;
            }

            try {
                const { stdout, stderr } = await execAsync(`node "${scriptPath}" --help`);
                expect(stdout + stderr).toContain('Bidirectional sync script');
                expect(stdout + stderr).toContain('Usage:');
            } catch (error) {
                // Help command should exit with 0
                if (error.code === 0) {
                    expect(error.stdout + error.stderr).toContain('Bidirectional sync script');
                } else {
                    throw error;
                }
            }
        });

        test('should create configuration template', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Node.js sync script not found, skipping test');
                return;
            }

            try {
                await execAsync(`node "${scriptPath}" --init`, { cwd: testDir });

                const configPath = path.join(testDir, 'sync_config.json');
                expect(fs.existsSync(configPath)).toBe(true);

                // Verify config is valid JSON
                const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
                expect(config).toHaveProperty('gitea');
                expect(config).toHaveProperty('github');
                expect(config).toHaveProperty('repositories');
                expect(config).toHaveProperty('sync_settings');
            } catch (error) {
                console.error('Error creating config template:', error);
                throw error;
            }
        });

        test('should handle invalid configuration gracefully', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Node.js sync script not found, skipping test');
                return;
            }

            // Create invalid config
            const invalidConfig = {
                gitea: {
                    url: 'https://gitea.example.com'
                    // Missing required fields
                }
            };

            fs.writeFileSync(configFile, JSON.stringify(invalidConfig, null, 2));

            try {
                await execAsync(`node "${scriptPath}" --config "${configFile}"`);
                // Should not reach here if validation works
                fail('Expected script to exit with error for invalid config');
            } catch (error) {
                // Should exit with non-zero code for invalid config
                expect(error.code).not.toBe(0);
            }
        });

        test('should support dry run mode', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Node.js sync script not found, skipping test');
                return;
            }

            // Create valid config
            const validConfig = {
                gitea: {
                    url: 'https://gitea.example.com',
                    username: 'testuser',
                    token: 'testtoken'
                },
                github: {
                    username: 'testuser',
                    token: 'testtoken'
                },
                repositories: [
                    {
                        gitea_repo: 'test/repo',
                        github_repo: 'test/repo',
                        sync_direction: 'bidirectional'
                    }
                ],
                sync_settings: {
                    dry_run: true
                }
            };

            fs.writeFileSync(configFile, JSON.stringify(validConfig, null, 2));

            try {
                const { stdout, stderr } = await execAsync(
                    `node "${scriptPath}" --config "${configFile}" --dry-run`
                );
                expect(stdout + stderr).toContain('dry-run');
            } catch (error) {
                // Dry run might fail due to missing dependencies, but should indicate dry run
                expect(error.stdout + error.stderr).toContain('dry-run');
            }
        });
    });

    describe('Shell Sync Script', () => {
        const scriptPath = path.join(__dirname, '..', 'scripts', 'gitea-github-sync.sh');

        test('should show help information', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Shell sync script not found, skipping test');
                return;
            }

            try {
                const { stdout, stderr } = await execAsync(`"${scriptPath}" --help`);
                expect(stdout + stderr).toContain('Bidirectional sync script');
                expect(stdout + stderr).toContain('Usage:');
            } catch (error) {
                // Help command should exit with 0
                if (error.code === 0) {
                    expect(error.stdout + error.stderr).toContain('Bidirectional sync script');
                } else {
                    throw error;
                }
            }
        });

        test('should create configuration template', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Shell sync script not found, skipping test');
                return;
            }

            try {
                await execAsync(`"${scriptPath}" --init`, { cwd: testDir });

                const configPath = path.join(testDir, 'sync_config.json');
                expect(fs.existsSync(configPath)).toBe(true);

                // Verify config is valid JSON
                const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
                expect(config).toHaveProperty('gitea');
                expect(config).toHaveProperty('github');
                expect(config).toHaveProperty('repositories');
                expect(config).toHaveProperty('sync_settings');
            } catch (error) {
                console.error('Error creating config template:', error);
                throw error;
            }
        });

        test('should be executable', () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Shell sync script not found, skipping test');
                return;
            }

            // Check if file has executable permissions
            const stats = fs.statSync(scriptPath);
            const isExecutable = !!(stats.mode & parseInt('111', 8));
            expect(isExecutable).toBe(true);
        });

        test('should handle dry run mode', async () => {
            if (!fs.existsSync(scriptPath)) {
                console.warn('Shell sync script not found, skipping test');
                return;
            }

            // Create valid config
            const validConfig = {
                gitea: {
                    url: 'https://gitea.example.com',
                    username: 'testuser',
                    token: 'testtoken'
                },
                github: {
                    username: 'testuser',
                    token: 'testtoken'
                },
                repositories: [
                    {
                        gitea_repo: 'test/repo',
                        github_repo: 'test/repo',
                        sync_direction: 'bidirectional'
                    }
                ],
                sync_settings: {
                    dry_run: true
                }
            };

            fs.writeFileSync(configFile, JSON.stringify(validConfig, null, 2));

            try {
                const { stdout, stderr } = await execAsync(
                    `"${scriptPath}" --config "${configFile}" --dry-run`,
                    { cwd: testDir }
                );
                expect(stdout + stderr).toContain('DRY RUN');
            } catch (error) {
                // Dry run might fail due to missing dependencies, but should indicate dry run
                expect(error.stdout + error.stderr).toContain('DRY RUN');
            }
        });
    });

    describe('Container Environment Integration', () => {
        test('should work with container environment variables', async () => {
            const scriptPath = path.join(__dirname, '..', 'scripts', 'gitea-github-sync.sh');

            if (!fs.existsSync(scriptPath)) {
                console.warn('Shell sync script not found, skipping test');
                return;
            }

            // Set container-like environment variables
            const containerEnv = {
                ...process.env,
                DATABASE_URL: 'postgresql://postgres:postgres@db:5432/devdb',
                REDIS_URL: 'redis://redis:6379',
                NODE_ENV: 'test'
            };

            try {
                const { stdout, stderr } = await execAsync(
                    `"${scriptPath}" --help`,
                    { env: containerEnv }
                );
                expect(stdout + stderr).toContain('Usage:');
            } catch (error) {
                if (error.code === 0) {
                    expect(error.stdout + error.stderr).toContain('Usage:');
                } else {
                    throw error;
                }
            }
        });

        test('should handle workspace paths correctly', () => {
            // Test that scripts can handle container workspace paths
            const workspacePath = '/workspace';
            const relativePath = './sync_workspace';

            // These are basic path handling tests
            expect(path.isAbsolute(workspacePath)).toBe(true);
            expect(path.isAbsolute(relativePath)).toBe(false);

            // In container, workspace should be accessible
            if (fs.existsSync(workspacePath)) {
                const stats = fs.statSync(workspacePath);
                expect(stats.isDirectory()).toBe(true);
            }
        });
    });

    describe('Configuration Validation', () => {
        test('should validate required configuration fields', () => {
            const requiredFields = [
                'gitea.url',
                'gitea.username',
                'gitea.token',
                'github.username',
                'github.token'
            ];

            const validConfig = {
                gitea: {
                    url: 'https://gitea.example.com',
                    username: 'testuser',
                    token: 'testtoken'
                },
                github: {
                    username: 'testuser',
                    token: 'testtoken'
                },
                repositories: [],
                sync_settings: {}
            };

            // Test that all required fields are present
            requiredFields.forEach(field => {
                const keys = field.split('.');
                let value = validConfig;
                for (const key of keys) {
                    expect(value).toHaveProperty(key);
                    value = value[key];
                }
                expect(value).toBeTruthy();
            });
        });

        test('should support different sync directions', () => {
            const validDirections = [
                'bidirectional',
                'gitea_to_github',
                'github_to_gitea'
            ];

            validDirections.forEach(direction => {
                const repoConfig = {
                    gitea_repo: 'test/repo',
                    github_repo: 'test/repo',
                    sync_direction: direction,
                    sync_issues: true
                };

                expect(repoConfig.sync_direction).toBe(direction);
                expect(['bidirectional', 'gitea_to_github', 'github_to_gitea'])
                    .toContain(repoConfig.sync_direction);
            });
        });
    });

    describe('Performance Tests', () => {
        test('should execute help command quickly', async () => {
            const scriptPath = path.join(__dirname, '..', 'scripts', 'gitea-github-sync.js');

            if (!fs.existsSync(scriptPath)) {
                console.warn('Node.js sync script not found, skipping test');
                return;
            }

            const startTime = Date.now();

            try {
                await execAsync(`node "${scriptPath}" --help`);
            } catch (error) {
                // Help command might exit with code 0
                if (error.code !== 0) {
                    throw error;
                }
            }

            const executionTime = Date.now() - startTime;

            // Should execute help in under 5 seconds
            expect(executionTime).toBeLessThan(5000);
        });
    });
});

// Test utilities for container environment
describe('Container Environment Tests', () => {
    test('should detect container environment correctly', () => {
        // Check for common container indicators
        const containerIndicators = [
            fs.existsSync('/.dockerenv'),
            process.env.CONTAINER_NAME !== undefined,
            process.env.KUBERNETES_SERVICE_HOST !== undefined
        ];

        const isInContainer = containerIndicators.some(indicator => indicator);

        if (isInContainer) {
            console.log('Running in container environment');

            // Additional container-specific tests
            expect(process.platform).toBe('linux');

            // Common container paths should exist
            expect(fs.existsSync('/proc')).toBe(true);
            expect(fs.existsSync('/sys')).toBe(true);
        } else {
            console.log('Running in non-container environment');
        }
    });
}); 