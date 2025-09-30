# Multi-stage build for spamusement.cc static site

# Stage 1: Build environment
# Using Ubuntu 24.04 (Noble)
FROM swift:6.0-noble AS builder

# Set working directory
WORKDIR /app

# Copy Swift package files AND source code needed to build
COPY Package.swift ./
COPY Package.resolved ./
COPY Sources ./Sources

# Pre-fetch and pre-build Swift dependencies
# This layer will be cached as long as Package files and Sources don't change
RUN echo "Prefetching and prebuilding dependencies..." \
    && swift package resolve \
    && swift build --product Spamusement -c release

# Copy all source files
COPY . .

# Build the site with verbose output for debugging
RUN echo "Starting website build..." \
    && .build/release/Spamusement

# Stage 2: Nginx runtime
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from builder
COPY --from=builder /app/deploy /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
