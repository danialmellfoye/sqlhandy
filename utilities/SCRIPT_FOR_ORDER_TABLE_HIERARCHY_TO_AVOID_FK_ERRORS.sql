WITH TableHierarchy AS (
    -- 1. Anchor Member
    SELECT 
        s.name AS SchemaName,
        t.name AS TableName,
        0 AS [Level],
        -- Explicitly cast to NVARCHAR(MAX)
        CAST(s.name + '.' + t.name AS NVARCHAR(MAX)) AS DependencyPath
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.object_id NOT IN (SELECT parent_object_id FROM sys.foreign_keys)

    UNION ALL

    -- 2. Recursive Member
    SELECT 
        s.name AS SchemaName,
        child.name AS TableName,
        th.[Level] + 1,
        -- Explicitly cast the recursive part to NVARCHAR(MAX) as well
        CAST(th.DependencyPath + N' > ' + s.name + N'.' + child.name AS NVARCHAR(MAX))
    FROM sys.tables child
    JOIN sys.schemas s ON child.schema_id = s.schema_id
    JOIN sys.foreign_keys fk ON child.object_id = fk.parent_object_id
    JOIN TableHierarchy th ON fk.referenced_object_id = OBJECT_ID(th.SchemaName + '.' + th.TableName)
    WHERE th.DependencyPath NOT LIKE '%' + s.name + '.' + child.name + '%'
)
-- 3. Final Result
SELECT 
    CONCAT(QUOTENAME(SchemaName), '.',
    QUOTENAME(TableName)) TableName,
    MAX([Level]) AS CreationOrder,
    MAX(DependencyPath) AS ExamplePath
FROM TableHierarchy
GROUP BY SchemaName, TableName
ORDER BY CreationOrder ASC, TableName ASC;
