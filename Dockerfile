# FROM python:3.12-slim

# # Prevents Python from buffering stdout and stderr
# ENV PYTHONUNBUFFERED=1

# # Copy from the cache instead of linking since it's a mounted volume
# ENV UV_LINK_MODE=copy

# WORKDIR /app
# COPY . .

# # Upgrade pip to the latest version
# RUN pip install --no-cache-dir --upgrade pip
# # Install uv
# RUN pip install --no-cache-dir uv>=0.7.19

# # Copy only the dependency files to leverage Docker layer caching
# COPY uv.lock pyproject.toml ./

# # Install project dependencies, sync to uv's lockfile
# RUN uv sync --frozen

# # Expose the port
# EXPOSE 8080

# CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

# adk-samples/python/agents/data-science/Dockerfile
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    PORT=8080 \
    PYTHONPATH=/app

# (Optional) build tools help for some wheels
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

# Install uv (Astral) and upgrade pip
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir "uv>=0.7.19"

# Work from the **data-science** directory (this folder has pyproject.toml)
WORKDIR /app

# Layer cache: lock + pyproject first
COPY uv.lock pyproject.toml ./

# Install deps according to lockfile
RUN uv sync --frozen

# Copy the rest of the agent code
COPY . .

# Cloud Run sends $PORT; we must bind to 0.0.0.0:$PORT
EXPOSE 8080
CMD ["bash","-lc","uv run adk web --host 0.0.0.0 --port ${PORT:-8080}"]
