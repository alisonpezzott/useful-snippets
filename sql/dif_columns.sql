-- Lista base de tabelas (nome "novo", sem _old)
WITH BaseTabelas AS (
    SELECT 'CT2010'    AS tabela_new UNION ALL
    SELECT 'CV3010'    UNION ALL
    SELECT 'SA1010'    UNION ALL
    SELECT 'SA3010'    UNION ALL
    SELECT 'SB1010'    UNION ALL
    SELECT 'SBM010'    UNION ALL
    SELECT 'SC5010'    UNION ALL
    SELECT 'ZC3010'    UNION ALL
    SELECT 'SC6010'    UNION ALL
    SELECT 'SCT010'    UNION ALL
    SELECT 'SD1010'    UNION ALL
    SELECT 'SD2010'    UNION ALL
    SELECT 'SE1010'    UNION ALL
    SELECT 'SE5010'    UNION ALL
    SELECT 'SF1010'    UNION ALL
    SELECT 'SF2010'    UNION ALL
    SELECT 'SF4010'    UNION ALL
    SELECT 'SU7010'    UNION ALL
    SELECT 'SU9010'    UNION ALL
    SELECT 'SUD010'    UNION ALL
    SELECT 'SZC010'    UNION ALL
    SELECT 'SZD010'    UNION ALL
    SELECT 'SZU010'    UNION ALL
    SELECT 'Z38010'    UNION ALL
    SELECT 'Z39010'    UNION ALL
    SELECT 'ZB9010'    UNION ALL
    SELECT 'ZBF010'    UNION ALL
    SELECT 'ZEI010'    UNION ALL
    SELECT 'ZF5010'    UNION ALL
    SELECT 'ZF6010'    UNION ALL
    SELECT 'ZJ0010'    UNION ALL
    SELECT 'ZJ1010'    UNION ALL
    SELECT 'ZR2010'    UNION ALL
    SELECT 'ZZH010'    UNION ALL
    SELECT 'SUC010'    UNION ALL
    SELECT 'SX5010'    UNION ALL
    SELECT 'DA0010'    UNION ALL
    SELECT 'AOV010'    UNION ALL
    SELECT 'SYS_COMPANY' UNION ALL
    SELECT 'DA1010'    UNION ALL
    SELECT 'SE4010'
),

-- Monta o par tabela_old / tabela_new
ListaTabelas AS (
    SELECT 
        tabela_new,
        tabela_new + '_old' AS tabela_old
    FROM BaseTabelas
),

-- Encontra colunas que existem em tabela_old e NÃO existem na tabela_new
Dif AS (
    SELECT
        LT.tabela_new,
        LT.tabela_old,
        A.COLUMN_NAME AS coluna_divergente
    FROM ListaTabelas LT
    JOIN INFORMATION_SCHEMA.COLUMNS A
        ON A.TABLE_NAME = LOWER(LT.tabela_old)
       AND A.TABLE_SCHEMA = 'protheus'
    LEFT JOIN INFORMATION_SCHEMA.COLUMNS B
        ON B.TABLE_NAME   = LOWER(LT.tabela_new)
       AND B.TABLE_SCHEMA = 'protheus'
       AND B.COLUMN_NAME  = A.COLUMN_NAME
    WHERE B.COLUMN_NAME IS NULL  -- está só na *_old
),

-- Agrupa as colunas divergentes por tabela
Agrupada AS (
    SELECT
        tabela_new,
        STRING_AGG(coluna_divergente, ', ') AS colunas
    FROM Dif
    GROUP BY tabela_new
)

-- Saída formatada
SELECT '====Tabelas divergentes====' AS resultado
UNION ALL
SELECT
    LT.tabela_new + ': ' + COALESCE(A.colunas, 'nenhuma coluna divergente') AS resultado
FROM ListaTabelas LT
LEFT JOIN Agrupada A
    ON LT.tabela_new = A.tabela_new;
