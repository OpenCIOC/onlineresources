SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_PageMsg_Toggle]
	@MemberID int,
	@PageMsgID int,
	@IsOn bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: CL
	Checked on: 06-Oct-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

IF @IsOn = 1 BEGIN
INSERT INTO VOL_View_PageMsg
	SELECT ViewType, @PageMsgID
	FROM VOL_View vw
	WHERE NOT EXISTS(
		SELECT * FROM VOL_View_PageMsg
		WHERE ViewType=vw.ViewType AND PageMsgID=@PageMsgID
	) AND (@MemberID IS NULL OR MemberID=@MemberID)
END ELSE BEGIN
	DELETE FROM VOL_View_PageMsg 
	WHERE PageMsgID=@PageMsgID
END


RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_PageMsg_Toggle] TO [cioc_login_role]
GO
