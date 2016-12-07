SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_FormLists]
	@MemberID [int],
	@AgencyCode [char](3),
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 28-Feb-2016
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

DECLARE @DefaultViewType int,
		@DefaultViewName nvarchar(100),
		@DefaultViewOwner char(3),
		@ViewOwner char(3)

SELECT @DefaultViewType=DefaultViewCIC FROM STP_Member WHERE MemberID=@MemberID

SELECT TOP 1 @DefaultViewOwner=Owner, @DefaultViewName=ViewName 
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
WHERE vw.MemberID=@MemberID
	AND vw.ViewType=@DefaultViewType
ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END

SELECT @ViewOwner=Owner
	FROM CIC_View
WHERE ViewType=@ViewType

/* usage */
SELECT
	CASE WHEN @DefaultViewType=@ViewType THEN 1 ELSE 0 END AS IsDefaultView,
	(SELECT COUNT(*) FROM GBL_View_DomainMap WHERE CICViewType = @ViewType) AS UsageCount,
	CASE WHEN EXISTS(SELECT * FROM CIC_View_Recurse WHERE ViewType=@DefaultViewType AND CanSee=@ViewType) THEN 1 ELSE 0 END AS IsPublicView,
	@DefaultViewType AS DefaultViewType, @DefaultViewName AS DefaultViewName, 
	CASE WHEN @DefaultViewOwner IS NULL OR @AgencyCode=@DefaultViewOwner THEN 1 ELSE 0 END AS CanEditDefaultView,
	CASE WHEN @ViewOwner IS NULL OR @AgencyCode IS NULL OR @ViewOwner=@AgencyCode THEN NULL ELSE @ViewOwner END AS ReadOnlyViewOwner,
	(SELECT TOP 1 ViewName FROM dbo.CIC_View_Description WHERE ViewType=@ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS CurrentName

SELECT sl.SL_ID, SecurityLevel
	FROM CIC_SecurityLevel sl
	INNER JOIN CIC_SecurityLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND LangID=(SELECT TOP 1 LangID FROM CIC_SecurityLevel_Name WHERE sln.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE ViewType=@ViewType
	OR EXISTS(SELECT * FROM CIC_SecurityLevel_EditView slev WHERE slev.SL_ID=sl.SL_ID AND slev.ViewType=@ViewType)
ORDER BY SecurityLevel

SELECT Culture 
	FROM STP_Language l
	INNER JOIN CIC_View_Description vd
		ON l.LangID=vd.LangID AND ViewType=@ViewType

/* get Template list */
DECLARE @TemplateOverride varchar(41)

SELECT @TemplateOverride = CAST(Template AS varchar(20)) + ',' + CAST(PrintTemplate AS varchar(20))
	FROM CIC_View
WHERE ViewType=@ViewType

EXEC dbo.sp_GBL_Template_l @MemberID, @AgencyCode, @TemplateOverride

/* get Agency list */

EXEC dbo.sp_CIC_Agency_l @MemberID, 0

/* get View list */
SELECT vw.ViewType, CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType 
			AND vwd.LangID=(SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.ViewType <> @ViewType
	AND MemberID=@MemberID
	AND (@AgencyCode IS NULL OR vw.Owner IS NULL OR vw.Owner=@AgencyCode
			OR (@ViewType IS NOT NULL AND EXISTS(SELECT * 
			FROM CIC_View_Recurse vr
			WHERE vr.ViewType = @ViewType AND vr.CanSee = vw.ViewType)))
ORDER BY vwd.ViewName

/* get Check Field list */
SELECT fo.FieldID, ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
WHERE ChecklistSearch IS NOT NULL AND (fI.FieldID IS NULL OR (@ViewType IS NOT NULL AND EXISTS(SELECT * FROM CIC_View_ChkField chkf WHERE fo.FieldID=chkf.FieldID AND ViewType=@ViewType)))
ORDER BY ISNULL(FieldDisplay, FieldName)

EXEC dbo.sp_GBL_InclusionPolicy_l @MemberID

EXEC dbo.sp_CIC_SearchTips_l @MemberID

EXEC dbo.sp_CIC_View_CustomField_l @ViewType, 0, 0

SELECT pp.ProfileID, ppd.ProfileName
FROM GBL_PrintProfile pp
INNER JOIN GBL_PrintProfile_Description ppd
	ON pp.ProfileID=ppd.ProfileID AND ppd.LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Description WHERE ProfileID=pp.ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE pp.Domain=1 AND (pp.[Public]=1 OR EXISTS(SELECT * FROM CIC_View_PrintProfile WHERE ViewType=@ViewType AND ProfileID=pp.ProfileID))

EXEC dbo.sp_CIC_Publication_l_SharedLocal @MemberID

RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_FormLists] TO [cioc_login_role]
GO
