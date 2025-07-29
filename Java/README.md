# Java JDK 21 FX Development Environment

This directory contains a complete Java development environment with JDK 21 and JavaFX support, optimized for VS Code Dev Containers.

## 🚀 Features

### Core Components
- **OpenJDK 21**: Latest LTS version with all modern Java features
- **JavaFX 21.0.2**: Complete GUI framework for desktop applications
- **Maven 3.9.6**: Build tool and dependency management
- **Gradle 8.5**: Alternative build system
- **JUnit 5**: Modern testing framework
- **TestFX**: JavaFX testing framework

### Development Tools
- **VS Code Java Extensions**: Complete Java development support
- **Code Quality**: Google Style formatting, linting, and code analysis
- **Debugging**: Hot code replace, breakpoint debugging
- **Testing**: Integrated test runner with JavaFX support

### Pre-configured Dependencies
- **JavaFX**: Controls, FXML, Web, Media, Graphics
- **Testing**: JUnit 5, TestFX, Hamcrest
- **Logging**: SLF4J, Logback
- **JSON**: Jackson for data processing
- **HTTP**: OkHttp client
- **Database**: PostgreSQL, MySQL connectors
- **Utilities**: Apache Commons, Commons IO

## 🛠️ Quick Start

### Option 1: Dev Container (Recommended)
```bash
# From the repository root
./setup-env.sh -j devcontainer /path/to/your/project

# Or navigate to the Java directory
cd Java
code .
# Click "Reopen in Container" when prompted
```

### Option 2: Local Development
```bash
# From the repository root
./setup-env.sh -j local /path/to/your/project

# Requires Java 21 installed locally
# On Ubuntu/Debian: sudo apt install openjdk-21-jdk
# On macOS: brew install openjdk@21
```

## 📁 Project Structure

```
Java/
├── .devcontainer/          # Dev container configuration
│   ├── devcontainer.json   # VS Code dev container settings
│   ├── Dockerfile          # Container image definition
│   └── docker-compose.yml  # Container orchestration
├── .vscode/               # VS Code settings
│   └── settings.json      # Java-specific settings
├── src/
│   ├── main/
│   │   ├── java/          # Java source code
│   │   └── resources/     # Application resources
│   └── test/
│       ├── java/          # Test source code
│       └── resources/     # Test resources
├── pom.xml                # Maven configuration
└── README.md             # This file
```

## 🔧 Development Workflow

### Building and Running
```bash
# Compile and run with Maven
mvn clean compile
mvn javafx:run

# Or use the Maven wrapper
./mvnw clean compile
./mvnw javafx:run

# Run tests
mvn test

# Package application
mvn package
```

### VS Code Integration
- **Java Language Server**: Full IntelliSense and code completion
- **Debugging**: Set breakpoints and debug JavaFX applications
- **Testing**: Run tests directly from VS Code
- **Code Quality**: Automatic formatting and linting on save

### JavaFX Development
- **Scene Builder**: Visual UI design (install separately)
- **FXML**: Declarative UI layouts
- **CSS Styling**: Custom styling for JavaFX components
- **Event Handling**: Modern lambda-based event handlers

## 🧪 Testing

### Unit Tests
```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

@Test
void testExample() {
    assertEquals(2, 1 + 1);
}
```

### JavaFX Tests
```java
import org.testfx.framework.junit5.ApplicationTest;
import javafx.scene.control.Button;

class AppTest extends ApplicationTest {
    @Test
    void testButtonClick() {
        Button button = lookup("#greetButton").query();
        clickOn(button);
        // Verify expected behavior
    }
}
```

## 🔍 Debugging

### VS Code Debug Configuration
- **Server-side**: Debug Java applications
- **Client-side**: Debug JavaFX UI components
- **Hot Code Replace**: Update code without restarting

### Common Debug Scenarios
1. **JavaFX Application**: Set breakpoints in UI event handlers
2. **Maven Build**: Debug build process and dependency issues
3. **Test Execution**: Step through test cases
4. **Performance**: Profile memory and CPU usage

## 📦 Package Management

### Maven Dependencies
The `pom.xml` includes:
- **JavaFX**: Complete GUI framework
- **Testing**: JUnit 5, TestFX
- **Logging**: SLF4J, Logback
- **JSON**: Jackson
- **HTTP**: OkHttp
- **Database**: PostgreSQL, MySQL
- **Utilities**: Apache Commons

### Adding Dependencies
```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>library</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 🎨 Customization

### VS Code Settings
- **Java Home**: Configured for OpenJDK 21
- **Code Style**: Google Style formatting
- **Auto-save**: Format and organize imports on save
- **File Associations**: FXML as XML, custom CSS support

### Container Customization
- **Base Image**: OpenJDK 21 with JavaFX
- **System Dependencies**: Graphics, multimedia, development tools
- **User Setup**: Non-root user with sudo access
- **Volume Mounts**: Persistent Maven and Gradle caches

## 🚀 Performance Optimization

### Build Caching
- **Maven Repository**: Persistent `.m2/repository`
- **Gradle Cache**: Persistent Gradle build cache
- **VS Code Extensions**: Shared extension cache
- **Docker Layers**: Optimized layer caching

### Development Tips
- **Incremental Compilation**: Maven's incremental build system
- **Hot Reload**: JavaFX hot code replace
- **Memory Management**: Configure JVM heap size as needed
- **Graphics Performance**: Hardware acceleration for JavaFX

## 🔧 Troubleshooting

### Common Issues

#### JavaFX Not Found
```bash
# Ensure JavaFX modules are in classpath
mvn clean compile
mvn javafx:run
```

#### Graphics Issues
```bash
# For headless environments
export DISPLAY=:0
# Or use software rendering
-Dprism.order=sw
```

#### Maven Build Failures
```bash
# Clean and rebuild
mvn clean install
# Check Java version
java -version
```

#### VS Code Java Extension Issues
1. **Reload Window**: `Ctrl+Shift+P` → "Developer: Reload Window"
2. **Java Language Server**: Restart Java language server
3. **Project Refresh**: `Ctrl+Shift+P` → "Java: Reload Projects"

### Debug Information
```bash
# Check Java version
java -version

# Check Maven version
mvn -version

# Check JavaFX installation
ls -la /opt/javafx-sdk/

# Check container logs
docker logs java-dev-container
```

## 📚 Resources

### Documentation
- [OpenJDK 21 Documentation](https://docs.oracle.com/en/java/javase/21/)
- [JavaFX Documentation](https://openjfx.io/)
- [Maven Documentation](https://maven.apache.org/guides/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)

### Learning Resources
- [JavaFX Tutorial](https://openjfx.io/openjfx-docs/)
- [Maven Getting Started](https://maven.apache.org/guides/getting-started/)
- [JUnit 5 Testing](https://junit.org/junit5/docs/current/user-guide/)

### Community
- [OpenJFX Community](https://openjfx.io/community/)
- [Maven Users Mailing List](https://maven.apache.org/mailing-lists.html)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/javafx)

## 🤝 Contributing

### Development Guidelines
1. **Code Style**: Follow Google Java Style Guide
2. **Testing**: Write unit tests for new features
3. **Documentation**: Update README and inline comments
4. **Dependencies**: Keep dependencies up to date

### Testing Checklist
- [ ] Unit tests pass
- [ ] JavaFX tests pass
- [ ] Build completes successfully
- [ ] Application runs without errors
- [ ] VS Code extensions work correctly

## 📄 License

This project is part of the DevContainers repository. See the main README for license information. 