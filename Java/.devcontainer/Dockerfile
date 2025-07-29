# Use the official OpenJDK 21 base image
FROM openjdk:21-jdk-bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 \
    MAVEN_HOME=/usr/share/maven \
    PATH=/usr/lib/jvm/java-21-openjdk-amd64/bin:/usr/share/maven/bin:$PATH

# Install system dependencies for Java development
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
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
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    # JavaFX dependencies
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgtk-3-0 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer-plugins-bad1.0-0 \
    libgstreamer-plugins-good1.0-0 \
    libgstreamer-plugins-ugly1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    libgstreamer-plugins-ugly1.0-dev \
    # Development tools
    maven \
    gradle \
    ant \
    # Additional utilities
    jq \
    httpie \
    postgresql-client \
    mysql-client \
    redis-tools \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install additional Java tools
RUN wget -qO- https://repo1.maven.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.tar.gz | tar xz -C /opt \
    && ln -s /opt/apache-maven-3.9.6 /usr/share/maven

# Install Gradle
RUN wget -qO- https://services.gradle.org/distributions/gradle-8.5-bin.zip | unzip -d /opt \
    && ln -s /opt/gradle-8.5/bin/gradle /usr/local/bin/gradle

# Install JavaFX SDK
RUN wget -qO- https://download2.gluonhq.com/openjfx/21.0.2/openjfx-21.0.2_linux-x64_bin-sdk.zip | unzip -d /opt \
    && ln -s /opt/openjfx-21.0.2-sdk /opt/javafx-sdk

# Set up JavaFX environment
ENV PATH="/opt/javafx-sdk/bin:${PATH}" \
    JAVAFX_HOME="/opt/javafx-sdk"

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up workspace directory
WORKDIR /workspace

# Copy Maven settings and configuration
COPY pom.xml /tmp/maven-tmp/
RUN mkdir -p /home/$USERNAME/.m2 \
    && cp /tmp/maven-tmp/pom.xml /workspace/ \
    && rm -rf /tmp/maven-tmp

# Set up Maven configuration
RUN mkdir -p /home/$USERNAME/.m2 \
    && echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">' > /home/$USERNAME/.m2/settings.xml \
    && echo '  <localRepository>/workspace/.m2/repository</localRepository>' >> /home/$USERNAME/.m2/settings.xml \
    && echo '  <interactiveMode>false</interactiveMode>' >> /home/$USERNAME/.m2/settings.xml \
    && echo '</settings>' >> /home/$USERNAME/.m2/settings.xml \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.m2

# Set up common directories
RUN mkdir -p /workspace/src/main/java \
    /workspace/src/main/resources \
    /workspace/src/test/java \
    /workspace/src/test/resources \
    /workspace/target \
    /workspace/lib \
    && chown -R $USERNAME:$USERNAME /workspace

# Configure Git
RUN git config --global init.defaultBranch main \
    && git config --global pull.rebase false

# Set up Maven wrapper
RUN cd /workspace \
    && mvn wrapper:wrapper \
    && chown -R $USERNAME:$USERNAME /workspace

# Switch to non-root user
USER $USERNAME

# Expose common ports
EXPOSE 8080 3000 5000 8000

# Default command
CMD ["bash"] 