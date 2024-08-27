import boto3
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten
from tensorflow.keras.utils import to_categorical
import logging
import os

# Configure logging to output to the console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

logging.info('Hello 01-basic!')

# MinIO configuration
minio_endpoint = os.getenv('MINIO_ENDPOINT')
minio_access_key = os.getenv('MINIO_ACCESS_KEY')
minio_secret_key = os.getenv('MINIO_SECRET_KEY')

# Setup MinIO client
s3_client = boto3.client('s3',
                         endpoint_url=f'http://{minio_endpoint}',
                         aws_access_key_id=minio_access_key,
                         aws_secret_access_key=minio_secret_key)

# Define bucket name
bucket_name = 'data'

# Define file names
files = {
    'train': 'mnist_train.csv',
    'test': 'mnist_test.csv'
}

# Download files
local_files = {}
logging.info('Starting dataset download')
for key, filename in files.items():
    local_path = os.path.join('/tmp', filename)
    logging.info(f'Downloading {filename} from bucket {bucket_name}')
    s3_client.download_file(bucket_name, filename, local_path)
    local_files[key] = local_path

# Load data using pandas
logging.info('Loading MNIST data from CSV files')
train_data = pd.read_csv(local_files['train'])
test_data = pd.read_csv(local_files['test'])

# Log the start time
logging.info('Training started')

# Extract labels and features
x_train = train_data.iloc[:, 1:].values
y_train = train_data.iloc[:, 0].values
x_test = test_data.iloc[:, 1:].values
y_test = test_data.iloc[:, 0].values

# Normalize pixel values to be between 0 and 1
x_train, x_test = x_train / 255.0, x_test / 255.0

# Reshape data to fit model input
x_train = x_train.reshape(-1, 28, 28)
x_test = x_test.reshape(-1, 28, 28)

# One-hot encode the labels
y_train = to_categorical(y_train, 10)
y_test = to_categorical(y_test, 10)

# Build and compile the model
model = Sequential([
    Flatten(input_shape=(28, 28)),
    Dense(128, activation='relu'),
    Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
logging.info('Starting model training')
history = model.fit(x_train, y_train, epochs=5, batch_size=32, validation_split=0.2)

# Evaluate the model
logging.info('Evaluating model')
test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
logging.info(f'Test accuracy: {test_acc:.4f}')

# Save training history
logging.info('Training finished')
logging.info(f'Test accuracy: {test_acc:.4f}')
