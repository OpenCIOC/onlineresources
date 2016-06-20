SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Suitability_OptionList]
	@MemberID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.2
	Checked by: KL
	Checked on: 30-Oct-2015
	Action: NO ACTION REQUIRED
*/

SELECT sb.SB_ID AS ID, sbn.Name
	FROM VOL_Suitability sb
	INNER JOIN VOL_Suitability_Name sbn
		ON sb.SB_ID=sbn.SB_ID AND sbn.LangID=@@LANGID
WHERE (sb.MemberID IS NULL OR @MemberID IS NULL OR sb.MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM VOL_Suitability_InactiveByMember WHERE SB_ID=sb.SB_ID AND MemberID=@MemberID)
ORDER BY sb.DisplayOrder, sbn.Name

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Suitability_OptionList] TO [cioc_vol_search_role]
GO
