# Analise e Predicao de Criminalidade no Brasil

## Visao Geral

Este projeto tem como objetivo analisar e prever tendencias de criminalidade no Brasil a partir da integracao de dados de seguranca publica com variaveis socioeconomicas, como:

- IDH
- populacao
- educacao

O fluxo principal do projeto sera:

```text
Jupyter
-> limpeza
-> tratamento de nulos
-> remocao de duplicatas
-> feature engineering
-> regressao linear / ML
-> MongoDB
-> Metabase
```

## Stack

- Python
- Jupyter Notebook
- MongoDB
- Mongo Express
- Metabase
- Docker Compose

## Estrutura do Projeto

```text
project/
├── docker-compose.yml
├── datasets/
├── notebooks/
├── db-seed/
├── metabase-data/
└── README.md
```

## Estrutura Atual

```text
.
├── docker-compose.yml
├── datasets/
│   └── README.md
├── notebooks/
│   ├── 01_exploracao_dados.ipynb
│   ├── 02_limpeza_tratamento.ipynb
│   ├── 03_integracao_feature_engineering.ipynb
│   ├── 04_modelagem_regressao_linear.ipynb
│   ├── 05_exportacao_mongodb.ipynb
│   └── README.md
├── db-seed/
│   └── README.md
├── metabase-data/
│   └── README.md
└── README.md
```

## Responsabilidade de Cada Ferramenta

### Jupyter

Usado para:

- leitura dos arquivos
- exploracao dos dados
- limpeza e tratamento
- integracao das bases
- criacao de features
- treino inicial do modelo de regressao linear

### MongoDB

Usado para:

- armazenar dados tratados
- salvar colecoes finais
- guardar resultados e previsoes

### Metabase

Usado para:

- conectar no MongoDB
- criar dashboards
- visualizar KPIs e analises

## Como Subir o Ambiente

```bash
docker compose up -d
```

Servicos esperados:

- Jupyter: `http://localhost:8888`
- MongoDB: `localhost:27017`
- Mongo Express: `http://localhost:8081`
- Metabase: `http://localhost:3000`

## Proximo Passo

O proximo passo recomendado e implementar o primeiro notebook de exploracao e limpeza do dataset de crime, definindo a chave unificada `estado + ano` para todas as bases.
* **Preventive actions** in high-risk areas
* Data-driven **public policy decisions**

---

## 📄 License

This project is for educational and research purposes.

---

## 👤 Author

Paulo Paniago & Team
