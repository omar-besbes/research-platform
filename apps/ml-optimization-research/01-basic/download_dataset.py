import os
import json
import kaggle
import argparse
import logging

# Configure logging to output to the console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def create_kaggle_json(username: str, key: str):
    """Create the Kaggle credentials file at ~/.config/kaggle/kaggle.json"""

    kaggle_dir = os.path.expanduser("~/.config/kaggle")
    os.makedirs(kaggle_dir, exist_ok=True)
    
    kaggle_json_path = os.path.join(kaggle_dir, "kaggle.json")
    credentials = {
        "username": username,
        "key": key
    }
    
    with open(kaggle_json_path, 'w') as file:
        json.dump(credentials, file)
    
    # Set file permissions to be read/write by the owner only
    os.chmod(kaggle_json_path, 600)
    print(f"Kaggle credentials saved to {kaggle_json_path}")
    logging.info(f"Kaggle credentials saved to {kaggle_json_path}")

def download_df(df: str):
    """Download dataset from Kaggle using credentials stored in ~/.config/kaggle/kaggle.json"""

    if not os.path.exists("dataset"):
        os.makedirs("dataset")
    k = kaggle.KaggleApi()
    k.authenticate()
    print("kaggle.com: authenticated")
    k.dataset_download_cli(df, unzip=True, path="dataset")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--username', help='Kaggle username', type=str)
    parser.add_argument('--key', help='Kaggle access key', type=str)
    parser.add_argument('--df', help='Dataset name from kaggle.com', type=str)
    args = parser.parse_args()

    create_kaggle_json(args.username, args.key)
    download_df(args.df)
 