# Use an official TensorFlow runtime as a parent image
FROM tensorflow/tensorflow:latest

# Install necessary packages
RUN pip install py7zr boto3 pandas

# Create a working directory
WORKDIR /app

# Copy the training script into the container
COPY src/train.py /app/train.py

# Set the command to run the training script
CMD ["python", "/app/train.py"]
