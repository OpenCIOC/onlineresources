
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_AIRS_Export_u_Counts] (
	@ViewType [int],
	@LangID [smallint],
	@FieldName nvarchar(100),
	@DateFieldName nvarchar(100),
	@Counts xml,
	@Sent xml,
	@ErrMsg nvarchar(500) OUTPUT
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 16-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE @CountsTable TABLE (
	NUM varchar(8) NOT NULL,
	LangID smallint NOT NULL,
	CNT nvarchar(3) NOT NULL
	PRIMARY KEY (NUM, LangID)
)
DECLARE @SentTable table (
	NUM varchar(8) PRIMARY KEY
)
DECLARE	@FieldObjectName nvarchar(100)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')

IF NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldName=@FieldName) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldName, @FieldObjectName)
	
	RETURN @Error
END

INSERT INTO @CountsTable (NUM, LangID, CNT)
SELECT bt.NUM, src.LangID, src.CNT FROM
(SELECT 
	N.value('@num', 'varchar(8)') AS NUM,
	@@LANGID AS LangID,
	N.value('@count', 'nvarchar(3)') AS CNT
FROM @Counts.nodes('//row') AS T(N)) AS src
INNER JOIN GBL_BaseTable_Description bt
	ON bt.NUM=src.NUM AND bt.LangID=@@LANGID
	
INSERT INTO dbo.CIC_BaseTable_Description
        ( NUM ,
          LangID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY
        )
SELECT btd.NUM, btd.LangID, GETDATE(), '(Unknown)', GETDATE(), '(Unknown)' FROM dbo.GBL_BaseTable_Description btd
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID)
		AND EXISTS(SELECT * FROM @CountsTable dt WHERE dt.NUM=btd.NUM AND dt.LangID=btd.LangID)

	MERGE INTO CIC_BT_EXTRA_TEXT AS dst
	USING @CountsTable AS src
		ON dst.FieldName=@FieldName AND dst.NUM=src.NUM AND dst.LangID=src.LangID
	WHEN MATCHED THEN
		UPDATE SET Value=src.CNT 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (FieldName, NUM, LangID, Value)
			VALUES (@FieldName, src.NUM, src.LangID, src.CNT)
	WHEN NOT MATCHED BY SOURCE AND dst.FieldName=@FieldName AND dst.LangID=@@LANGID THEN
		DELETE
	;

IF @DateFieldName IS NOT NULL AND EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldName=@DateFieldName) BEGIN
	INSERT INTO @SentTable (NUM)
	SELECT bt.NUM FROM
	(SELECT 
		N.value('@num', 'varchar(8)') AS NUM
	FROM @Sent.nodes('//row') as T(N)) as src
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=src.NUM
	
	MERGE INTO CIC_BT_EXTRA_DATE dst
	USING (SELECT DISTINCT NUM FROM @SentTable) src
		ON src.NUM=dst.NUM AND dst.FieldName=@DateFieldName
	WHEN MATCHED THEN
		UPDATE SET Value = GETDATE() 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (FieldName, NUM, Value)
			VALUES (@DateFieldName, NUM, GETDATE())

		;

END
RETURN @Error

SET NOCOUNT OFF








GO





GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_u_Counts] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_u_Counts] TO [cioc_login_role]
GO
