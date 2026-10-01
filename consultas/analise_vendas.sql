-- Projeto de Análise de Vendas com SQL
-- Consultas desenvolvidas em PostgreSQL

-- =====================================================
-- 01. VENDAS CONCLUÍDAS POR CANAL
-- Objetivo: identificar quais canais concentram
-- a maior quantidade de vendas concluídas.
-- =====================================================

SELECT 
    canal_venda,
    COUNT(venda_id) AS quantidade_vendas
FROM vendas.vendas
WHERE status = 'Concluída'
GROUP BY canal_venda
ORDER BY quantidade_vendas DESC;

-- =====================================================
-- 02. VENDAS CONCLUÍDAS POR FORMA DE PAGAMENTO
-- Objetivo: identificar as formas de pagamento mais
-- utilizadas nas vendas concluídas.
-- =====================================================

SELECT
    forma_pagamento,
    COUNT(venda_id) AS quantidade_vendas
FROM vendas.vendas
WHERE status = 'Concluída'
GROUP BY forma_pagamento
ORDER BY quantidade_vendas DESC;

-- =====================================================
-- 03. VENDAS CONCLUÍDAS POR VENDEDOR
-- Objetivo: identificar os vendedores com maior
-- quantidade de vendas concluídas.
-- =====================================================

SELECT
    v.vendedor_nome,
    COUNT(vendas.venda_id) AS quantidade_vendas
FROM vendas.vendas AS vendas
INNER JOIN vendas.vendedores AS v
    ON vendas.vendedor_id = v.vendedor_id
WHERE vendas.status = 'Concluída'
GROUP BY v.vendedor_nome
ORDER BY quantidade_vendas DESC;


-- =====================================================
-- 04. TOP 10 PRODUTOS POR FATURAMENTO
-- Objetivo: identificar os produtos que geraram
-- o maior faturamento nas vendas concluídas.
-- =====================================================

SELECT
    p.produto_nome,
    ROUND(
        SUM(i.quantidade * i.preco_final_unitario), 2
    ) AS faturamento_total
FROM vendas.itens_venda AS i
INNER JOIN vendas.vendas AS v
    ON i.venda_id = v.venda_id
INNER JOIN vendas.produtos AS p
    ON i.produto_id = p.produto_id
WHERE v.status = 'Concluída'
GROUP BY p.produto_id, p.produto_nome
ORDER BY faturamento_total DESC
LIMIT 10;

-- =====================================================
-- 05. QUANTIDADE VENDIDA POR PRODUTO
-- Objetivo: analisar a movimentação dos produtos,
-- incluindo aqueles que não tiveram vendas.
-- =====================================================

SELECT
    p.produto_nome,
    COALESCE(SUM(i.quantidade), 0) AS quantidade_vendida
FROM vendas.produtos AS p
LEFT JOIN vendas.itens_venda AS i
    ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY quantidade_vendida ASC;

-- =====================================================
-- 06. TOP 10 CLIENTES POR QUANTIDADE DE COMPRAS
-- Objetivo: identificar os clientes que realizaram
-- o maior número de compras concluídas.
-- =====================================================

SELECT
    c.cliente_nome,
    COUNT(v.venda_id) AS quantidade_compras
FROM vendas.vendas AS v
INNER JOIN vendas.clientes AS c
    ON v.cliente_id = c.cliente_id
WHERE v.status = 'Concluída'
GROUP BY c.cliente_id, c.cliente_nome
ORDER BY quantidade_compras DESC
LIMIT 10;

-- =====================================================
-- 07. TOP 10 CLIENTES POR FATURAMENTO
-- Objetivo: identificar os clientes que mais geraram
-- receita por meio das compras concluídas.
-- =====================================================

SELECT
    c.cliente_nome,
    SUM(i.quantidade * i.preco_final_unitario) AS total_gasto
FROM vendas.itens_venda AS i
INNER JOIN vendas.vendas AS v
    ON i.venda_id = v.venda_id
INNER JOIN vendas.clientes AS c
    ON v.cliente_id = c.cliente_id
WHERE v.status = 'Concluída'
GROUP BY c.cliente_id, c.cliente_nome
ORDER BY total_gasto DESC
LIMIT 10;

-- =====================================================
-- 08. EVOLUÇÃO MENSAL DO FATURAMENTO
-- Objetivo: analisar a evolução do faturamento
-- ao longo dos meses.
-- =====================================================

SELECT
    TO_CHAR(v.data_venda, 'YYYY-MM') AS mes,
    SUM(i.quantidade * i.preco_final_unitario) AS faturamento_total
FROM vendas.itens_venda AS i
INNER JOIN vendas.vendas AS v
    ON i.venda_id = v.venda_id
WHERE v.status = 'Concluída'
GROUP BY TO_CHAR(v.data_venda, 'YYYY-MM')
ORDER BY mes ASC;

-- =====================================================
-- 09. CATEGORIAS COM FATURAMENTO ACIMA DA MÉDIA
-- Objetivo: identificar as categorias cujo faturamento
-- total ficou acima da média entre todas as categorias.
-- =====================================================

SELECT
    cat.categoria_nome,
    SUM(i.quantidade * i.preco_final_unitario) AS faturamento_total
FROM vendas.itens_venda AS i
INNER JOIN vendas.vendas AS v
    ON i.venda_id = v.venda_id
INNER JOIN vendas.produtos AS p
    ON i.produto_id = p.produto_id
INNER JOIN vendas.categorias AS cat
    ON p.categoria_id = cat.categoria_id
WHERE v.status = 'Concluída'
GROUP BY cat.categoria_nome
HAVING SUM(i.quantidade * i.preco_final_unitario) > (
    SELECT AVG(faturamento_por_categoria)
    FROM (
        SELECT
            SUM(i2.quantidade * i2.preco_final_unitario)
                AS faturamento_por_categoria
        FROM vendas.itens_venda AS i2
        INNER JOIN vendas.vendas AS v2
            ON i2.venda_id = v2.venda_id
        INNER JOIN vendas.produtos AS p2
            ON i2.produto_id = p2.produto_id
        WHERE v2.status = 'Concluída'
        GROUP BY p2.categoria_id
    ) AS sub_medias
)
ORDER BY faturamento_total DESC;


-- =====================================================
-- 10. RANKING DE VENDEDORES POR FATURAMENTO
-- Objetivo: criar um ranking dos vendedores de acordo
-- com o faturamento gerado nas vendas concluídas.
-- =====================================================

SELECT
    v.vendedor_nome AS vendedor,
    SUM(i.quantidade * i.preco_final_unitario) AS faturamento,
    RANK() OVER (
        ORDER BY SUM(i.quantidade * i.preco_final_unitario) DESC
    ) AS ranking
FROM vendas.itens_venda AS i
INNER JOIN vendas.vendas AS vend
    ON i.venda_id = vend.venda_id
INNER JOIN vendas.vendedores AS v
    ON vend.vendedor_id = v.vendedor_id
WHERE vend.status = 'Concluída'
GROUP BY v.vendedor_nome
ORDER BY ranking ASC;

