# Use a slim official Python image to keep the final image small
FROM python:3.13-slim

# Install ffmpeg, which is required to merge the generated audio clips into one MP3.
# --no-install-recommends avoids pulling in unnecessary packages, and the apt cache
# is removed afterwards to reduce image size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for all following commands
WORKDIR /app

# Copy only the requirements file first so Docker can cache the dependency layer.
# Dependencies are reinstalled only when requirements.txt changes, not on every code edit.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application source code
COPY . .

# Document the port the app listens on (publish it with `docker run -p 8000:8000`)
EXPOSE 8000

# Start the FastAPI app with uvicorn. Binding to 0.0.0.0 makes the server
# reachable from outside the container.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
