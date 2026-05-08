# scripts

Esta pasta contém scripts utilitários e reprodutíveis do projeto.

## `padronizar_anuarios_crimes.py`

Lê os arquivos dos anuários de segurança pública em Excel:

- `datasets/crimes/anuario-2023.xlsx`
- `datasets/crimes/anuario-2024.xlsx`
- `datasets/crimes/anuario-2025.xlsx`

E gera arquivos CSV no mesmo layout do histórico de crimes:

- `datasets/crimes/2022-2024_padronizado.csv`
- `datasets/crimes/2016-2024.csv`

Como executar dentro do container Jupyter:

```bash
docker compose exec -T jupyter-service python scripts/padronizar_anuarios_crimes.py
```

Observação:

Os anuários disponibilizam as tabelas de capitais com foco em violência letal. Por isso, o script preserva apenas os indicadores disponíveis em nível de capital e deixa vazios os campos que aparecem apenas em nível de UF.

