# Use a lightweight Python image
FROM python:3.12-slim-bullseye as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Set the working directory
WORKDIR /myapp

# Install system dependencies in one step for efficiency
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file and install Python dependencies
COPY ./requirements.txt /myapp/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the rest of the application code
COPY . /myapp

# Copy and configure the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Add a non-root user and switch to it
RUN useradd -m myuser
USER myuser

# Expose the application's port
EXPOSE 8000

# Start the application
CMD ["/start.sh"]