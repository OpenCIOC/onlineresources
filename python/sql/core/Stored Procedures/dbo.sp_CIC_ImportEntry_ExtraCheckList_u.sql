
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraCheckList_u]
	@FieldName varchar(100),
	@NUM varchar(8),
	@ListItems xml,
	@BadValues varchar(5000) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @ListTable TABLE (
	EXC_ID int,
	Code varchar(20),
	ListNameEn nvarchar(200),
	ListNameFr nvarchar(200)
)

INSERT INTO @ListTable(
    Code ,
    ListNameEn ,
    ListNameFr
)
SELECT
	N.value('@CD', 'varchar(20)') AS Code,
	N.value('@V', 'nvarchar(200)') AS ListNameEn,
	N.value('@VF', 'nvarchar(200)') AS ListNameFr
FROM @ListItems.nodes('//CHK') as T(N)

UPDATE lt
	SET EXC_ID=(SELECT TOP 1 exc.EXC_ID
		FROM CIC_ExtraCheckList exc
		INNER JOIN CIC_ExtraCheckList_Name excn
			ON exc.EXC_ID=excn.EXC_ID
		WHERE exc.FieldName=@FieldName
			AND [Name]=lt.ListNameEn OR [Name]=lt.ListNameFr
		ORDER BY CASE
			WHEN [Code]=lt.Code THEN 0
			WHEN [Name]=lt.ListNameEn AND LangID=0 THEN 1
			WHEN [Name]=lt.ListNameFr AND LangID=2 THEN 2
			ELSE 3
		END)
FROM @ListTable lt

IF EXISTS(SELECT * FROM @ListTable WHERE EXC_ID IS NOT NULL) BEGIN
	EXEC dbo.sp_CIC_ImportEntry_CIC_Check_i @NUM
END
	
SELECT @BadValues=COALESCE(@BadValues + ' ; ','') + COALESCE(lt.Code, lt.ListNameEn, lt.ListNameFr)
FROM @ListTable lt
WHERE EXC_ID IS NULL

MERGE INTO dbo.CIC_BT_EXC dst
USING (SELECT DISTINCT EXC_ID FROM @ListTable WHERE EXC_ID IS NOT NULL) src
	ON dst.FieldName_Cache=@FieldName AND dst.NUM=@NUM AND dst.EXC_ID=src.EXC_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (FieldName_Cache, NUM, EXC_ID) 
		VALUES (@FieldName, @NUM, src.EXC_ID)
WHEN NOT MATCHED BY SOURCE AND dst.NUM=@NUM AND dst.FieldName_Cache=@FieldName THEN
	DELETE
	;

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraCheckList_u] TO [cioc_login_role]
GO
