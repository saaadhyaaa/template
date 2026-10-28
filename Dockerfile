# Python base image
FROM python:3.12-slim

# Working directory inside the container
WORKDIR /app

# Copy dependency file
COPY requirements.txt .

# Install Flask and other dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Flask application port
EXPOSE 5000

# Start the Flask application
# CHANGE app.py if your Python filename is different.
# CHANGE app if your Flask variable has another name.
CMD ["python", "app.py"]
