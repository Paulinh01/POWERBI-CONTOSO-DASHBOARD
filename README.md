# 📊 Dashboard Executivo Contoso

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Power Query](https://img.shields.io/badge/Power%20Query-217346?style=for-the-badge&logo=microsoft&logoColor=white)
![Status](https://img.shields.io/badge/Status-Conclu%C3%ADdo-brightgreen?style=for-the-badge)

---

## 🚀 Sobre o Projeto

Dashboard Executivo desenvolvido com a base **Contoso Retail (Microsoft)**, com foco na análise de desempenho comercial através de consultas SQL avançadas e visualizações interativas no Power BI.

O objetivo é transformar dados brutos em informações estratégicas para apoiar a tomada de decisão em diferentes níveis da organização — do operacional ao executivo.

---

## 🎯 Perguntas de Negócio Respondidas

- 💰 Qual o lucro total e a margem por continente e país?
- 🏪 Quais lojas têm melhor performance em receita e ticket médio?
- 📦 Quais produtos, marcas e classes geram mais lucro?
- 📈 Como receita e custo evoluíram ao longo dos anos?
- 🎨 Qual a classificação de cores de produto por receita?

---

## 📐 Estrutura do Projeto

```
POWERBI-CONTOSO-DASHBOARD/
│
├── README.md
│
├── dashboards/
│   ├── VisaoGeral.png
│   ├── Performance_Lojas.png
│   └── Performance_Produtos.png
│
├── queries/
│   ├── 01_KPIs_Gerais.sql
│   ├── 02_Ranking_Paises.sql
│   ├── 03_Percentual_Acumulado.sql
│   └── 04_Ranking_Produtos.sql
│
└── docs/
    └── Carrossel_LinkedIn.pdf
```

---

## 📊 Dashboards

### Visão Geral
![Visão Geral](DASHBOARD/1-VisaoGeral.png)
> Receita, Custo e Lucro por Continent, País e Marca ao longo dos anos.

---

### Performance das Lojas
![Performance Lojas](DASHBOARD/2-PerformanceLojas.png)
> Ranking de lojas, Ticket Médio, Receita por Tipo e por Continente.

---

### Performance de Produtos
![Performance Produtos](DASHBOARD/3-PerformanceProdutos.png)
> Ranking de produtos, Receita por Classe, Marca e Classificação de Cores.

---

## 🔢 KPIs Principais

| Indicador | Valor |
|---|---|
| 💰 Receita Total | R$ 12.413.657.608,89 |
| 💸 Custo Total | R$ 5.364.896.601,78 |
| 📈 Lucro Total | R$ 7.048.761.007,11 |
| 🎯 Margem Geral | 56,78% |
| 🏪 Total de Lojas | 306 |
| 📦 Total de Produtos | 2.516 |

---

## 🔍 Queries SQL

### 01 — KPIs Gerais

```sql
WITH CTE_Totais AS
(
    SELECT
        SUM(TotalCost)     AS TotalCusto,
        SUM(SalesAmount)   AS TotalVenda,
        SUM(SalesQuantity) AS QuantidadeVendida,
        SUM(ReturnQuantity) AS QuantidadeRetornada
    FROM FactSales
)
SELECT
    FORMAT(TotalCusto, 'C', 'pt-BR')                              AS [Total de Custo],
    FORMAT(TotalVenda, 'C', 'pt-BR')                              AS [Total de Venda],
    FORMAT(TotalVenda - TotalCusto, 'C', 'pt-BR')                AS [Lucro],
    FORMAT((TotalVenda - TotalCusto) / TotalVenda, 'P2', 'pt-BR') AS [Margem %],
    QuantidadeVendida,
    QuantidadeRetornada,
    FORMAT(TotalVenda / QuantidadeVendida, 'C', 'pt-BR')         AS [Ticket Médio]
FROM CTE_Totais;
```

---

### 02 — Ranking de Países por Lucro

```sql
WITH CTE_Totais AS
(
    SELECT
        DimGeography.RegionCountryName                             AS Pais,
        SUM(FactSales.TotalCost)                                   AS TotalCusto,
        SUM(FactSales.SalesAmount)                                 AS TotalVenda,
        SUM(FactSales.SalesAmount) - SUM(FactSales.TotalCost)     AS Lucro
    FROM FactSales
    INNER JOIN DimStore
        ON FactSales.StoreKey = DimStore.StoreKey
    INNER JOIN DimGeography
        ON DimStore.GeographyKey = DimGeography.GeographyKey
    GROUP BY DimGeography.RegionCountryName
)
SELECT
    RANK() OVER(ORDER BY Lucro DESC)         AS Ranking,
    Pais,
    FORMAT(TotalCusto, 'C', 'pt-BR')        AS [Total de Custo],
    FORMAT(TotalVenda, 'C', 'pt-BR')        AS [Total de Venda],
    FORMAT(Lucro, 'C', 'pt-BR')            AS [Lucro],
    FORMAT(Lucro / TotalVenda, 'P2', 'pt-BR') AS [Margem %]
FROM CTE_Totais
ORDER BY Lucro DESC;
```

---

### 03 — Percentual Acumulado de Lucro por País

```sql
WITH CTE_Totais AS
(
    SELECT
        DimGeography.RegionCountryName                         AS Pais,
        SUM(FactSales.TotalCost)                               AS TotalCusto,
        SUM(FactSales.SalesAmount)                             AS TotalVenda,
        SUM(FactSales.SalesAmount) - SUM(FactSales.TotalCost) AS Lucro
    FROM FactSales
    INNER JOIN DimStore
        ON FactSales.StoreKey = DimStore.StoreKey
    INNER JOIN DimGeography
        ON DimStore.GeographyKey = DimGeography.GeographyKey
    GROUP BY DimGeography.RegionCountryName
),
CTE_Percentual AS
(
    SELECT
        Pais,
        TotalCusto,
        TotalVenda,
        Lucro,
        Lucro / SUM(Lucro) OVER() AS PercentualLucro
    FROM CTE_Totais
)
SELECT
    RANK() OVER(ORDER BY Lucro DESC)            AS Ranking,
    Pais,
    FORMAT(Lucro, 'C', 'pt-BR')               AS [Lucro],
    FORMAT(PercentualLucro, 'P2', 'pt-BR')    AS [% Individual],
    FORMAT(
        SUM(Lucro) OVER(
            ORDER BY Lucro DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(Lucro) OVER(),
        'P2', 'pt-BR'
    )                                          AS [% Acumulado]
FROM CTE_Percentual
ORDER BY Lucro DESC;
```

---

### 04 — Ranking de Produtos com % do Total

```sql
WITH CTE_Produtos AS
(
    SELECT
        DimProduct.ProductName,
        DimProduct.BrandName,
        DimProduct.ClassName,
        SUM(FactSales.SalesAmount)                             AS Receita,
        SUM(FactSales.TotalCost)                               AS Custo,
        SUM(FactSales.SalesAmount) - SUM(FactSales.TotalCost) AS Lucro
    FROM FactSales
    INNER JOIN DimProduct
        ON FactSales.ProductKey = DimProduct.ProductKey
    GROUP BY
        DimProduct.ProductName,
        DimProduct.BrandName,
        DimProduct.ClassName
)
SELECT
    RANK() OVER(ORDER BY Lucro DESC)                         AS Ranking,
    ProductName                                              AS Produto,
    BrandName                                                AS Marca,
    ClassName                                                AS Classe,
    FORMAT(Receita, 'C', 'pt-BR')                          AS [Receita],
    FORMAT(Lucro, 'C', 'pt-BR')                            AS [Lucro],
    FORMAT(Lucro / Receita, 'P2', 'pt-BR')                 AS [Margem %],
    FORMAT(Lucro / SUM(Lucro) OVER(), 'P2', 'pt-BR')       AS [% do Total]
FROM CTE_Produtos
ORDER BY Lucro DESC;
```

---

## 🛠️ Técnicas SQL Utilizadas

| Técnica | Descrição |
|---|---|
| `WITH (CTE)` | Estruturação de queries complexas em etapas legíveis |
| `CTEs Encadeadas` | Duas CTEs dependentes na mesma query |
| `RANK()` | Ranking de registros por valor |
| `SUM() OVER()` | Totais e acumulados via Window Function |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | Acumulado progressivo |
| `FORMAT('C', 'pt-BR')` | Formatação monetária em Real brasileiro |
| `INNER JOIN` | Cruzamento entre tabelas de fato e dimensão |

---

## 📚 Roadmap de Aprendizado

| Skill | Status |
|---|---|
| Excel Avançado | ✅ Concluído |
| Power BI + DAX | ✅ Concluído |
| SQL Fundamentos | ✅ Concluído |
| SQL Avançado (CTEs + Window Functions) | ✅ Concluído |
| Python para Dados | 🔄 Em andamento |
| Git & GitHub | 🔄 Em andamento |

---

## 👤 Autor

**Paulo Wesllem de Queiroz**
Analista de PCP | Power BI | SQL | Dados

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/paulo-wesllem-de-queiroz-a07791302/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/Paulinh01)

---

*Projeto desenvolvido como parte da jornada de migração para Análise de Dados · Jul/2026*
