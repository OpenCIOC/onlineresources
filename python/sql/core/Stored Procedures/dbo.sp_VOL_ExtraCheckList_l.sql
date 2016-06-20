SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ExtraCheckList_l]
	@MemberID [int],
	@FieldName varchar(100),
	@ShowHidden [bit],
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 17-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT exc.EXC_ID AS EXC_ID, ISNULL(CASE WHEN excn.LangID=@@LANGID THEN excn.Name ELSE '[' + excn.Name + ']' END,exc.Code) AS ExtraCheckList
	FROM VOL_ExtraCheckList exc
	LEFT JOIN VOL_ExtraCheckList_Name excn
		ON exc.EXC_ID=excn.EXC_ID
			AND excn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM VOL_ExtraCheckList_Name WHERE EXC_ID=exc.EXC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE exc.FieldName=@FieldName
	AND COALESCE(excn.Name,exc.Code) IS NOT NULL
	AND (exc.MemberID IS NULL OR @MemberID IS NULL OR exc.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_ExtraCheckList_InactiveByMember WHERE EXC_ID=exc.EXC_ID AND MemberID=@MemberID)
	)
ORDER BY exc.DisplayOrder, ISNULL(excn.Name,exc.Code)

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ExtraCheckList_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_ExtraCheckList_l] TO [cioc_vol_search_role]
GO
