# URLs

IBGE_API_ENDPOINT = "https://servicodados.ibge.gov.br/api/v1/localidades/{dataset}?view=nivelado"
ALTERATIONS_URL = "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/alteracoes_toponimicas_municipais/Alteracoes_Toponimicas_Municipais_{dataset}.xls"

# Dataset names

IBGE_DATASETS = {
    'subdistricts': 'subdistritos',
    'districts': 'distritos',
    'municipalities': 'municipios'
}

ALTERATIONS = [2025]

# Directories

RAW_DIR = "/data/raw"