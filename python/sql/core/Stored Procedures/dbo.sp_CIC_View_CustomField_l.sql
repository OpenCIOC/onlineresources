
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_CustomField_l]
	@ViewType int,
	@ForSearch bit,
	@Dates bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: KL
	Checked on: 20-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int

SELECT @MemberID = MemberID FROM dbo.CIC_View WHERE ViewType=@ViewType

SELECT fo.FieldID, ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE	((CanUseResults = 1 AND @ForSearch = 0) OR (CanUseSearch = 1 AND @ForSearch = 1))
		AND (@ForSearch= 0
			OR ((@Dates=1 AND ValidateType = 'd') OR (@Dates=0 AND (ValidateType IS NULL OR ValidateType <> 'd'))))
		AND (ValidateType ='d' OR CanUseDisplay = 0
			OR EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup gp 
				INNER JOIN CIC_View_DisplayField fd
					ON gp.DisplayFieldGroupID = fd.DisplayFieldGroupID
				WHERE ViewType = @ViewType AND fd.FieldID = fo.FieldID))
		AND (FieldName NOT IN ('LATITUDE','LONGITUDE') OR 
			EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MapSearchResults=1))
		AND NOT EXISTS(SELECT * FROM dbo.GBL_FieldOption_InactiveByMember iam WHERE iam.MemberID=@MemberID AND iam.FieldID=fo.FieldID)
ORDER BY ISNULL(FieldDisplay, FieldName)

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_CustomField_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_CustomField_l] TO [cioc_login_role]
GO
