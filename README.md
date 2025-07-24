# DevContainers Repository

A comprehensive collection of development container templates for various programming languages and use cases. This repository is designed to provide ready-to-use, fully configured development environments that can be quickly spun up in VS Code or any compatible IDE.

## 🚀 Quick Start

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd DevContainers
   ```

2. **Open in VS Code**:
   - Install the "Dev Containers" extension in VS Code
   - Open the desired language directory (e.g., `Python/`)
   - VS Code will detect the dev container configuration
   - Click "Reopen in Container" when prompted

3. **Start developing**:
   - All dependencies and tools will be automatically installed
   - Extensions will be pre-configured
   - Your development environment is ready!

## 📁 Repository Structure

```
DevContainers/
├── README.md                          # This file - main documentation
├── .copilot-instructions.md            # AI assistant context and instructions
│
├── Python/                             # Python development environment
│   ├── .devcontainer/                  # Dev container configuration
│   │   ├── devcontainer.json          # VS Code dev container settings
│   │   ├── Dockerfile                 # Container image definition
│   │   └── docker-compose.yml         # Container orchestration
│   ├── requirements.txt               # Python dependencies
│   ├── projects/                      # Your Python projects go here
│   ├── notebooks/                     # Jupyter notebooks
│   ├── data/                          # Data files
│   ├── scripts/                       # Utility scripts
│   └── security-analysis/             # Cybersecurity analysis work
│
└── [Future Language Directories]      # Additional languages will be added here
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
