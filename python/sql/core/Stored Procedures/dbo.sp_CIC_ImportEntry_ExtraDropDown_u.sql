SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraDropDown_u]
	@FieldName varchar(100),
	@NUM varchar(8),
	@Code varchar(20),
	@ExtraDropDownEn nvarchar(200),
	@ExtraDropDownFr nvarchar(200),
	@BadValue varchar(200) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @EXD_ID int

SELECT @EXD_ID = (SELECT TOP 1 exd.EXD_ID
	FROM CIC_ExtraDropDown exd
	LEFT JOIN CIC_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID
	WHERE exd.FieldName=@FieldName
		AND ([Code]=@Code OR [Name]=@ExtraDropDownEn OR [Name]=@ExtraDropDownFr)
	ORDER BY CASE
		WHEN [Code]=@Code THEN 0
		WHEN [Name]=@ExtraDropDownEn AND LangID=0 THEN 1
		WHEN [Name]=@ExtraDropDownFr AND LangID=2 THEN 2
		ELSE 3
	END)
	
IF @EXD_ID IS NULL BEGIN
	SET @BadValue = COALESCE(@Code,@ExtraDropDownEn,@ExtraDropDownFr)
END

MERGE INTO dbo.CIC_BT_EXD dst
USING (SELECT @EXD_ID AS EXD_ID) src
	ON dst.FieldName_Cache=@FieldName AND dst.NUM=@NUM AND dst.EXD_ID=src.EXD_ID
WHEN NOT MATCHED BY TARGET AND src.EXD_ID IS NOT NULL THEN
	INSERT (FieldName_Cache, NUM, EXD_ID) 
		VALUES (@FieldName, @NUM, src.EXD_ID)
WHEN NOT MATCHED BY SOURCE AND dst.NUM=@NUM AND dst.FieldName_Cache=@FieldName THEN
	DELETE
	;

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraDropDown_u] TO [cioc_login_role]
GO
