# Multi-stage build for spamusement.cc static site

# Stage 1: Build environment
# Using Ubuntu 24.04 (Noble)
FROM swift:6.1-noble AS builder

# Set working directory
WORKDIR /app

# Pre-fetch Swift dependencies (cached unless the Package files change)
COPY Package.swift Package.resolved ./
RUN --mount=type=cache,target=/app/.build,sharing=locked \
    swift package resolve

# Pre-build the site generator (cached unless the sources change).
# .build is a cache mount so SwiftPM's incremental state survives between
# deploys: only the changed module recompiles. Because a cache mount isn't
# part of the image layer, the binary has to be copied out of it here, and
# is run from /usr/local/bin below.
COPY Sources ./Sources
RUN --mount=type=cache,target=/app/.build,sharing=locked \
    swift build --product Spamusement \
    && cp .build/debug/Spamusement /usr/local/bin/spamusement

# Copy all remaining files
COPY . .

# Build the site
RUN spamusement

# Stage 2: Nginx runtime
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from builder
COPY --from=builder /app/deploy /usr/share/nginx/html
