CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS datamart_seguranca_publica;

COMMENT ON SCHEMA raw IS 'Repositorio de dados brutos, com transformacoes minimas para carga.';
COMMENT ON SCHEMA staging IS 'Camada de limpeza, padronizacao e conformidade dos dados.';
COMMENT ON SCHEMA dw IS 'Data warehouse dimensional em star schema com snowflake parcial.';
COMMENT ON SCHEMA datamart_seguranca_publica IS 'Camada analitica preparada para BI, Metabase e indicadores.';
