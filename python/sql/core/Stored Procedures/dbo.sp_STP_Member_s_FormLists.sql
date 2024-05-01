SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_STP_Member_s_FormLists]
	@MemberID [int],
	@AgencyCode [char](3),
	@ShowCIC [bit],
	@ShowVOL [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

Declare @DefaultViewCIC varchar(20),
		@DefaultViewVOL varchar(20),
		@TemplateOverride varchar(40)
		
SELECT	@DefaultViewCIC=DefaultViewCIC,
		@DefaultViewVOL=DefaultViewVOL,
		@TemplateOverride=CAST(ISNULL(DefaultTemplate,'') AS varchar) + ',' + CAST(ISNULL(DefaultPrintTemplate,'') AS varchar)
FROM dbo.STP_Member
WHERE MemberID=@MemberID

/* Templates */
EXEC dbo.sp_GBL_Template_l @MemberID, @AgencyCode, @TemplateOverride 

IF @ShowCIC=1 BEGIN
	EXEC dbo.sp_CIC_View_l @MemberID, @AgencyCode, 1, @DefaultViewCIC
	EXEC dbo.sp_CIC_Publication_l_SharedLocal @MemberID
END

IF @ShowVOL=1 BEGIN
	EXEC dbo.sp_VOL_View_l @MemberID, @AgencyCode, 1, @DefaultViewVOL
	EXEC dbo.sp_VOL_ApplicationSurvey_l @MemberID, 1
	
END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_s_FormLists] TO [cioc_login_role]
GO
