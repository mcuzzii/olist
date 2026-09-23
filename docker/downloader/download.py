import os
import subprocess
import io
import json
from pathlib import Path
import requests
import pandas as pd

IBGE_DATASETS = {
    'subdistricts': 'subdistritos',
    'districts': 'distritos',
    'municipalities': 'municipios'
}
ALTERATIONS = [2014] + list(range(2017, 2026))

IBGE_URL = "https://servicodados.ibge.gov.br/api/v1/localidades/{dataset}?view=nivelado"
ALTERATIONS_URL = (
    "https://geoftp.ibge.gov.br/organizacao_do_territorio/"
    "estrutura_territorial/"
    "alteracoes_toponimicas_municipais/"
    "Alteracoes_Toponimicas_Municipais_{dataset}.xls"
)

RAW_DIR = "/data/raw"

def download_kaggle_dataset():
    dataset = os.environ["KAGGLE_DATASET"]

    subprocess.run(
        [
            "kaggle",
            "datasets",
            "download",
            dataset,
            "--path",
            str(RAW_DIR),
            "--unzip",
        ],
        check=True,
    )

def download_ibge_datasets(
    url_format: str,
    dataset_names: list | dict,
    output_dir: Path
):
    
    if isinstance(dataset_names, list):
        dataset_names = {v: v for v in dataset_names}

    for category, dataset in dataset_names.items():

        output_path = output_dir / f"ibge_{category}.csv"

        response = requests.get(url_format.format(dataset=dataset), timeout=30)
        response.raise_for_status()

        data = response.json()

        id_columns = [col for col in data[0] if col.endswith("-id")]

        for row in data:
            for col in id_columns:
                if row[col] is not None:
                    row[col] = str(row[col])

        df = pd.DataFrame(data)
        df.to_csv(output_path, index=False, encoding="utf-8")

        print(f"Saved {len(df)} records to {output_path}.")

def download_alterations(
    url_format: str,
    dataset_names: list | dict,
    output_dir: Path
):

    if isinstance(dataset_names, list):
        dataset_names = {v: v for v in dataset_names}
    
    for category, dataset in dataset_names.items():
    
        output_path = output_dir / f"alterations_{category}.csv"

        response = requests.get(url_format.format(dataset=dataset), timeout=30)
        response.raise_for_status()

        df = pd.read_excel(io.BytesIO(response.content), dtype=str)
        df.to_csv(output_path, index=False, encoding="utf-8")

        print(f"Saved {len(df)} records to {output_path}.")

def main():

    download_kaggle_dataset()
    download_ibge_datasets(IBGE_URL, IBGE_DATASETS, Path(RAW_DIR))
    download_alterations(ALTERATIONS_URL, ALTERATIONS, Path(RAW_DIR))

if __name__ == "__main__":
    main()