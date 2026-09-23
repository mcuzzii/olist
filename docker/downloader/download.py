import os
import subprocess
import csv
from pathlib import Path
import requests
import pandas as pd
import xlrd
from config import IBGE_DATASETS, ALTERATIONS, IBGE_API_ENDPOINT, ALTERATIONS_URL, RAW_DIR

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

def download_datasets(
    url_format: str,
    prefix: str,
    dataset_names: list | dict,
    output_dir: Path
):
    
    if isinstance(dataset_names, list):
        dataset_names = {v: v for v in dataset_names}

    for category, dataset in dataset_names.items():

        output_path = output_dir / f"{prefix}_{category}.csv"

        response = requests.get(url_format.format(dataset=dataset), timeout=30)
        response.raise_for_status()

        if prefix == 'ibge':

            data = response.json()

            for row in data:
                for col in row:
                    if row[col] is not None:
                        row[col] = str(row[col])

            df = pd.DataFrame(data)
            df.to_csv(output_path, index=False, encoding="utf-8")

            print(f"Saved {len(df)} records to {output_path}.")

        elif prefix == 'alterations':

            book = xlrd.open_workbook(file_contents=response.content)
            sheet = book.sheet_by_index(0)

            with output_path.open("w", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)

                rows = sheet.get_rows()
                num_rows = 0

                for row in rows:
                    values = []

                    for cell in row:
                        if cell.ctype == xlrd.XL_CELL_EMPTY:
                            values.append("")
                        elif cell.ctype == xlrd.XL_CELL_TEXT:
                            values.append(cell.value)
                        elif cell.ctype == xlrd.XL_CELL_NUMBER:
                            values.append(str(cell.value))
                        elif cell.ctype == xlrd.XL_CELL_DATE:
                            values.append(
                                xlrd.xldate_as_datetime(
                                    cell.value,
                                    book.datemode
                                ).strftime("%d/%m/%Y")
                            )
                        else:
                            values.append(str(cell.value))

                    writer.writerow(values)
                    num_rows += 1

                print(f"Saved {num_rows - 1} records to {output_path}.")

def main():

    download_kaggle_dataset()
    download_datasets(IBGE_API_ENDPOINT, "ibge", IBGE_DATASETS, Path(RAW_DIR))
    download_datasets(ALTERATIONS_URL, "alterations", ALTERATIONS, Path(RAW_DIR))

if __name__ == "__main__":
    main()