WITH CTE_Totais AS
(
    SELECT
        SUM(TotalCost) AS TotalCusto,
        SUM(SalesAmount) AS TotalVenda,
        SUM(SalesQuantity) AS QuantidadeVendida,
        SUM(ReturnQuantity) AS QuantidadeRetornada
    FROM FactSales
)

SELECT
    FORMAT(TotalCusto, 'C', 'pt-BR') AS [Total de Custo],
    FORMAT(TotalVenda, 'C', 'pt-BR') AS [Total de Venda],
    FORMAT(TotalVenda - TotalCusto, 'C', 'pt-BR') AS [Lucro],
    FORMAT((TotalVenda - TotalCusto) / TotalVenda, 'P2', 'pt-BR') AS [Margem %],
    QuantidadeVendida,
    QuantidadeRetornada,
    FORMAT(TotalVenda / QuantidadeVendida, 'C', 'pt-BR') AS [Ticket Médio]
FROM CTE_Totais;
