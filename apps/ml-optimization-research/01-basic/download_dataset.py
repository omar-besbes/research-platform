import os
import kaggle
import argparse

def download_df(df: str, username: str, key: str):
    if not os.path.exists("dataset"):
        os.makedirs("dataset")
    k = kaggle.KaggleApi({ "username": username, "key": key })
    k.authenticate()
    print("kaggle.com: authenticated")
    k.dataset_download_cli(df, unzip=True, path="dataset")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--username', help='Kaggle username', type=str)
    parser.add_argument('--key', help='Kaggle access key', type=str)
    parser.add_argument('--df', help='Dataset name from kaggle.com', type=str)
    args = parser.parse_args()
    download_df(args.df, args.username, args.key)
 