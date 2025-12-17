# =============================================================================
# MCP Atlassian - Docker Build Configuration
# =============================================================================
# For internal Workday builds, configure these ARGs to use Artifactory mirrors:
#
#   docker build \
#     --build-arg BASE_REGISTRY=artifactory.workday.com/docker-remote \
#     --build-arg UV_REGISTRY=artifactory.workday.com/docker-remote \
#     --build-arg PYPI_INDEX_URL=https://artifactory.workday.com/artifactory/api/pypi/pypi-remote/simple \
#     -t artifactory.workday.com/your-repo/mcp-atlassian:latest .
#
# =============================================================================

# Configurable base image registries (default to public for development)
ARG UV_REGISTRY=ghcr.io/astral-sh
ARG BASE_REGISTRY=docker.io/library

# PyPI index URL (default to public PyPI, override for Artifactory)
ARG PYPI_INDEX_URL=https://pypi.org/simple

# Use a Python image with uv pre-installed
FROM ${UV_REGISTRY}/uv:python3.13-alpine AS uv

# Re-declare ARG after FROM to make it available in this stage
ARG PYPI_INDEX_URL

# Install the project into `/app`
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Configure UV to use the specified PyPI index
ENV UV_INDEX_URL=${PYPI_INDEX_URL}

# Generate proper TOML lockfile first
RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=README.md,target=README.md \
    uv lock

# Install the project's dependencies using the lockfile
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --frozen --no-install-project --no-dev --no-editable

# Then, copy the rest of the project source code and install it
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --frozen --no-dev --no-editable

# Remove unnecessary files from the virtual environment before copying
RUN find /app/.venv -name '__pycache__' -type d -exec rm -rf {} + && \
    find /app/.venv -name '*.pyc' -delete && \
    find /app/.venv -name '*.pyo' -delete && \
    echo "Cleaned up .venv"

# Final stage
FROM ${BASE_REGISTRY}/python:3.13-alpine

# Create a non-root user 'app'
RUN adduser -D -h /home/app -s /bin/sh app
WORKDIR /app
USER app

COPY --from=uv --chown=app:app /app/.venv /app/.venv

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Disable Python output buffering for proper stdio communication
ENV PYTHONUNBUFFERED=1

# For minimal OAuth setup without environment variables, use:
# docker run -e ATLASSIAN_OAUTH_ENABLE=true -p 8000:8000 your-image
# Then provide authentication via headers:
# Authorization: Bearer <your_oauth_token>
# X-Atlassian-Cloud-Id: <your_cloud_id>

ENTRYPOINT ["mcp-atlassian"]
