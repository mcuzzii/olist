import os
from kaggle.api.kaggle_api_extended import KaggleApi
import csv
from pathlib import Path
import requests
import pandas as pd
import xlrd
import subprocess
import time
from config import (
    IBGE_DATASETS,
    IBGE_API_ENDPOINT,
    ALTERATIONS_URL,
    RF_URL,
    RAW_DIR,
    IBGE_OUT,
    ALTERATIONS_OUT,
    RF_EXE,
    RF_UNPACKED,
    RF_CEP,
    RF_MUN,
    RF_CEP_OUT,
    RF_MUN_OUT,
    RF_CEP_FIELDS,
    RF_MUN_FIELDS
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
    dataset_names: list,
    output_dir_format: str,
):

    for category, dataset in dataset_names:

        output_path = output_dir_format.format(fn=category)

        response = requests.get(url_format.format(dataset=dataset), timeout=30)
        response.raise_for_status()

        data = response.json()

        for row in data:
            for col in row:
                if row[col] is not None:
                    row[col] = str(row[col])

        df = pd.DataFrame(data)
        df.to_csv(output_path, index=False, encoding="utf-8")

        print(f"Saved {len(df)} records to {output_path}.")

def download_ibge_alterations(
    url: str,
    output_path: str
):

    response = requests.get(url, timeout=30)
    response.raise_for_status()

    book = xlrd.open_workbook(file_contents=response.content)
    sheet = book.sheet_by_index(0)

    with Path(output_path).open("w", newline="", encoding="utf-8") as f:
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
    output_path: str,
    max_retries: int = 3,
):
    print(f"Downloading from {url}...")

    for attempt in range(max_retries + 1):
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()

            Path(output_path).write_bytes(response.content)

            print("Done.")
            return

        except requests.RequestException as e:
            if attempt == max_retries:
                raise

            print(
                f"Download failed (attempt {attempt + 1}/"
                f"{max_retries + 1}): {e}"
            )
            time.sleep(2 ** attempt)

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
    bin_path: str,
    output_path: str,
    fields: list,
    encoding: str = "latin-1",
    skip_on_short: bool = False
):

    line_len = sum([w for _, w in fields])
    
    rows = short = nonascii = bad_tail = mismatch = 0

    with open(output_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow([name for name, _ in fields])

        for raw in Path(bin_path).read_bytes().splitlines():

            s = raw.decode(encoding)

            if not raw.isascii():
                nonascii += 1

            if len(s) < line_len:
                short += 1

                if skip_on_short:
                    continue

            if s[line_len:].strip():
                bad_tail += 1
            
            values, pos = [], 0

            for _, width in fields:
                values.append(s[pos:pos + width].rstrip())
                pos += width

            rebuilt = "".join(v.ljust(w_) for v, (_, w_) in zip(values, fields))
            if rebuilt != s[:line_len]:
                mismatch += 1

            w.writerow(values)
            rows += 1

    print(
        f"{bin_path}: rows={rows:,} short={short:,} non-ascii lines={nonascii:,} "
        f"non-blank tail={bad_tail:,} round-trip mismatches={mismatch:,}"
    )

def extract_rf_data(
    url: str,
    raw_exe: str,
    unpacked_exe: str,
    bin_dir: str,
    cep_fn: str,
    mun_fn: str,
    cep_fields: list,
    mun_fields: list,
    cep_output_path: str,
    mun_output_path: str
):

    direct_download(
        url,
        raw_exe
    )
    unpack_exe(
        raw_exe,
        unpacked_exe
    )
    extract_bins(
        unpacked_exe,
        bin_dir,
        cep_fn,
        mun_fn
    )
    write_rf_csv(
        f"{bin_dir}/{cep_fn}.bin",
        cep_output_path, cep_fields,
        skip_on_short=True
    )
    write_rf_csv(
        f"{bin_dir}/{mun_fn}.bin",
        mun_output_path,
        mun_fields
    )

def load_correios(
    max_retries: int = 3
):
    command = [
        "uv", "run", "edne-correios-loader", "load",
        "--database-url", (
            f"postgresql://{os.environ['PGUSER']}:"
            f"{os.environ['PGPASSWORD']}@"
            f"{os.environ['PGHOST']}:{os.environ['PGPORT']}/"
            f"{os.environ['PGDATABASE']}"
        ),
        "--tables", "all",
    ]

    for attempt in range(max_retries + 1):
        try:
            subprocess.run(command, check=True)
            print("Done.")
            return

        except subprocess.CalledProcessError as e:
            if attempt == max_retries:
                raise

            print(
                f"Command failed (attempt {attempt + 1}/"
                f"{max_retries + 1}, exit code {e.returncode})."
            )
            time.sleep(2 ** attempt)

def main():

    download_kaggle_dataset(RAW_DIR)
    download_ibge(
        IBGE_API_ENDPOINT,
        IBGE_DATASETS,
        IBGE_OUT
    )
    download_ibge_alterations(
        ALTERATIONS_URL,
        ALTERATIONS_OUT
    )
    extract_rf_data(
        RF_URL,
        RF_EXE,
        RF_UNPACKED,
        RAW_DIR,
        RF_CEP,
        RF_MUN,
        RF_CEP_FIELDS,
        RF_MUN_FIELDS,
        RF_CEP_OUT,
        RF_MUN_OUT
    )
    load_correios()

if __name__ == "__main__":
    main()