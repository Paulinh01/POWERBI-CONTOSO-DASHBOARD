WITH CTE_Totais AS
(
    SELECT
        DimGeography.RegionCountryName AS Pais,
        SUM(FactSales.TotalCost) AS TotalCusto,
        SUM(FactSales.SalesAmount) AS TotalVenda,
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
    Pais,
    FORMAT(TotalCusto, 'C', 'pt-BR') AS [Total de Custo],
    FORMAT(TotalVenda, 'C', 'pt-BR') AS [Total de Venda],
    FORMAT(Lucro, 'C', 'pt-BR') AS [Lucro],
    FORMAT(PercentualLucro, 'P2', 'pt-BR') AS [% do Lucro]
FROM CTE_Percentual
ORDER BY PercentualLucro DESC;
