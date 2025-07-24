/**
 * Run `build` or `dev` with `SKIP_ENV_VALIDATION` to skip env validation. This is especially useful
 * for Docker builds.
 */
await import("./src/env.js");

/** @type {import("next").NextConfig} */
const config = {
  // Enable React strict mode for improved error handling
  reactStrictMode: true,

  // Disable x-powered-by header
  poweredByHeader: false,

  // Enable SWC minification for improved performance
  swcMinify: true,

  // Experimental features
  experimental: {
    // Enable Server Components (App Router)
    appDir: false, // Set to true when migrating to app directory
    
    // Optimize CSS
    optimizeCss: true,
    
    // Enable edge runtime for specific routes
    runtime: "nodejs",
  },

  // Configure domains for next/image
  images: {
    domains: [
      "localhost",
      "127.0.0.1",
      // Add your image domains here
      // "example.com",
      // "cdn.example.com",
    ],
    // Disable static imports for better performance
    dangerouslyAllowSVG: true,
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  },

  // Environment variables available in the client
  env: {
    CUSTOM_KEY: "my-value",
  },

  // Redirect configuration
  async redirects() {
    return [
      // Example redirect
      // {
      //   source: "/old-path",
      //   destination: "/new-path",
      //   permanent: true,
      // },
    ];
  },

  // Rewrite configuration  
  async rewrites() {
    return [
      // Example rewrite
      // {
      //   source: "/api/proxy/:path*",
      //   destination: "https://api.external.com/:path*",
      // },
    ];
  },

  // Headers configuration
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          // Security headers
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "Referrer-Policy",
            value: "strict-origin-when-cross-origin",
          },
          {
            key: "Permissions-Policy",
            value: "camera=(), microphone=(), geolocation=()",
          },
        ],
      },
    ];
  },

  // Bundle analyzer
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Enable bundle analyzer in development
    if (process.env.ANALYZE === "true") {
      const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer");
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: "server",
          openAnalyzer: true,
        })
      );
    }

    return config;
  },

  // TypeScript configuration
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // !! WARN !!
    ignoreBuildErrors: false,
  },

  // ESLint configuration
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: false,
  },

  // Output configuration
  output: "standalone",

  // Compiler options
  compiler: {
    // Remove console.log in production
    removeConsole: process.env.NODE_ENV === "production",
  },
};

export default config; 