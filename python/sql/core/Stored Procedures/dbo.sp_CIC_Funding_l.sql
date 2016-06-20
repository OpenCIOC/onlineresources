
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Funding_l]
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT fd.FD_ID, CASE WHEN fdn.LangID=@@LANGID THEN fdn.Name ELSE '[' + fdn.Name + ']' END AS FundingType
	FROM CIC_Funding fd
	INNER JOIN CIC_Funding_Name fdn
		ON fd.FD_ID=fdn.FD_ID
			AND fdn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_Funding_Name WHERE FD_ID=fd.FD_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (fd.MemberID IS NULL OR @MemberID IS NULL OR fd.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_Funding_InactiveByMember WHERE FD_ID=fd.FD_ID AND MemberID=@MemberID)
	)
ORDER BY fd.DisplayOrder, fdn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Funding_l] TO [cioc_login_role]
GO
