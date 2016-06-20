SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_s]
	@MemberID int,
	@ER_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 04-Mar-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@MemberObjectName	nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry_Data ied INNER JOIN CIC_ImportEntry ie ON ied.EF_ID=ie.EF_ID WHERE ied.ER_ID=@ER_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

IF @Error=0 BEGIN
	SELECT	fo.FieldName,
			ISNULL(FieldDisplay, FieldName) AS FieldDisplay
		FROM GBL_FieldOption fo
		LEFT JOIN GBL_FieldOption_Description fod
			ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	WHERE	(CanUseExport = 1) OR FieldName IN ('PUBLICATION','DISTRIBUTION','SUBMIT_CHANGES_TO')

	SELECT	ied.NUM,
			ied.EXTERNAL_ID,
			ied.OWNER, 
			dbo.fn_CIC_ImportEntry_Data_Languages(ied.ER_ID) AS LANGUAGES,
			ied.DATA
		FROM CIC_ImportEntry_Data ied
	WHERE ied.ER_ID=@ER_ID
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_s] TO [cioc_login_role]
GO
