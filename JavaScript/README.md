# Next.js T3 Stack Development Environment

A comprehensive development container for the **T3 Stack** - the best way to start a full-stack, typesafe Next.js app.

## 🚀 What's Included

### Core T3 Stack
- **[Next.js 14](https://nextjs.org/)** - The React Framework for Production
- **[TypeScript](https://www.typescriptlang.org/)** - Strongly typed programming language 
- **[tRPC](https://trpc.io/)** - End-to-end typesafe APIs made easy
- **[Prisma](https://prisma.io/)** - Next-generation Node.js and TypeScript ORM
- **[NextAuth.js](https://next-auth.js.org/)** - Complete open source authentication solution
- **[Tailwind CSS](https://tailwindcss.com/)** - A utility-first CSS framework

### Development Environment
- **Node.js 18 LTS** with pnpm, yarn, and npm
- **PostgreSQL 15** database with Adminer web interface
- **Redis 7** for caching and sessions
- **VS Code extensions** pre-configured for optimal development
- **Docker optimization** for fast rebuilds and development

### Pre-configured Tools
- **ESLint** with TypeScript and Next.js rules
- **Prettier** with Tailwind CSS plugin
- **Testing** setup with Jest and React Testing Library
- **Storybook** for component development (optional)
- **Environment validation** with Zod
- **Bundle analyzer** integration

## 🛠 Quick Start

### Option 1: Use This Template
1. **Navigate to JavaScript directory**:
   ```bash
   cd JavaScript/
   code .
   ```
2. **Reopen in Container** when VS Code prompts
3. **Install dependencies**:
   ```bash
   npm install
   ```
4. **Set up database**:
   ```bash
   cp template/env.example .env.local
   # Edit .env.local with your settings
   npx prisma db push
   ```
5. **Start developing**:
   ```bash
   npm run dev
   ```

### Option 2: Copy to Existing Repository
Use the provided script to copy the T3 stack setup to your existing repository:

```bash
./template/copy-to-existing-repo.sh /path/to/your/repo
```

This script will:
- ✅ Copy all dev container configuration files
- ✅ Copy template configuration files (if they don't exist)
- ✅ Merge .gitignore entries
- ✅ Set up VS Code settings and launch configurations
- ✅ Provide step-by-step instructions

## 📁 Project Structure

```
JavaScript/
├── .devcontainer/              # Dev container configuration
│   ├── devcontainer.json      # VS Code settings & extensions
│   ├── Dockerfile             # Container definition
│   ├── docker-compose.yml     # Multi-service setup
│   └── .dockerignore          # Docker build exclusions
├── template/                   # Template for copying to existing repos
│   ├── copy-to-existing-repo.sh  # Copy script
│   ├── package.json           # Dependencies template
│   ├── tsconfig.json          # TypeScript configuration
│   ├── next.config.js         # Next.js configuration
│   ├── tailwind.config.js     # Tailwind CSS configuration
│   ├── postcss.config.js      # PostCSS configuration
│   ├── .eslintrc.json         # ESLint rules
│   ├── .prettierrc.json       # Prettier configuration
│   ├── env.example            # Environment variables template
│   ├── prisma/
│   │   └── schema.prisma      # Database schema
│   └── .vscode/               # VS Code configuration
│       ├── settings.json      # Editor settings
│       └── launch.json        # Debug configuration
├── package.json               # Project dependencies
└── README.md                  # This file
```

## 🔧 Development Workflow

### Database Management
```bash
# Generate Prisma client
npm run db:generate

# Push schema changes to database
npm run db:push

# Open Prisma Studio (database GUI)
npm run db:studio

# Create and run migrations
npm run db:migrate

# Reset database
npm run db:reset
```

### Code Quality
```bash
# Run linting
npm run lint
npm run lint:fix

# Format code
npm run format

# Type checking
npm run type-check

# Run tests
npm run test
npm run test:watch
npm run test:coverage
```

### Development Server
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Clean build cache
npm run clean

# Fresh install (removes all cache)
npm run clean:full
```

## 🗄 Database Services

### PostgreSQL
- **Host**: `localhost` (when running locally) or `postgres` (from container)
- **Port**: `5432`
- **Database**: `t3_dev`
- **Username**: `postgres`
- **Password**: `password`

### Adminer (Database GUI)
- **URL**: http://localhost:8080
- **System**: PostgreSQL
- **Server**: postgres
- **Username**: postgres
- **Password**: password

### Redis
- **Host**: `localhost` (when running locally) or `redis` (from container)
- **Port**: `6379`
- **Password**: `password`

## 🔐 Environment Variables

Copy `template/env.example` to `.env.local` and configure:

```bash
# Database
DATABASE_URL="postgresql://postgres:password@localhost:5432/t3_dev?schema=public"

# NextAuth.js
NEXTAUTH_SECRET="your-secret-key"
NEXTAUTH_URL="http://localhost:3000"

# OAuth Providers (optional)
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""

# Additional services
REDIS_URL="redis://localhost:6379"
```

## 🎯 VS Code Extensions

The dev container includes these essential extensions:

### TypeScript & React
- TypeScript and JavaScript Language Features
- React Refactor
- ES7+ React/Redux/React-Native snippets

### Code Quality
- ESLint
- Prettier
- Error Lens
- Auto Rename Tag

### Database & API
- Prisma
- REST Client
- Thunder Client

### Git & Collaboration
- GitLens
- GitHub Copilot
- GitHub Pull Requests

### Styling
- Tailwind CSS IntelliSense
- PostCSS Language Support

## 🚀 Performance Optimizations

### Docker Layer Caching
- Package files copied first for maximum cache hits
- Dependencies installed in separate layer
- Named volumes for `node_modules` and build cache

### Development Speed
- **Hot reloading** with Next.js Fast Refresh
- **Volume mounts** for `node_modules` to avoid host filesystem overhead
- **Build caching** for faster rebuilds
- **Persistent extension cache** to avoid re-downloading

### Bundle Optimization
- **SWC minification** enabled
- **Bundle analyzer** available with `ANALYZE=true npm run build`
- **Automatic code splitting** with Next.js
- **Tree shaking** for smaller bundles

## 🔍 Debugging

### VS Code Debugger
- **Server-side debugging**: F5 → "Next.js: debug server-side"
- **Client-side debugging**: F5 → "Next.js: debug client-side"  
- **Full-stack debugging**: F5 → "Next.js: debug full stack"

### Browser DevTools
- React Developer Tools (install browser extension)
- Next.js DevTools integration
- Prisma Studio for database inspection

## 🧪 Testing

### Jest Setup
```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage
```

### Testing Libraries Included
- **Jest** - Testing framework
- **React Testing Library** - React component testing
- **Jest DOM** - Custom DOM matchers
- **User Event** - User interaction simulation

## 📝 Common Tasks

### Adding Authentication
```typescript
// The container includes NextAuth.js setup
// Add providers in pages/api/auth/[...nextauth].ts
```

### Database Schema Changes
```bash
# 1. Edit prisma/schema.prisma
# 2. Push to database
npm run db:push
# 3. Generate client
npm run db:generate
```

### Adding New Dependencies
```bash
# Install and save to package.json
npm install package-name

# Install dev dependency
npm install -D package-name

# Update all dependencies
npx npm-check-updates -u
npm install
```

### Deploying to Vercel
```bash
# Install Vercel CLI (already included)
vercel

# Or connect your git repository to Vercel dashboard
```

## 🎨 Customization

### Tailwind CSS
- Customize `tailwind.config.js` for your design system
- CSS variables approach for easy theming
- Pre-configured animations and transitions

### ESLint Rules
- Extend `.eslintrc.json` with custom rules
- TypeScript-first configuration
- Next.js best practices included

### Prisma Models
- Extend `prisma/schema.prisma` with your data models
- NextAuth.js models included by default
- Example models provided for reference

## 📚 Resources

- [T3 Stack Documentation](https://create.t3.gg/)
- [Next.js Documentation](https://nextjs.org/docs)
- [tRPC Documentation](https://trpc.io/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [NextAuth.js Documentation](https://next-auth.js.org/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## 🆘 Troubleshooting

### Container Won't Start
- Ensure Docker is running
- Check port conflicts (3000, 5432, 6379, 8080)
- Try rebuilding: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

### Database Connection Issues
- Verify PostgreSQL is running: `docker-compose ps`
- Check environment variables in `.env.local`
- Reset database: `npm run db:reset`

### TypeScript Errors
- Restart TypeScript server: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"
- Check `tsconfig.json` configuration
- Ensure all dependencies are installed

### Performance Issues
- Clear Next.js cache: `npm run clean`
- Restart dev server
- Check Docker resource allocation

---

**Happy coding with the T3 Stack! 🎉**

*This dev container provides everything you need for modern, full-stack TypeScript development with the T3 stack.* 