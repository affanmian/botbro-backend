FROM python:3.10

WORKDIR /app

# Shared location for Playwright's browser binaries, accessible to both root and the app user
ENV PLAYWRIGHT_BROWSERS_PATH=/app/.playwright-browsers

# Install system dependencies
RUN apt-get update && apt-get install -y build-essential sqlite3

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Playwright needs its browser binaries + system deps for the scraper to work (needs root)
RUN playwright install --with-deps chromium || true

# Hugging Face Spaces run as user 1000, so we need to set permissions
RUN useradd -m -u 1000 user
RUN chown -R user:user /app
USER user

# Runs on whatever port the host (Render) assigns via $PORT, defaulting to 7860 for local/HF use
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-7860}"]
