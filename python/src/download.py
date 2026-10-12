import os
from kaggle.api.kaggle_api_extended import KaggleApi
import csv
from pathlib import Path
import requests
import pandas as pd
import xlrd
import subprocess
from config import (
    IBGE_DATASETS,
    ALTERATIONS,
    IBGE_API_ENDPOINT,
    ALTERATIONS_URL,
    RF_URL,
    RAW_DIR,
    IBGE_OUT,
    RF_EXE,
    RF_UNPACKED,
    RF_CEP,
    RF_MUN,
    RF_OUT
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

def download_ibge(
    url_format: str,
    prefix: str,
    dataset_names: list | dict,
    output_dir_format: str,
):
    
    if isinstance(dataset_names, list):
        dataset_names = {v: v for v in dataset_names}

    for category, dataset in dataset_names.items():

        output_path = Path(output_dir_format.format(prefix=prefix, category=category))

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

def direct_download(
    url: str,
    output_path: str
):
    print(f"Downloading from {url}...")
    
    response = requests.get(url, timeout=30)
    response.raise_for_status()

    Path(output_path).write_bytes(response.content)

    print("Done.")

def unpack_exe(
    raw_exe: str,
    output_path: str
):

    subprocess.run(
        [
            'upx',
            '-d',
            '-o', output_path,
            raw_exe
        ],
        check=True
    )

def extract_bins(
    unpacked_exe: str,
    bin_dir: str,
    cep_fn: str,
    mun_fn: str
):

    for f in [cep_fn, mun_fn]:
        subprocess.run(
            [
                'wrestool',
                '--raw',
                '-x',
                '-t', 'RCDATA',
                '-n', f,
                '-o' f'{bin_dir}/{f}.bin',
                unpacked_exe
            ],
            check=True
        )

def write_rf_csv(
    bin_dir: str,
    output_path: str,
    cep_fn: str,
    mun_fn: str,
):
    
    bin_dir = Path(bin_dir)
    
    mun = {}
    for line in (bin_dir / f"{mun_fn}.bin").read_bytes().splitlines():
        s = line.decode("latin-1").strip()
        if len(s) > 6:
            mun.setdefault(s[:5], set()).add((s[:6], s[6:].strip()))

    amb = {k: v for k, v in mun.items() if len(v) > 1}
    print("municipalities:", len(mun), "| ambiguous 5-digit keys:", len(amb))

    rows, unmatched = 0, set()
    with open(output_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(
            [
                 "cep",
                 "type",
                 "street",
                 "neighborhood",
                 "uf",
				"muni_key",
                "paf",
                "municipality"
            ]
        )
        
        for line in (bin_dir / f"{cep_fn}.bin").read_bytes().splitlines():
            s = line.decode("latin-1")
            if len(s) < 163:
                continue
            key = s[150:155]
            m = mun.get(key)
            name = sorted(m)[0][1] if m else ""
            if not m:
                unmatched.add(key)
            w.writerow(
                [
                    s[0:8],
                    s[8:18].strip(),
                    s[18:88].strip(),
					s[88:148].strip(),
                    s[148:150],
                    key,
                    s[155:163],
                    name
                ]
            )
            rows += 1
    
    print("rows:", rows, "| unmatched keys:", len(unmatched), sorted(unmatched)[:10])
    print("21504 ->", mun.get("21504"))

def extract_rf_data(
    url: str,
    raw_exe: str,
    unpacked_exe: str,
    bin_dir: str,
    cep_fn: str,
    mun_fn: str,
    output_path
):

    direct_download(url, raw_exe)
    unpack_exe(raw_exe, unpacked_exe)
    extract_bins(unpacked_exe, bin_dir, cep_fn, mun_fn)
    write_rf_csv(bin_dir, output_path, cep_fn, mun_fn)

def main():

    download_kaggle_dataset(RAW_DIR)
    download_ibge(IBGE_API_ENDPOINT, "ibge", IBGE_DATASETS, IBGE_OUT)
    download_ibge(ALTERATIONS_URL, "alterations", ALTERATIONS, IBGE_OUT)
    extract_rf_data(RF_URL, RF_EXE, RF_UNPACKED, RAW_DIR, RF_CEP, RF_MUN, RF_OUT)

if __name__ == "__main__":
    main()