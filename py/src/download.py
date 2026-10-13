import os
from kaggle.api.kaggle_api_extended import KaggleApi
from pathlib import Path
import requests
import zipfile
from io import BytesIO
from config import (
    MUN_MESH_URL,
    KAGGLE_DIR,
    MUN_MESH_DIR
)

def download_kaggle_dataset(
    output_dir: str
):
    
    dataset = os.environ["KAGGLE_DATASET"]

    api = KaggleApi()
    api.authenticate()

    api.dataset_download_files(
        dataset,
        path=output_dir,
        unzip=True
    )

    print(f"Saved olist records to {output_dir}")

def download_and_unzip(
    url: str,
    output_dir: str,
    max_retries: int = 3
):
    
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    print(f"Downloading from {url}...")

    for attempt in range(max_retries + 1):
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()

            with zipfile.ZipFile(BytesIO(response.content)) as zip_file:
                print("Unzipping file...")
                zip_file.extractall(output_dir)

            print("Done.")
            return

        except (requests.RequestException, zipfile.BadZipFile) as e:
            if attempt == max_retries:
                raise

            print(
                f"Failed (attempt {attempt + 1}/{max_retries + 1}): {e}"
            )

def main():

    download_kaggle_dataset(KAGGLE_DIR)
    download_and_unzip(
        MUN_MESH_URL,
        MUN_MESH_DIR
    )

if __name__ == "__main__":
    main()