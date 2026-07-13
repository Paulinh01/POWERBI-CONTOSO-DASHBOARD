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
    FORMAT(Lucro,'C','pt-BR') AS Lucro,

    FORMAT(
        Lucro / SUM(Lucro) OVER(),
        'P2','pt-BR'
    ) AS [% Individual],

    FORMAT(
        SUM(Lucro) OVER(
            ORDER BY Lucro DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        /
        SUM(Lucro) OVER(),
        'P2','pt-BR'
    ) AS [% Acumulado]

FROM CTE_Totais
ORDER BY Lucro DESC;
