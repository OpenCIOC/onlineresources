
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_s]
	@MemberID [int],
	@PB_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 28-Apr-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT pb.*,
		(SELECT COUNT(*) FROM CIC_BT_PB pr INNER JOIN dbo.GBL_BaseTable bt ON bt.NUM = pr.NUM AND bt.MemberID=@MemberID WHERE PB_ID=@PB_ID) AS UsageCountLocal,
		(SELECT COUNT(*) FROM CIC_BT_PB pr INNER JOIN dbo.GBL_BaseTable bt ON bt.NUM = pr.NUM AND bt.MemberID<>@MemberID WHERE PB_ID=@PB_ID) AS UsageCountOther
	FROM CIC_Publication pb
WHERE pb.PB_ID=@PB_ID
	AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)

SELECT pbn.*, l.Culture
	FROM CIC_Publication_Name pbn
	INNER JOIN STP_Language l
		ON pbn.LangID=l.LangID
WHERE PB_ID = @PB_ID 

SELECT vw.ViewType, CASE WHEN vwd.LangID=@@LangID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		vw.MemberID,
		ISNULL(memd.MemberNameCIC,memd.MemberName) AS MemberName
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LangID THEN 0 ELSE 1 END, LangID)
	INNER JOIN STP_Member mem
		ON vw.MemberID=mem.MemberID
	LEFT JOIN STP_Member_Description memd
		ON mem.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=mem.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE PB_ID=@PB_ID
ORDER BY CASE WHEN vw.MemberID=@MemberID THEN 0 ELSE 1 END, vwd.ViewName

SELECT	ghg.GroupID,
		ghg.DisplayOrder,
		ghg.IconNameFull,
		(SELECT ghgd.Name, l.Culture
		FROM CIC_GeneralHeading_Group_Name ghgd
			INNER JOIN STP_Language l
				ON l.LangID=ghgd.LangID
		WHERE ghgd.GroupID=ghg.GroupID
		FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
	FROM CIC_GeneralHeading_Group ghg
WHERE ghg.PB_ID=@PB_ID
ORDER BY DisplayOrder, 
	(SELECT TOP 1 Name FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)

SELECT gh.GH_ID, ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']')
	FROM CIC_GeneralHeading gh
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.TaxonomyName=0
			AND gh.GH_ID=ghn.GH_ID
			AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE gh.PB_ID=@PB_ID
ORDER BY DisplayOrder, ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']')

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_s] TO [cioc_login_role]
GO
