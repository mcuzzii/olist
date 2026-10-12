# URLs

IBGE_API_ENDPOINT = "https://servicodados.ibge.gov.br/api/v1/localidades/{dataset}?view=nivelado"
ALTERATIONS_URL = "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/alteracoes_toponimicas_municipais/Alteracoes_Toponimicas_Municipais_{dataset}.xls"
RF_URL = "https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/declaracoes-e-demonstrativos/sisobrapref-sistema-de-cadastro-de-obra-modulo-prefeitura/arquivos/atualizacep_01022018.exe/@@download/file"

# Dataset names

IBGE_DATASETS = {
    'subdistricts': 'subdistritos',
    'districts': 'distritos',
    'municipalities': 'municipios'
}
ALTERATIONS = [2025]

# Files and directories

RAW_DIR = "/app/data"
IBGE_OUT = f"{RAW_DIR}/{{prefix}}_{{category}}.csv"
RF_EXE = f"{RAW_DIR}/atualizacep_01022018.exe"
RF_UNPACKED = f"{RAW_DIR}/atualizacep_unpacked.exe"
RF_CEP = "TABCEP"
RF_MUN = "TABMUNI"
RF_OUT = f"{RAW_DIR}/receita_federal_cep.csv"