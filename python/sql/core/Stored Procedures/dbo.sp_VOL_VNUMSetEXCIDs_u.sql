SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMSetEXCIDs_u]
	@FieldName varchar(100),
	@VNUM varchar(10),
	@IdList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 17-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @tmpEXCIDs TABLE(
	EXC_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpEXCIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN VOL_ExtraCheckList exc
		ON tm.ItemID=exc.EXC_ID AND exc.FieldName=@FieldName

MERGE INTO dbo.VOL_OP_EXC dst
USING (SELECT DISTINCT EXC_ID FROM @tmpEXCIDs) src
	ON dst.FieldName_Cache=@FieldName AND dst.VNUM=@VNUM AND dst.EXC_ID=src.EXC_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (FieldName_Cache, VNUM, EXC_ID) 
		VALUES (@FieldName, @VNUM, src.EXC_ID)
WHEN NOT MATCHED BY SOURCE AND dst.VNUM=@VNUM AND dst.FieldName_Cache=@FieldName THEN
	DELETE
	;

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSetEXCIDs_u] TO [cioc_login_role]
GO
