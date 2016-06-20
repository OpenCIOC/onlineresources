
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s]
	@ViewType int,
	@MemberID int,
	@SlimResults bit = 0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 28-Feb-2016
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT	vw.*
	FROM CIC_View vw
WHERE vw.MemberID=@MemberID
	AND vw.ViewType = @ViewType

IF @SlimResults = 0 BEGIN

	SELECT *, Culture
		FROM CIC_View_Description vd
		INNER JOIN STP_Language l
			ON l.LangID=vd.LangID 
	WHERE ViewType=@ViewType

	SELECT CanSee
		FROM CIC_View_Recurse
	WHERE ViewType=@ViewType

	SELECT FieldID
		FROM CIC_View_ChkField
	WHERE ViewType=@ViewType

	EXEC dbo.sp_GBL_Display_s_View @ViewType, 1

	SELECT PB_ID
		FROM CIC_View_QuickListPub
	WHERE ViewType=@ViewType
	
	SELECT PB_ID
		FROM CIC_View_AutoAddPub
	WHERE ViewType=@ViewType

END

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_s] TO [cioc_login_role]
GO
