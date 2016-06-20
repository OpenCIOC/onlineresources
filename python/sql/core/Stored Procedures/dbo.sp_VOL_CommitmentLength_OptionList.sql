SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommitmentLength_OptionList]
	@MemberID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.2
	Checked by: KL
	Checked on: 08-Nov-2015
	Action: NO ACTION REQUIRED
*/

SELECT cl.CL_ID AS ID, cln.Name
	FROM VOL_CommitmentLength cl
	INNER JOIN dbo.VOL_CommitmentLength_Name cln
		ON cl.CL_ID=cln.CL_ID AND cln.LangID=@@LANGID
WHERE (cl.MemberID IS NULL OR @MemberID IS NULL OR cl.MemberID=@MemberID)
	AND NOT EXISTS(SELECT * FROM VOL_CommitmentLength_InactiveByMember WHERE CL_ID=cl.CL_ID AND MemberID=@MemberID)
ORDER BY cl.DisplayOrder, cln.Name

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommitmentLength_OptionList] TO [cioc_vol_search_role]
GO
