SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_BoxType_u]
	@MODIFIED_BY nvarchar(50),
	@ListValues xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 04-Oct-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@PostalBoxTypeObjectName nvarchar(60)
SET @PostalBoxTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Postal Box Type')

DECLARE @BoxTypeTable table (
	BT_ID int,
	BoxType nvarchar(20)
)

INSERT INTO @BoxTypeTable (BT_ID, BoxType)
SELECT 
	N.value('BT_ID[1]', 'int') AS BT_ID,
	N.value('BoxType[1]', 'nvarchar(20)') AS BoxType
FROM @ListValues.nodes('//CHK') AS T(N)

DECLARE @UsedNames nvarchar(MAX)

SELECT DISTINCT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + BoxType
FROM @BoxTypeTable nt
WHERE EXISTS(SELECT * FROM @BoxTypeTable ep WHERE BoxType=nt.BoxType AND BT_ID<>nt.BT_ID)

IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END ELSE BEGIN
	MERGE INTO GBL_BoxType dst
	USING (SELECT DISTINCT BT_ID, BoxType FROM @BoxTypeTable) src
		ON dst.BT_ID=src.BT_ID
	WHEN MATCHED AND src.BoxType<>dst.BoxType COLLATE Latin1_General_100_CS_AS THEN
		UPDATE SET BoxType=src.BoxType, MODIFIED_DATE=GETDATE(), MODIFIED_BY=@MODIFIED_BY
		
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE, BoxType)
			VALUES (@MODIFIED_BY, GETDATE(), @MODIFIED_BY, GETDATE(), src.BoxType)
	
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE 
		
		;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PostalBoxTypeObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BoxType_u] TO [cioc_login_role]
GO
