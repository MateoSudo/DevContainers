# DevContainers Repository

A comprehensive collection of development container templates for various programming languages and use cases. This repository is designed to provide ready-to-use, fully configured development environments that can be quickly spun up in VS Code or any compatible IDE.

## 🚀 Quick Start

### Option 1: Multi-Language Workspace (Recommended)
1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd DevContainers
   ```

2. **Open the workspace file**:
   ```bash
   code DevContainers.code-workspace
   ```
   This gives you access to all language environments with easy switching.

### Option 2: Root-Level Container
1. **Open repository root in VS Code**:
   ```bash
   code .
   ```
2. **Reopen in Container** when prompted (defaults to Python environment)

### Option 3: Individual Language Environment
1. **Navigate to specific language directory**:
   ```bash
   cd Python/  # or any other language directory
   code .
   ```
2. **Reopen in Container** when prompted

### Quick Access Tasks
- **Ctrl+Shift+P** → "Tasks: Run Task" → "🐍 Open Python Container"
- **Ctrl+Shift+P** → "Dev Containers: Reopen in Container"

## 📁 Repository Structure

```
DevContainers/
├── README.md                          # This file - main documentation
├── .copilot-instructions.md            # AI assistant context and instructions
├── DevContainers.code-workspace       # VS Code workspace for multi-language development
│
├── .devcontainer/                     # Root-level dev container configuration
│   └── devcontainer.json             # Multi-language container settings
├── .vscode/                           # Repository-wide VS Code settings
│   └── settings.json                 # Editor configuration and dev container settings
│
├── Python/                            # Python development environment
│   ├── .devcontainer/                 # Python-specific container configuration
│   │   ├── devcontainer.json         # VS Code dev container settings
│   │   ├── Dockerfile                # Container image definition
│   │   └── docker-compose.yml        # Container orchestration
│   ├── requirements.txt              # Python dependencies
│   ├── projects/                     # Your Python projects go here
│   ├── notebooks/                    # Jupyter notebooks
│   │   └── welcome.ipynb             # Demo notebook with examples
│   ├── scripts/                      # Example and utility scripts
│   │   ├── data_analysis_example.py  # Data science demo script
│   │   └── cybersecurity_example.py  # Security analysis demo script
│   ├── data/                         # Data files and analysis outputs
│   └── security-analysis/            # Cybersecurity analysis work
│
└── [Future Language Directories]     # Additional languages will be added here
    ├── JavaScript/
    ├── Java/
    ├── Go/
    └── ...
```

## 🐍 Python Development Environment

The Python dev container is a comprehensive setup for **Data Science** and **Cybersecurity** work.

### Features

#### 🔬 Data Science Tools
- **Python 3.11** with optimized performance
- **Core Libraries**: pandas, numpy, scipy, scikit-learn
- **Deep Learning**: PyTorch with CUDA support
- **Visualization**: matplotlib, seaborn, plotly, bokeh
- **Databases**: SQLAlchemy, psycopg2, pymongo
- **Jupyter**: Full JupyterLab and notebook support

#### 🔒 Cybersecurity Tools
- **Network Analysis**: tshark, nmap, scapy, pyshark
- **Packet Analysis**: tcpdump, wireshark tools
- **Cryptography**: cryptography, pycryptodome
- **File Analysis**: binwalk, exiftool, python-magic
- **Forensics**: yara-python, pefile
- **Network Utilities**: netcat, traceroute, whois

#### 🛠 Development Tools
- **Code Quality**: black, pylint, flake8, mypy, bandit
- **Testing**: pytest with coverage
- **Documentation**: sphinx, mkdocs
- **Version Control**: git, GitHub CLI

#### 🎯 VS Code Extensions (Pre-installed)
- Python extension pack with Pylance
- Jupyter notebooks support
- GitHub Copilot and Copilot Chat
- GitLens for advanced git features
- Prettier and formatting tools
- Docker tools and remote development
- Security and code quality extensions

### Quick Usage

1. **Navigate to Python directory**:
   ```bash
   cd Python/
   ```

2. **Open in VS Code**:
   ```bash
   code .
   ```

3. **Reopen in Container** when prompted

4. **Start Jupyter Lab** (optional):
   ```bash
   jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
   ```
   Access at: http://localhost:8888

### Directory Organization

- **`projects/`**: Place your main Python projects here
- **`notebooks/`**: Jupyter notebooks for analysis and experimentation
- **`data/`**: Store datasets and data files
- **`scripts/`**: Utility scripts and automation
- **`security-analysis/`**: Cybersecurity analysis, packet captures, etc.

### Package Management

The environment uses `requirements.txt` for package management:

```bash
# Install new packages
pip install package-name

# Update requirements.txt
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

### Cybersecurity Usage Examples

```python
# Network packet analysis
import scapy.all as scapy
packets = scapy.rdpcap('capture.pcap')

# Network scanning
import nmap
nm = nmap.PortScanner()
nm.scan('192.168.1.0/24', '22-443')

# File analysis
import magic
file_type = magic.from_file('suspicious_file.exe')
```

## 🔧 Customization

### Adding New Packages

1. **Python packages**: Add to `Python/requirements.txt`
2. **System packages**: Modify `Python/.devcontainer/Dockerfile`
3. **VS Code extensions**: Update `Python/.devcontainer/devcontainer.json`

### Container Configuration

- **Ports**: Modify `forwardPorts` in `devcontainer.json`
- **Environment variables**: Update `containerEnv` section
- **Volume mounts**: Adjust `mounts` in `devcontainer.json`
- **Capabilities**: Modify `cap_add` in `docker-compose.yml`

### Performance Optimization

The containers are optimized for performance:
- **Volume caching**: Dependencies persist between container restarts
- **Layer caching**: Docker layers are optimized for rebuild speed
- **Extension persistence**: VS Code extensions don't re-download
- **Pip caching**: Python packages cache for faster installs

## 🔧 Working with Multiple Containers

### Three Ways to Use This Repository

#### 1. **VS Code Workspace (Best for Multi-Language Development)**
Open `DevContainers.code-workspace` to work with multiple language environments:
- See all language directories in one workspace
- Easy switching between environments
- Pre-configured tasks for container management
- Consistent settings across all languages

#### 2. **Root-Level Container (Quick Python Access)**
Open the repository root and use the default container:
- Automatically opens Python environment
- Good for quick Python development
- Access to all repository files

#### 3. **Individual Language Containers (Focused Development)**
Navigate to specific language directories:
- Optimized for single-language development  
- Language-specific extensions and settings
- Isolated environments

### VS Code Workspace Features

The `DevContainers.code-workspace` provides:
- **📁 Organized folder structure** with emojis for easy identification
- **⚡ Quick tasks** to open specific containers
- **🔧 Build commands** for all containers
- **📝 Consistent settings** across all environments
- **🎯 Extension recommendations** for each language

### Container Management Tasks

Access via **Ctrl+Shift+P** → "Tasks: Run Task":
- **🐍 Open Python Container**: Opens Python environment in new window
- **🔧 Build All Containers**: Rebuilds all development containers
- **🧹 Clean Docker Resources**: Cleanup unused Docker resources

## 🚀 Advanced Usage

### Running Multiple Containers

You can run multiple language environments simultaneously:

```bash
# Terminal 1: Python environment
cd Python/
code .

# Terminal 2: Future JavaScript environment
cd JavaScript/
code .
```

### Custom Docker Commands

```bash
# Build the container manually
cd Python/.devcontainer/
docker-compose build

# Run container with custom command
docker-compose run python-dev python script.py

# Access running container
docker-compose exec python-dev bash
```

### Networking and Security

The Python container includes special capabilities for cybersecurity work:
- `NET_ADMIN` and `NET_RAW` capabilities for packet analysis
- Network tools accessible from within the container
- Secure by default - privileged mode disabled unless needed

## 🔍 Troubleshooting

### Common Issues

1. **Container won't start**:
   - Check Docker is running
   - Verify no port conflicts (8888, 8000, 5000, 3000)
   - Try rebuilding: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

2. **Packages not installing**:
   - Check internet connection
   - Verify `requirements.txt` syntax
   - Try rebuilding container from scratch

3. **VS Code extensions not loading**:
   - Ensure Dev Containers extension is installed
   - Check extension marketplace connectivity
   - Try "Dev Containers: Reload Window"

4. **Jupyter not accessible**:
   - Verify port 8888 is forwarded
   - Check Jupyter is running: `jupyter lab list`
   - Access via http://localhost:8888

### Getting Help

- Check the `.copilot-instructions.md` file for AI assistant context
- Review container logs: `docker-compose logs python-dev`
- Rebuild from scratch if needed: "Dev Containers: Rebuild Container"

## 🤝 Contributing

### Adding New Languages

1. Create a new directory (e.g., `JavaScript/`)
2. Add `.devcontainer/` configuration
3. Include language-specific requirements file
4. Update this README with new language documentation
5. Test the setup thoroughly

### Improving Existing Containers

1. Fork the repository
2. Make your improvements
3. Test in a fresh environment
4. Submit a pull request with detailed description

## 📚 Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Python Package Index (PyPI)](https://pypi.org/)
- [Cybersecurity Python Libraries](https://github.com/topics/cybersecurity-python)

## 🏷 Tags

`dev-containers` `docker` `vscode` `python` `data-science` `cybersecurity` `development-environment` `jupyter` `pytorch` `pandas` `tshark` `nmap` `scapy`

---

## 📝 Version History

- **v1.0.0**: Initial Python 3.11 container with data science and cybersecurity tools
- **Future**: JavaScript, Java, Go containers planned

---

**Happy Coding! 🎉**

*This repository is designed to get you up and running quickly with a fully configured development environment. If you have suggestions or run into issues, please open an issue or contribute improvements.*
