# URLs

IBGE_API_ENDPOINT = "https://servicodados.ibge.gov.br/api/v1/localidades/{dataset}?view=nivelado"
ALTERATIONS_URL = "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/alteracoes_toponimicas_municipais/Alteracoes_Toponimicas_Municipais_2025.xls"
RF_URL = "https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/declaracoes-e-demonstrativos/sisobrapref-sistema-de-cadastro-de-obra-modulo-prefeitura/arquivos/atualizacep_01022018.exe/@@download/file"

# Dataset names

IBGE_DATASETS = [
    ('subdistricts', 'subdistritos'),
    ('districts', 'distritos'),
    ('municipalities', 'municipios')
]

# Files and directories

RAW_DIR = "/app/data"
IBGE_OUT = f"{RAW_DIR}/{{fn}}.csv"
ALTERATIONS_OUT = f"{RAW_DIR}/alterations.csv"
RF_EXE = f"{RAW_DIR}/atualizacep_01022018.exe"
RF_UNPACKED = f"{RAW_DIR}/atualizacep_unpacked.exe"
RF_CEP = "TABCEP"
RF_MUN = "TABMUNI"
RF_CEP_OUT = f"{RAW_DIR}/dated_zips.csv"
RF_MUN_OUT = f"{RAW_DIR}/dated_municipalities.csv"

# Table configs

RF_CEP_FIELDS = [
    ("NU_CEP", 8),
    ("ID_TIPO_LOGR", 10),
    ("TE_DESCRICAO_CEP", 70),
    ("NM_BAIRRO", 60),
    ("SG_UF", 2),
    ("ID_MUNI_PREV", 5),
    ("ID_PAF", 8),
]
RF_MUN_FIELDS = [
    ("ID_MUNIC", 6),
    ("NM_MUNIC", 30)
]