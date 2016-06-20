SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToGeneralHeadings_Groups_rst](
	@MemberID int,
	@NUM varchar(8),
	@PB_ID int,
	@NonPublic bit
)
RETURNS @GeneralHeadings TABLE (
	[GroupID] int NOT NULL,
	[GroupName] nvarchar(200) COLLATE Latin1_General_100_CI_AI NOT NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 22-Feb-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@BT_PB_ID int

IF @PB_ID IS NOT NULL BEGIN
	SELECT @BT_PB_ID = BT_PB_ID FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=@PB_ID
	IF @BT_PB_ID IS NOT NULL BEGIN
		INSERT INTO @GeneralHeadings 
		SELECT ghg.GroupID, ghgn.Name AS GroupName
			FROM CIC_GeneralHeading_Group ghg
			INNER JOIN CIC_GeneralHeading_Group_Name ghgn
				ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=@@LANGID
		WHERE EXISTS(
			SELECT *
				FROM CIC_BT_PB_GH pr
				INNER JOIN CIC_GeneralHeading gh
					ON pr.GH_ID=gh.GH_ID
			WHERE BT_PB_ID=@BT_PB_ID
				AND (@NonPublic=1 OR NonPublic=0)
				AND gh.HeadingGroup=ghg.GroupID
			)
		ORDER BY ghg.DisplayOrder, ghgn.Name
	END
END

RETURN

END



GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToGeneralHeadings_Groups_rst] TO [cioc_cic_search_role]
GO
