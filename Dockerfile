# Use an official Node.js image as the base
FROM node:20.9.0

# Install Python 3.11 and pip
RUN apt-get update && \
    apt-get install -y python3.11 python3.11-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /wd

# Copy package manager files
COPY package.json pnpm-lock.yaml ./

# Install pnpm globally
RUN npm install -g pnpm

# Install Node.js dependencies
RUN pnpm install

# Create a virtual environment and activate it
RUN python3 -m venv /wd/venv

# Copy the requirements file
COPY requirements.txt ./

# Install Python dependencies in the virtual environment
RUN /wd/venv/bin/pip install -r requirements.txt

# Set the virtual environment as the default for Python
ENV PATH="/wd/venv/bin:$PATH"

# Copy the rest of the application code
COPY . ./

# Expose ports for frontend (3000) and backend (5328)
EXPOSE 3000 5328

# Start the application
CMD ["pnpm", "dev"]
