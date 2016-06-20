SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullRecordPrivacy](
	@PrivacyProfile [int],
	@UpdatePassword [varchar](20),
	@UpdatePasswordRequired [bit]
)
RETURNS [nvarchar](250) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr		nvarchar(500),
		@ProfileName	varchar(100)

SET @ProfileName = NULL
SET @returnStr = NULL

IF @UpdatePassword IS NOT NULL AND @UpdatePasswordRequired IS NOT NULL BEGIN
	SET @returnStr = CASE
		WHEN @UpdatePasswordRequired=0 AND @ProfileName IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Password required for Feedback on private information.')
		WHEN @UpdatePasswordRequired=1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Password required for all Feedback.')
		END
END

IF @PrivacyProfile IS NOT NULL BEGIN
	SELECT TOP 1 @ProfileName = ProfileName
		FROM GBL_PrivacyProfile_Name
	WHERE ProfileID=@PrivacyProfile
	ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
	IF @ProfileName IS NOT NULL BEGIN
		SET @returnStr = CASE WHEN @returnStr IS NULL THEN '' ELSE @returnStr + CHAR(13) + CHAR(10) END
			+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Privacy Profile') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @ProfileName
	END
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FullRecordPrivacy] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullRecordPrivacy] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullRecordPrivacy] TO [cioc_vol_search_role]
GO
