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
    GROUP BY
        DimGeography.RegionCountryName
)

SELECT
    RANK() OVER (ORDER BY Lucro DESC) AS Ranking,
    Pais,
    FORMAT(TotalCusto,'C','pt-BR') AS [Total de Custo],
    FORMAT(TotalVenda,'C','pt-BR') AS [Total de Venda],
    FORMAT(Lucro,'C','pt-BR') AS [Lucro],
    FORMAT(Lucro/TotalVenda,'P2','pt-BR') AS [Margem %]
FROM CTE_Totais
ORDER BY Lucro DESC;
