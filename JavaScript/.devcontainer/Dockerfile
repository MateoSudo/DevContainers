# Next.js T3 Stack Development Container
# Optimized for fast rebuilds and development efficiency

# Use the official Node.js LTS image as base
FROM node:18-bullseye-slim

# Set environment variables
ENV NODE_ENV=development \
    PNPM_HOME="/pnpm" \
    PATH="$PNPM_HOME:$PATH" \
    NEXT_TELEMETRY_DISABLED=1 \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Install system dependencies and development tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # Build essentials
    build-essential \
    python3 \
    python3-pip \
    # Git and version control
    git \
    openssh-client \
    # Utilities
    curl \
    wget \
    vim \
    nano \
    tree \
    jq \
    # Database clients
    postgresql-client \
    # Process management
    procps \
    # SSL certificates
    ca-certificates \
    # Cleanup
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install global npm packages for enhanced development
RUN npm install -g \
    pnpm@latest \
    yarn@latest \
    npm-check-updates \
    vercel \
    prisma \
    @next/codemod \
    create-t3-app@latest

# Create a non-root user
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Ensure the node user has the correct UID/GID
RUN if [ "$USER_UID" != "1000" ] || [ "$USER_GID" != "1000" ]; then \
    groupmod --gid $USER_GID node \
    && usermod --uid $USER_UID --gid $USER_GID node \
    && chown -R $USER_UID:$USER_GID /home/node; \
    fi

# Set up workspace directory
WORKDIR /workspace

# Copy package files first for better caching
# This layer will only rebuild when package files change
COPY package*.json ./
COPY pnpm-lock.yaml* ./
COPY yarn.lock* ./

# Install dependencies as root to avoid permission issues
# This is a critical optimization - dependencies are cached in this layer
RUN if [ -f pnpm-lock.yaml ]; then \
    corepack enable pnpm && pnpm install --frozen-lockfile; \
    elif [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile; \
    else \
    npm ci; \
    fi

# Create common project directories
RUN mkdir -p \
    src/components \
    src/pages \
    src/lib \
    src/utils \
    src/styles \
    src/types \
    public \
    prisma \
    docs \
    && chown -R $USERNAME:$USERNAME /workspace

# Set up Git configuration template
RUN git config --system --add safe.directory /workspace

# Configure npm/pnpm settings for the user
USER $USERNAME
RUN npm config set update-notifier false \
    && npm config set fund false

# Set up shell enhancements for better DX
RUN echo 'alias ll="ls -la"' >> ~/.bashrc \
    && echo 'alias la="ls -la"' >> ~/.bashrc \
    && echo 'alias ..="cd .."' >> ~/.bashrc \
    && echo 'alias npm-fresh="rm -rf node_modules package-lock.json && npm install"' >> ~/.bashrc \
    && echo 'alias pnpm-fresh="rm -rf node_modules pnpm-lock.yaml && pnpm install"' >> ~/.bashrc

# Switch back to root for final setup
USER root

# Expose common development ports
EXPOSE 3000 3001 5432 6379

# Create entrypoint script for development
RUN echo '#!/bin/bash\n\
    if [ ! -f package.json ]; then\n\
    echo "No package.json found. Creating T3 app template..."\n\
    npx create-t3-app@latest . --default --noGit\n\
    fi\n\
    \n\
    # Ensure correct permissions\n\
    chown -R node:node /workspace\n\
    \n\
    # Start development server if package.json exists and has dev script\n\
    if [ -f package.json ] && grep -q "\"dev\":" package.json; then\n\
    echo "Starting development server..."\n\
    su node -c "npm run dev"\n\
    else\n\
    echo "Development container ready!"\n\
    exec "$@"\n\
    fi' > /usr/local/bin/dev-entrypoint.sh \
    && chmod +x /usr/local/bin/dev-entrypoint.sh

# Set the default user
USER $USERNAME

# Default command
ENTRYPOINT ["/usr/local/bin/dev-entrypoint.sh"]
CMD ["bash"] 