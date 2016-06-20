
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetEXCIDs_u]
	@FieldName varchar(100),
	@NUM varchar(8),
	@IdList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @tmpEXCIDs TABLE(
	EXC_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpEXCIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CIC_ExtraCheckList exc
		ON tm.ItemID=exc.EXC_ID AND exc.FieldName=@FieldName

MERGE INTO dbo.CIC_BT_EXC dst
USING (SELECT DISTINCT EXC_ID FROM @tmpEXCIDs) src
	ON dst.FieldName_Cache=@FieldName AND dst.NUM=@NUM AND dst.EXC_ID=src.EXC_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (FieldName_Cache, NUM, EXC_ID) 
		VALUES (@FieldName, @NUM, src.EXC_ID)
WHEN NOT MATCHED BY SOURCE AND dst.NUM=@NUM AND dst.FieldName_Cache=@FieldName THEN
	DELETE
	;

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetEXCIDs_u] TO [cioc_login_role]
GO
