CREATE TABLE IF NOT EXISTS raw.idh_municipio_2010 (
    territorialidades TEXT,
    idhm_2010 TEXT,
    idhm_renda_2010 TEXT,
    idhm_longevidade_2010 TEXT,
    idhm_educacao_2010 TEXT,
    arquivo_origem TEXT,
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.crimes_municipio_ano (
    payload JSONB,
    arquivo_origem TEXT,
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.populacao_municipio_ano (
    ano TEXT,
    id_municipio TEXT,
    id_municipio_nome TEXT,
    sexo TEXT,
    grupo_idade TEXT,
    populacao TEXT,
    arquivo_origem TEXT,
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.educacao_ideb (
    ibge_id TEXT,
    dependencia_id TEXT,
    ciclo_id TEXT,
    ano TEXT,
    ideb TEXT,
    fluxo TEXT,
    aprendizado TEXT,
    nota_mt TEXT,
    nota_lp TEXT,
    arquivo_origem TEXT,
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dw.dim_tempo (
    sk_tempo SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE,
    decada INTEGER NOT NULL,
    periodo_analise TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_regiao (
    sk_regiao SERIAL PRIMARY KEY,
    nome_regiao TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dw.dim_uf (
    sk_uf SERIAL PRIMARY KEY,
    codigo_uf_ibge INTEGER NOT NULL UNIQUE,
    sigla_uf CHAR(2) NOT NULL UNIQUE,
    nome_uf TEXT NOT NULL,
    sk_regiao INTEGER NOT NULL REFERENCES dw.dim_regiao(sk_regiao)
);

CREATE TABLE IF NOT EXISTS dw.dim_municipio (
    sk_municipio SERIAL PRIMARY KEY,
    codigo_municipio INTEGER NOT NULL UNIQUE,
    nome_municipio TEXT NOT NULL,
    nome_municipio_padronizado TEXT NOT NULL,
    sk_uf INTEGER NOT NULL REFERENCES dw.dim_uf(sk_uf)
);

CREATE TABLE IF NOT EXISTS dw.dim_dependencia_administrativa (
    sk_dependencia SERIAL PRIMARY KEY,
    dependencia_id INTEGER NOT NULL UNIQUE,
    descricao_dependencia TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_ciclo_educacao (
    sk_ciclo SERIAL PRIMARY KEY,
    ciclo_id TEXT NOT NULL UNIQUE,
    descricao_ciclo TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_localizacao (
    sk_localizacao SERIAL PRIMARY KEY,
    localizacao_id INTEGER NOT NULL UNIQUE,
    descricao_localizacao TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_sexo (
    sk_sexo SERIAL PRIMARY KEY,
    sexo TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dw.dim_faixa_etaria (
    sk_faixa_etaria SERIAL PRIMARY KEY,
    grupo_idade TEXT NOT NULL UNIQUE,
    idade_inicio INTEGER,
    idade_fim INTEGER
);

CREATE TABLE IF NOT EXISTS dw.fact_municipio_ano (
    sk_fato BIGSERIAL PRIMARY KEY,
    sk_tempo INTEGER NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_municipio INTEGER NOT NULL REFERENCES dw.dim_municipio(sk_municipio),
    codigo_municipio INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    id_lote_carga TEXT,
    populacao_total NUMERIC(18, 2),
    populacao_crescimento_pct NUMERIC(12, 4),
    idhm NUMERIC(8, 4),
    idhm_renda NUMERIC(8, 4),
    idhm_educacao NUMERIC(8, 4),
    idhm_longevidade NUMERIC(8, 4),
    ideb NUMERIC(8, 4),
    fluxo NUMERIC(8, 4),
    aprendizado NUMERIC(8, 4),
    nota_mt NUMERIC(10, 4),
    nota_lp NUMERIC(10, 4),
    crimes_total NUMERIC(18, 2),
    mortes_violentas_intencionais NUMERIC(18, 2),
    homicidios_dolosos NUMERIC(18, 2),
    feminicidios NUMERIC(18, 2),
    estupros NUMERIC(18, 2),
    furto_veiculos NUMERIC(18, 2),
    taxa_crimes_100k NUMERIC(18, 6),
    taxa_mortes_violentas_100k NUMERIC(18, 6),
    taxa_homicidios_100k NUMERIC(18, 6),
    taxa_feminicidios_100k NUMERIC(18, 6),
    taxa_estupros_100k NUMERIC(18, 6),
    taxa_furto_veiculos_100k NUMERIC(18, 6),
    risco_indice NUMERIC(18, 6),
    UNIQUE (sk_tempo, sk_municipio)
);

COMMENT ON TABLE dw.fact_municipio_ano IS 'Fato principal com granularidade de um registro por municipio e ano.';
COMMENT ON COLUMN dw.fact_municipio_ano.id_lote_carga IS 'Dimensao degenerada para rastrear lote/arquivo/ciclo de carga.';

CREATE INDEX IF NOT EXISTS idx_fact_municipio_ano_tempo ON dw.fact_municipio_ano(sk_tempo);
CREATE INDEX IF NOT EXISTS idx_fact_municipio_ano_municipio ON dw.fact_municipio_ano(sk_municipio);
CREATE INDEX IF NOT EXISTS idx_fact_municipio_ano_codigo_ano ON dw.fact_municipio_ano(codigo_municipio, ano);
