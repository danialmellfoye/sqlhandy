/****** Object:  StoredProcedure [dbo].[USP_CompareTableData]    Script Date: 10/31/2025 4:56:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[USP_CompareTableData] (
	@LeftTable VARCHAR(128),
	@RightTable VARCHAR(128),
	@UniqueJoinColumns VARCHAR(500),  -- Multiple join columns (comma seperated) c
	@IgnoreColumns VARCHAR(500),
	@FilterByStatus VARCHAR (500) --Multiple filter (& seperated and condition, | seperated for or condition)
)
AS
BEGIN

	BEGIN TRY
	
		BEGIN TRANSACTION
		
		DECLARE @Columns TABLE ([ColumnOrder] INT,[CommonColumns] VARCHAR(200))
		INSERT INTO @Columns ([ColumnOrder], [CommonColumns])
		SELECT [ColumnOrder], [COLUMN_NAME] FROM (
		SELECT ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) [ColumnOrder], [COLUMN_NAME] FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_SCHEMA] = PARSENAME(@RightTable,2) AND [TABLE_NAME] = PARSENAME(@RightTable,1)
		INTERSECT
		SELECT ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) [ColumnOrder], [COLUMN_NAME] FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_SCHEMA] = PARSENAME(@LeftTable,2) AND [TABLE_NAME] = PARSENAME(@LeftTable,1)
		) AS SQ1 WHERE QUOTENAME(SQ1.COLUMN_NAME) NOT IN (SELECT [value] FROM STRING_SPLIT(@IgnoreColumns, ','))

		DECLARE @OnCondition VARCHAR(MAX)
		DECLARE @cteCompareRow VARCHAR(MAX)
		IF @UniqueJoinColumns = ''
		BEGIN
			SELECT @OnCondition = CONCAT('CONCAT('''',',STRING_AGG(CONCAT('[l].',[CommonColumns]),','), ') = ', 'CONCAT('''',',STRING_AGG(CONCAT('[r].',[CommonColumns]),','),')') FROM @Columns
		
			SELECT @cteCompareRow = CONCAT('IIF(CONCAT('''',',STRING_AGG(CONCAT('[l].',[CommonColumns]),','), ') = '''',', '''Record Missing in Left table: ', @LeftTable, ''', IIF(CONCAT('''',',STRING_AGG(CONCAT('[r].',[CommonColumns]),','),') = '''',', '''Record Missing in Right table: ', @RightTable, ''', NULL)) [RowComparisonStatus]') FROM @Columns
		END
		ELSE
		BEGIN
			SELECT @OnCondition = CONCAT('CONCAT('''',',STRING_AGG(CONCAT('[l].',[value]),','), ') = ', 'CONCAT('''',',STRING_AGG(CONCAT('[r].',[value]),','),')') FROM STRING_SPLIT(@UniqueJoinColumns,',')
		
			SELECT @cteCompareRow = CONCAT('IIF(CONCAT('''',',STRING_AGG(CONCAT('[l].',[value]),','), ') = '''',', '''Record Missing in Left table: ', @LeftTable, ''', IIF(CONCAT('''',',STRING_AGG(CONCAT('[r].',[value]),','),') = '''',', '''Record Missing in Right table: ', @RightTable, ''', NULL)) [RowComparisonStatus]') FROM STRING_SPLIT(@UniqueJoinColumns,',')
		END
		
		DECLARE @CteDsiplayColumn VARCHAR(MAX)
		SELECT @CteDsiplayColumn = STRING_AGG(CONCAT('[l].', QUOTENAME([CommonColumns]), ' ',REPLACE(QUOTENAME([CommonColumns]),']','_L]'),', ','[r].', QUOTENAME([CommonColumns]), ' ',REPLACE(QUOTENAME([CommonColumns]),']','_R]')),', ') FROM @Columns
		
		DECLARE @CteCompareEachColumn VARCHAR(MAX)
		SELECT @CteCompareEachColumn = STRING_AGG(CONCAT('IIF(ISNULL(CONVERT(VARCHAR,[l].[',[CommonColumns],']),''0'') = ISNULL(CONVERT(VARCHAR,[r].[',[CommonColumns],']),''0''),NULL,''"',[CommonColumns],'"'') [',[CommonColumns],'_C]'),', ') FROM @Columns
		
		DECLARE @CombinedStatus VARCHAR(MAX)
		SELECT @CombinedStatus = CONCAT('REPLACE(CONCAT(''Mismatched Column(s): ['',CONCAT_WS('', '',', STRING_AGG(CONCAT('[',[CommonColumns],'_C]'), ', '), '),'']''),''Mismatched Column(s): []'',''No Mismatch''),[RowComparisonStatus]) [ValueComparisonStatus]') FROM @Columns
		
		DECLARE @FinalDisplayColumn VARCHAR(MAX)
		SELECT @FinalDisplayColumn = STRING_AGG(CONCAT('[',[CommonColumns],'_L], [',[CommonColumns],'_R]'), ', ') FROM @Columns
		
		DECLARE @opr VARCHAR(10)
		SELECT @opr = IIF(CHARINDEX('&', @FilterByStatus) = 0, ' OR ', ' AND ')
		DECLARE @WhereCondition VARCHAR(MAX)
		SELECT @WhereCondition = IIF(ISNULL(@FilterByStatus, '') = '','','WHERE ' + STRING_AGG(CONCAT('[ValueComparisonStatus] LIKE ''%',TRIM([value]),'%'''), @opr)) FROM STRING_SPLIT(@FilterByStatus,IIF(@opr = ' AND ', '&', '|'))
		
		DECLARE @Query VARCHAR(MAX)
		SET @Query = '
		WITH cteColumnComparison 
		AS ( 
			SELECT ' + @cteCompareRow + ', ' + @CteCompareEachColumn + ', ' + @CteDsiplayColumn + ' 
			FROM ' + @LeftTable + ' [l] 
			FULL OUTER JOIN 
			' + @RightTable + ' [r] 
			ON ' + @OnCondition + ' 
		), 
		cteGroupComparionStatus 
		AS ( 
			SELECT IIF([RowComparisonStatus] IS NULL,' + @CombinedStatus + ', ' + @FinalDisplayColumn + ' 
			FROM cteColumnComparison 
		) 
		SELECT * FROM cteGroupComparionStatus ' + @WhereCondition + '; 
		'
		EXEC (@Query);
		
		COMMIT TRANSACTION
	
	END TRY

	BEGIN CATCH
		-- Rollback in case of error
		IF @@TRANCOUNT > 0
		    ROLLBACK TRANSACTION
		
		-- Raise error details
		DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
		RAISERROR (@ErrMsg, @ErrSeverity, 1);
	END CATCH

END
GO


