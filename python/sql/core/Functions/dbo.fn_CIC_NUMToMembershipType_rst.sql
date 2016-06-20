SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToMembershipType_rst](
	@NUM varchar(8)
)
RETURNS @MembershipType TABLE (
	[MT_ID] int NULL,
	[MembershipType] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @MembershipType
SELECT mt.MT_ID, mtn.Name
	FROM CIC_BT_MT pr
	INNER JOIN CIC_MembershipType mt
		ON pr.MT_ID = mt.MT_ID
	INNER JOIN CIC_MembershipType_Name mtn
		ON mt.MT_ID = mtn.MT_ID AND LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY mt.DisplayOrder, mtn.Name

RETURN

END
GO
