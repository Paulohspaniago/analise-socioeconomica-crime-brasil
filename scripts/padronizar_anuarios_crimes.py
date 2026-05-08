from pathlib import Path
import re

import numpy as np
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
CRIMES_DIR = BASE_DIR / "datasets" / "crimes"
CSV_HISTORICO = CRIMES_DIR / "2016-2021.csv"
CSV_PADRONIZADO = CRIMES_DIR / "2022-2024_padronizado.csv"
CSV_CONSOLIDADO = CRIMES_DIR / "2016-2024.csv"


CAPITAIS = {
    "AC": {"id_municipio": 1200401, "municipio": "Rio Branco", "uf_nome": "Acre"},
    "AL": {"id_municipio": 2704302, "municipio": "Maceió", "uf_nome": "Alagoas"},
    "AM": {"id_municipio": 1302603, "municipio": "Manaus", "uf_nome": "Amazonas"},
    "AP": {"id_municipio": 1600303, "municipio": "Macapá", "uf_nome": "Amapá"},
    "BA": {"id_municipio": 2927408, "municipio": "Salvador", "uf_nome": "Bahia"},
    "CE": {"id_municipio": 2304400, "municipio": "Fortaleza", "uf_nome": "Ceará"},
    "DF": {"id_municipio": 5300108, "municipio": "Brasília", "uf_nome": "Distrito Federal"},
    "ES": {"id_municipio": 3205309, "municipio": "Vitória", "uf_nome": "Espírito Santo"},
    "GO": {"id_municipio": 5208707, "municipio": "Goiânia", "uf_nome": "Goiás"},
    "MA": {"id_municipio": 2111300, "municipio": "São Luís", "uf_nome": "Maranhão"},
    "MG": {"id_municipio": 3106200, "municipio": "Belo Horizonte", "uf_nome": "Minas Gerais"},
    "MS": {"id_municipio": 5002704, "municipio": "Campo Grande", "uf_nome": "Mato Grosso do Sul"},
    "MT": {"id_municipio": 5103403, "municipio": "Cuiabá", "uf_nome": "Mato Grosso"},
    "PA": {"id_municipio": 1501402, "municipio": "Belém", "uf_nome": "Pará"},
    "PB": {"id_municipio": 2507507, "municipio": "João Pessoa", "uf_nome": "Paraíba"},
    "PE": {"id_municipio": 2611606, "municipio": "Recife", "uf_nome": "Pernambuco"},
    "PI": {"id_municipio": 2211001, "municipio": "Teresina", "uf_nome": "Piauí"},
    "PR": {"id_municipio": 4106902, "municipio": "Curitiba", "uf_nome": "Paraná"},
    "RJ": {"id_municipio": 3304557, "municipio": "Rio de Janeiro", "uf_nome": "Rio de Janeiro"},
    "RN": {"id_municipio": 2408102, "municipio": "Natal", "uf_nome": "Rio Grande do Norte"},
    "RO": {"id_municipio": 1100205, "municipio": "Porto Velho", "uf_nome": "Rondônia"},
    "RR": {"id_municipio": 1400100, "municipio": "Boa Vista", "uf_nome": "Roraima"},
    "RS": {"id_municipio": 4314902, "municipio": "Porto Alegre", "uf_nome": "Rio Grande do Sul"},
    "SC": {"id_municipio": 4205407, "municipio": "Florianópolis", "uf_nome": "Santa Catarina"},
    "SE": {"id_municipio": 2800308, "municipio": "Aracaju", "uf_nome": "Sergipe"},
    "SP": {"id_municipio": 3550308, "municipio": "São Paulo", "uf_nome": "São Paulo"},
    "TO": {"id_municipio": 1721000, "municipio": "Palmas", "uf_nome": "Tocantins"},
}


CONFIGS = [
    {
        "arquivo": "anuario-2023.xlsx",
        "aba": "T07",
        "ano": 2022,
        "uf_col": 0,
        "municipio_col": 1,
        "colunas": {
            "quantidade_homicidio_doloso": 3,
            "quantidade_latrocinio": 5,
            "quantidade_lesao_corporal_morte": 7,
            "quantidade_feminicidio": 9,
            "quantidade_mortes_intervencao_policial": 13,
            "quantidade_mortes_violentas_intencionais": 15,
        },
    },
    {
        "arquivo": "anuario-2024.xlsx",
        "aba": "T07",
        "ano": 2023,
        "uf_col": 1,
        "municipio_col": 2,
        "colunas": {
            "quantidade_homicidio_doloso": 4,
            "quantidade_latrocinio": 6,
            "quantidade_lesao_corporal_morte": 8,
            "quantidade_feminicidio": 10,
            "quantidade_mortes_intervencao_policial": 14,
            "quantidade_mortes_violentas_intencionais": 16,
        },
    },
    {
        "arquivo": "anuario-2025.xlsx",
        "aba": "T06",
        "ano": 2024,
        "uf_col": 0,
        "municipio_col": 1,
        "colunas": {
            "quantidade_homicidio_doloso": 3,
            "quantidade_latrocinio": 5,
            "quantidade_lesao_corporal_morte": 7,
            "quantidade_feminicidio": 9,
            "quantidade_mortes_intervencao_policial": 13,
            "quantidade_mortes_violentas_intencionais": 15,
        },
    },
]


def limpar_texto(valor):
    if pd.isna(valor):
        return ""
    valor = str(valor).strip()
    valor = re.sub(r"\s*\(\d+\)\s*", "", valor)
    return valor.strip()


def numero(valor):
    if pd.isna(valor):
        return np.nan
    if isinstance(valor, str):
        valor = valor.strip()
        if valor in {"", "-", "...", "–"}:
            return 0
        valor = valor.replace(".", "").replace(",", ".")
    return pd.to_numeric(valor, errors="coerce")


def linha_vazia_padrao(colunas):
    return {coluna: np.nan for coluna in colunas}


def extrair_anuario(config, colunas_saida):
    caminho = CRIMES_DIR / config["arquivo"]
    df = pd.read_excel(caminho, sheet_name=config["aba"], header=None)

    linhas = []
    for _, row in df.iterrows():
        uf = limpar_texto(row.get(config["uf_col"]))
        if uf not in CAPITAIS:
            continue

        capital = CAPITAIS[uf]
        saida = linha_vazia_padrao(colunas_saida)

        saida.update(
            {
                "ano": config["ano"],
                "sigla_uf": uf,
                "sigla_uf_nome": capital["uf_nome"],
                "id_municipio": capital["id_municipio"],
                "id_municipio_nome": capital["municipio"],
                "grupo": "Pós-pandemia",
            }
        )

        for coluna_saida, coluna_origem in config["colunas"].items():
            saida[coluna_saida] = numero(row.get(coluna_origem))

        mvi = saida["quantidade_mortes_violentas_intencionais"]
        mdip = saida["quantidade_mortes_intervencao_policial"]
        if pd.notna(mvi) and mvi != 0:
            saida["proporcao_mortes_intenvencao_policial_x_mortes_violentas_intencionais"] = (mdip / mvi) * 100

        linhas.append(saida)

    resultado = pd.DataFrame(linhas, columns=colunas_saida)
    return resultado.sort_values(["ano", "sigla_uf"]).reset_index(drop=True)


def main():
    historico = pd.read_csv(CSV_HISTORICO)
    colunas_saida = historico.columns.tolist()

    frames = [extrair_anuario(config, colunas_saida) for config in CONFIGS]
    padronizado = pd.concat(frames, ignore_index=True)
    consolidado = pd.concat([historico, padronizado], ignore_index=True)

    padronizado.to_csv(CSV_PADRONIZADO, index=False)
    consolidado.to_csv(CSV_CONSOLIDADO, index=False)

    print("Arquivo padronizado:", CSV_PADRONIZADO.relative_to(BASE_DIR))
    print("Arquivo consolidado:", CSV_CONSOLIDADO.relative_to(BASE_DIR))
    print("\nLinhas por ano no padronizado:")
    print(padronizado.groupby("ano").size())
    print("\nColunas com dados dos anuarios:")
    print(padronizado.notna().sum()[padronizado.notna().sum() > 0])


if __name__ == "__main__":
    main()
