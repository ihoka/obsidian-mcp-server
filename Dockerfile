# Use official Ruby image based on the version specified in .ruby-version
FROM ruby:3.4.4-alpine

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies needed for Ruby gems
RUN apk add --no-cache \
    build-base \
    git

# Copy Gemfile and Gemfile.lock first for better Docker layer caching
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle config --local deployment true && \
    bundle config --local without development test && \
    bundle install --jobs 4

# Copy the rest of the application code
COPY . .

# Create a non-root user for security
RUN addgroup -g 1000 obsidian && \
    adduser -u 1000 -G obsidian -s /bin/sh -D obsidian

# Change ownership of the app directory to the obsidian user
RUN chown -R obsidian:obsidian /app

# Switch to non-root user
USER obsidian

# Expose the default port (MCP typically runs on stdin/stdout, but this allows for flexibility)
# Note: MCP servers typically communicate via stdin/stdout, not HTTP ports
# This is mainly for documentation and potential future HTTP interface
EXPOSE 3000

# Make the main script executable
RUN chmod +x obsidian_server.rb

# Set the default command to run the MCP server
CMD ["./obsidian_server.rb"]
