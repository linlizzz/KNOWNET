# Use an official Node.js image as the base for building the frontend
FROM node:20.9.0 AS frontend-builder

# Set the working directory for the frontend build
WORKDIR /frontend

# Copy package manager files and install dependencies
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

# Copy the rest of the frontend source code and build it
COPY . .
RUN pnpm run build

# Use a smaller base image for the final stage
FROM node:20.9.0-slim

# Install Python 3.11 and pip
RUN apt-get update && \
    apt-get install -y python3.11 python3.11-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /workdir

# Install only necessary Node.js packages
RUN npm install -g next && npm install -g pnpm && npm install -g concurrently

# Copy the built frontend from the previous stage
COPY --from=frontend-builder /frontend/.next ./.next
COPY --from=frontend-builder /frontend/public ./public
COPY --from=frontend-builder /frontend/package.json ./package.json

# Create a virtual environment and activate it
RUN python3 -m venv /workdir/venv

# Copy the requirements file
COPY requirements.txt ./

# Install Python dependencies in the virtual environment
RUN /workdir/venv/bin/pip install -r requirements.txt

# Set the virtual environment as the default for Python
ENV PATH="/workdir/venv/bin:$PATH"

# Copy the rest of the application code
COPY . .

# Expose ports for frontend (3000) and backend (5328)
EXPOSE 3000 5328

# Start both the frontend and backend
CMD ["concurrently", "\"HOST=0.0.0.0 next start\"", "\"pnpm run flask-dev\""]
