# 🇧🇷 Socioeconomic Drivers of Crime in Brazil

## 📊 Overview

This project aims to analyze and predict public safety incidents in Brazil by combining socioeconomic indicators such as **Human Development Index (HDI)**, **population growth**, and **education levels**.

The goal is to understand how these variables influence crime rates and support **data-driven decision-making** for governments and organizations.

---

## 🎯 Objectives

* Analyze the relationship between **crime rates and socioeconomic factors**
* Evaluate the impact of **education (INEP/IBGE)** on public safety
* Build a **predictive model** for crime trends over time
* Provide insights to support **resource allocation and prevention strategies**

---

## 🧠 Key Questions

* Do regions with lower education levels have higher crime rates?
* How does population growth impact public safety?
* Is education more correlated with crime reduction than HDI?
* Which regions are at higher risk over time?

---

## 🏗️ Architecture

```mermaid
flowchart LR
    A[Raw Data Sources] --> B[Jupyter - Cleaning and EDA]
    B --> C[Null Handling and Deduplication]
    C --> D[Feature Engineering]
    D --> E[Linear Regression / ML]
    D --> F[PostgreSQL - Raw, Staging, DW]
    F --> G[Data Mart Views]
    G --> H[Metabase Dashboard]
    E --> G
```

---

## 🧰 Tech Stack

* **Python** (Pandas, NumPy, Scikit-learn)
* **Jupyter Notebook** (EDA, cleaning, feature engineering, modeling)
* **PostgreSQL** (Raw data, staging, data warehouse, and data marts)
* **pgAdmin** (Database administration)
* **Metabase** (Dashboards and KPI analysis)
* **Docker & Docker Compose** (Environment setup)
* **Git & GitHub** (Collaboration)

---

## 📂 Project Structure

```text
.
├── docker-compose.yml
├── docker/
├── README.md
├── datasets/
├── notebooks/
│   ├── 01_exploracao_dados.ipynb
│   ├── 02_limpeza_tratamento.ipynb
│   ├── 03_integracao_feature_engineering.ipynb
│   ├── 04_modelagem_regressao_linear.ipynb
│   └── 05_exportacao_dw_postgresql.ipynb
├── postgres-init/
├── metabase-data/
├── docs/
└── src/
```

---

## 📊 Data Sources

* Public Safety Data (criminality datasets)
* HDI Data
* Population Data
* Education Data from Ministério da Educação / INEP / IBGE

---

## ⚙️ Setup (Docker)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 2. Start containers

```bash
docker compose up -d --build
```

---

## 🔗 Services

| Service             | URL                   |
| ------------------- | --------------------- |
| Jupyter Notebook    | http://localhost:8888 |
| PostgreSQL          | localhost:5432        |
| pgAdmin             | http://localhost:8081 |
| Metabase            | http://localhost:3000 |

Docker Compose service names:

* `postgres-service`
* `pgadmin-service`
* `jupyter-service`
* `metabase-service`

---

## 🔬 Methodology

### 1. Data Cleaning

* Read raw files from `datasets/`
* Handle missing values
* Remove duplicates
* Normalize formats
* Align datasets by `municipality code + year`

---

### 2. Feature Engineering

* Crime rate per 100k inhabitants
* Population growth rate
* Education indicators
* Time-based features

---

### 3. Modeling

We use a **Linear Regression model** as the first baseline to predict crime rates:

$$
crime\_rate = f(HDI, Population, Education, Time)
$$

---

### 4. Data Warehouse

PostgreSQL is used to organize the analytical pipeline into schemas:

* `raw`: raw or nearly raw datasets
* `staging`: cleaned and standardized datasets
* `dw`: dimensional model with facts and dimensions
* `datamart_seguranca_publica`: analytical views for BI

---

### 5. Visualization

Dashboards built in **Metabase**:

* Regional crime distribution
* Correlation analysis
* Risk ranking
* Trends over time
* KPI monitoring

---

## 🤝 Collaboration

Each team member is responsible for a specific area:

* Data Engineering (ETL, cleaning, PostgreSQL and DW publishing)
* Machine Learning
* Database Modeling
* Dashboard & Visualization
* Documentation

### Workflow

* Feature branches
* Pull Requests
* Code reviews

---

## ⚠️ Limitations

* Limited socioeconomic variables
* Possible data inconsistencies across sources
* Linear model assumptions
* Correlation ≠ causation

---

## 🚀 Future Improvements

* Add more variables (income, unemployment)
* Use advanced models (ARIMA, Prophet)
* Move reusable transformations from notebooks into production code
* Deploy API for predictions

---

## 💡 Business Impact

This project enables:

* Better **resource allocation**
* **Preventive actions** in high-risk areas
* Data-driven **public policy decisions**

---

## 📄 License

This project is for educational and research purposes.

---

## 👤 Author

Paulo Paniago & Team
