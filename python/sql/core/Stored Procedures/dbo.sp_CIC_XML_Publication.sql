SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_XML_Publication]
	@NUM varchar(8),
	@ProfileID int,
	@HasEnglish bit,
	@HasFrench bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 16-May-2014
	Action: NO ACTION REQUIRED
*/

SELECT (SELECT (SELECT PubCode AS '@V',
			CASE WHEN ed.IncludeDescription=1 THEN prde.Description ELSE NULL END AS '@N',
			CASE WHEN ed.IncludeDescription=1 THEN prdf.Description ELSE NULL END AS '@NF',
			(SELECT
					CASE WHEN gh.TaxonomyName=1 AND btde.LangID IS NOT NULL THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, btde.LangID) ELSE ghne.Name END AS '@V',
					CASE WHEN gh.TaxonomyName=1 AND btdf.LangID IS NOT NULL THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, btdf.LangID) ELSE ghnf.Name END AS '@VF'
				FROM CIC_BT_PB_GH prg
				INNER JOIN CIC_GeneralHeading gh
					ON prg.GH_ID=gh.GH_ID AND ed.IncludeHeadings=1
				LEFT JOIN CIC_GeneralHeading_Name ghne
					ON gh.GH_ID=ghne.GH_ID AND ghne.LangID=btde.LangID
				LEFT JOIN CIC_GeneralHeading_Name ghnf
					ON gh.GH_ID=ghnf.GH_ID AND ghnf.LangID=btdf.LangID
				WHERE prg.BT_PB_ID=pr.BT_PB_ID
					AND (gh.TaxonomyName=1 OR ghne.Name IS NOT NULL OR ghnf.Name IS NOT NULL)
				FOR XML PATH('HD'), TYPE
			) AS HEADINGS
		FROM GBL_BaseTable bt
		LEFT JOIN GBL_BaseTable_Description btde
			ON btde.NUM=bt.NUM AND btde.LangID=0 AND @HasEnglish=1
		LEFT JOIN GBL_BaseTable_Description btdf
			ON btdf.NUM=bt.NUM AND btdf.LangID=2 AND @HasFrench=1
		INNER JOIN CIC_BT_PB pr
			ON pr.NUM=bt.NUM
		LEFT JOIN CIC_BT_PB_Description prde
			ON pr.BT_PB_ID=prde.BT_PB_ID
				AND prde.LangID=btde.LangID
		LEFT JOIN CIC_BT_PB_Description prdf
			ON pr.BT_PB_ID=prdf.BT_PB_ID
				AND prdf.LangID=btdf.LangID
		INNER JOIN CIC_Publication pb
			ON pr.PB_ID=pb.PB_ID
		INNER JOIN CIC_ExportProfile_Pub ed
			ON pb.PB_ID=ed.PB_ID
		WHERE bt.NUM=@NUM
			AND ed.ProfileID=@ProfileID
		FOR XML PATH('CD'), TYPE
	) FOR XML PATH('PUBLICATION')
) AS PUBLICATION

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_CIC_XML_Publication] TO [cioc_login_role]
GO
