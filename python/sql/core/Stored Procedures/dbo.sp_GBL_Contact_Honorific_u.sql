SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Contact_Honorific_u]
	@ListValues xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@HonorificObjectName nvarchar(60)
SET @HonorificObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Contact Honorific')

DECLARE @HonorificTable TABLE (
--	OldValue nvarchar(20),
	Honorific nvarchar(20)
)

INSERT INTO @HonorificTable (/*OldValue,*/ Honorific)
SELECT 
--	N.value('OldValue[1]', 'nvarchar(20)') AS OldValue,
	N.value('Honorific[1]', 'nvarchar(20)') AS Honorific
FROM @ListValues.nodes('//CHK') as T(N)

/*
DECLARE @UsedNames nvarchar(max)
SELECT DISTINCT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Honorific
FROM @HonorificTable nt
WHERE EXISTS(SELECT * FROM @HonorificTable ep WHERE Honorific=nt.Honorific AND OldValue<>nt.OldValue)

IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END ELSE BEGIN
*/

	MERGE INTO GBL_Contact_Honorific dst
	USING (SELECT DISTINCT Honorific FROM @HonorificTable) src
		ON dst.Honorific=src.Honorific
	WHEN MATCHED AND src.Honorific<>dst.Honorific COLLATE Latin1_General_100_CS_AS THEN
		UPDATE SET Honorific=src.Honorific
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Honorific)
			VALUES (src.Honorific)
	
	WHEN NOT MATCHED BY SOURCE THEN -- AND NOT EXISTS(SELECT * FROM GBL_Contact WHERE NAME_HONORIFIC=dst.Honorific) THEN
		DELETE 
		
		;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @HonorificObjectName, @ErrMsg
	
--END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_u] TO [cioc_login_role]
GO
