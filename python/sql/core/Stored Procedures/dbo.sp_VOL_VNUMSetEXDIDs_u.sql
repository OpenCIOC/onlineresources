SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMSetEXDIDs_u]
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

DECLARE @tmpEXDID int

SELECT TOP 1 @tmpEXDID = EXD_ID
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN VOL_ExtraDropDown exd
		ON tm.ItemID=exd.EXD_ID AND exd.FieldName=@FieldName

MERGE INTO dbo.VOL_OP_EXD dst
USING (SELECT @tmpEXDID AS EXD_ID WHERE @tmpEXDID IS NOT NULL) src
	ON dst.FieldName_Cache=@FieldName AND dst.VNUM=@VNUM AND dst.EXD_ID=src.EXD_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (FieldName_Cache, VNUM, EXD_ID) 
		VALUES (@FieldName, @VNUM, src.EXD_ID)
WHEN NOT MATCHED BY SOURCE AND dst.VNUM=@VNUM AND dst.FieldName_Cache=@FieldName THEN
	DELETE
	;

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSetEXDIDs_u] TO [cioc_login_role]
GO
