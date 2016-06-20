--UPDATE GBL_BaseTable_Description SET DESCRIPTION=DESCRIPTION

DECLARE @STATFIRSTID int, @STATLASTID int, @STATCURRENTID int, @INCREMENT int

SELECT @STATFIRSTID = MIN(BTD_ID), @STATLASTID = MAX(BTD_ID) FROM GBL_BaseTable_Description 
PRINT N'GETTING ROWS FROM ' + CAST(@STATFIRSTID AS nvarchar) + N' TO ' + CAST(@STATLASTID AS nvarchar)

SET @STATCURRENTID = @STATFIRSTID
SET @INCREMENT = 1000

WHILE @STATCURRENTID <= @STATLASTID BEGIN
	PRINT N'SELECT FROM ' + CAST(@STATCURRENTID AS nvarchar) + N' TO ' + CAST(@STATCURRENTID + @INCREMENT AS nvarchar)

UPDATE btd
	SET CMP_DescriptionShort = LTRIM(LEFT(
			REPLACE(REPLACE(REPLACE(
					REPLACE(REPLACE(REPLACE(cioc_shared.dbo.RegexReplace(REPLACE(REPLACE(btd.DESCRIPTION, '<li>', ' * '),'<LI>', ' * '),'<[^>]+>',' '), CHAR(10), ' '), CHAR(9), ' '), CHAR(13), ' '),
				'  ', ' ' + CHAR(1)), CHAR(1) + ' ', ''), CHAR(1), '')
		,200)) + CASE WHEN LEN(btd.DESCRIPTION) > 200 THEN ' ...' ELSE '' END
	FROM GBL_BaseTable_Description btd
	WHERE DESCRIPTION IS NOT NULL AND BTD_ID >= @STATCURRENTID AND BTD_ID < (@STATCURRENTID + @INCREMENT)

	SET @STATCURRENTID = @STATCURRENTID + @INCREMENT
END


UPDATE GBL_FieldOption
	SET DisplayFM = 'btd.CMP_DescriptionShort',
	DisplayFMWeb = 'btd.CMP_DescriptionShort + CASE WHEN RIGHT(btd.CMP_DescriptionShort, 4) = '' ...'' THEN '' '' + cioc_shared.dbo.fn_SHR_GBL_Link_Record(bt.NUM,''['' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(''More'',@@LANGID) + '']'',[HTTP],[PTS]) ELSE '''' END'
WHERE FieldName = 'DESCRIPTION_SHORT'

