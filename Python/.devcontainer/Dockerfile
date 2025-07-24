# Use the official Python dev container base image with Python 3.11
FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

# Set environment variables for Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies for data science, cybersecurity, and general development
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # Build essentials and development tools
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    zip \
    unzip \
    # Network and cybersecurity tools
    tshark \
    wireshark-common \
    tcpdump \
    nmap \
    netcat \
    dnsutils \
    iputils-ping \
    traceroute \
    whois \
    # Database tools
    sqlite3 \
    postgresql-client \
    default-mysql-client \
    # Media and graphics libraries (for data visualization)
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    # Additional security and analysis tools
    hashdeep \
    binwalk \
    exiftool \
    file \
    binutils \
    bsdutils \
    # Python development dependencies
    python3-dev \
    python3-pip \
    python3-venv \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install additional cybersecurity tools via pip that integrate well with Python
RUN pip install --no-cache-dir \
    # Security analysis tools
    scapy \
    pycryptodome \
    cryptography \
    requests \
    beautifulsoup4 \
    # Network analysis
    python-nmap \
    netaddr \
    dpkt \
    pyshark \
    # Forensics and analysis
    yara-python \
    pefile \
    python-magic \
    # Additional useful tools
    click \
    tqdm \
    colorama

# Create a non-root user for development (if not already created by base image)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Ensure the user exists and has proper permissions
RUN if ! id -u $USERNAME > /dev/null 2>&1; then \
    groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME; \
    fi

# Set up workspace directory
WORKDIR /workspace

# Copy requirements file to leverage Docker cache
COPY requirements.txt /tmp/pip-tmp/

# Install Python packages from requirements.txt
# Using --user flag to install in user space for better caching
RUN pip install --user --no-cache-dir -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp

# Create common directories for projects
RUN mkdir -p /workspace/projects \
    && mkdir -p /workspace/notebooks \
    && mkdir -p /workspace/data \
    && mkdir -p /workspace/scripts \
    && mkdir -p /workspace/security-analysis \
    && chown -R $USERNAME:$USERNAME /workspace

# Set up Jupyter configuration and VS Code server directories
RUN mkdir -p /home/$USERNAME/.jupyter \
    && mkdir -p /home/$USERNAME/.vscode-server/extensions \
    && mkdir -p /home/$USERNAME/.vscode-server/data \
    && echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.port = 8888" >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.open_browser = False" >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.allow_root = True" >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.jupyter \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.vscode-server

# Install additional development tools via pip for the user
USER $USERNAME
RUN pip install --user \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets

# Switch back to root for any final setup
USER root

# Expose common ports
EXPOSE 8888 8000 5000 3000

# Set the default user for the container
USER $USERNAME

# Default command
CMD ["bash"] 