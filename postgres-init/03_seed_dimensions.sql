INSERT INTO dw.dim_tempo (ano, decada, periodo_analise)
VALUES
    (2010, 2010, 'Referencia socioeconomica'),
    (2016, 2010, 'Periodo de analise'),
    (2017, 2010, 'Periodo de analise'),
    (2018, 2010, 'Periodo de analise'),
    (2019, 2010, 'Periodo de analise'),
    (2020, 2020, 'Periodo de analise'),
    (2021, 2020, 'Periodo de analise')
ON CONFLICT (ano) DO NOTHING;

INSERT INTO dw.dim_regiao (nome_regiao)
VALUES
    ('Norte'),
    ('Nordeste'),
    ('Centro-Oeste'),
    ('Sudeste'),
    ('Sul')
ON CONFLICT (nome_regiao) DO NOTHING;

INSERT INTO dw.dim_uf (codigo_uf_ibge, sigla_uf, nome_uf, sk_regiao)
SELECT codigo_uf_ibge, sigla_uf, nome_uf, r.sk_regiao
FROM (
    VALUES
        (11, 'RO', 'Rondonia', 'Norte'),
        (12, 'AC', 'Acre', 'Norte'),
        (13, 'AM', 'Amazonas', 'Norte'),
        (14, 'RR', 'Roraima', 'Norte'),
        (15, 'PA', 'Para', 'Norte'),
        (16, 'AP', 'Amapa', 'Norte'),
        (17, 'TO', 'Tocantins', 'Norte'),
        (21, 'MA', 'Maranhao', 'Nordeste'),
        (22, 'PI', 'Piaui', 'Nordeste'),
        (23, 'CE', 'Ceara', 'Nordeste'),
        (24, 'RN', 'Rio Grande do Norte', 'Nordeste'),
        (25, 'PB', 'Paraiba', 'Nordeste'),
        (26, 'PE', 'Pernambuco', 'Nordeste'),
        (27, 'AL', 'Alagoas', 'Nordeste'),
        (28, 'SE', 'Sergipe', 'Nordeste'),
        (29, 'BA', 'Bahia', 'Nordeste'),
        (31, 'MG', 'Minas Gerais', 'Sudeste'),
        (32, 'ES', 'Espirito Santo', 'Sudeste'),
        (33, 'RJ', 'Rio de Janeiro', 'Sudeste'),
        (35, 'SP', 'Sao Paulo', 'Sudeste'),
        (41, 'PR', 'Parana', 'Sul'),
        (42, 'SC', 'Santa Catarina', 'Sul'),
        (43, 'RS', 'Rio Grande do Sul', 'Sul'),
        (50, 'MS', 'Mato Grosso do Sul', 'Centro-Oeste'),
        (51, 'MT', 'Mato Grosso', 'Centro-Oeste'),
        (52, 'GO', 'Goias', 'Centro-Oeste'),
        (53, 'DF', 'Distrito Federal', 'Centro-Oeste')
) AS u(codigo_uf_ibge, sigla_uf, nome_uf, nome_regiao)
JOIN dw.dim_regiao r ON r.nome_regiao = u.nome_regiao
ON CONFLICT (codigo_uf_ibge) DO NOTHING;

INSERT INTO dw.dim_dependencia_administrativa (dependencia_id, descricao_dependencia)
VALUES
    (0, 'Total'),
    (1, 'Federal'),
    (2, 'Estadual'),
    (3, 'Municipal'),
    (4, 'Privada'),
    (5, 'Publica')
ON CONFLICT (dependencia_id) DO NOTHING;

INSERT INTO dw.dim_ciclo_educacao (ciclo_id, descricao_ciclo)
VALUES
    ('AI', 'Anos Iniciais'),
    ('AF', 'Anos Finais'),
    ('EM', 'Ensino Medio')
ON CONFLICT (ciclo_id) DO NOTHING;

INSERT INTO dw.dim_localizacao (localizacao_id, descricao_localizacao)
VALUES
    (0, 'Total'),
    (1, 'Urbana'),
    (2, 'Rural')
ON CONFLICT (localizacao_id) DO NOTHING;

INSERT INTO dw.dim_sexo (sexo)
VALUES
    ('total'),
    ('masculino'),
    ('feminino')
ON CONFLICT (sexo) DO NOTHING;
