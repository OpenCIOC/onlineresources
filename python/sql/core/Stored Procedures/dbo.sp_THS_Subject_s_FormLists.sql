SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Subject_s_FormLists]
	@MemberID int,
	@Subj_ID int,
	@OtherSubjIDs varchar(max) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sj.CREATED_DATE, sj.CREATED_BY, sj.MODIFIED_DATE, sj.MODIFIED_BY,
		sj.MemberID,
		ISNULL(MemberNameCIC,MemberName) AS ManagedBy,
		SUM(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE 0 END) AS UsageCountLocal,
		SUM(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE 0 END) AS UsageCountOther,
		SUM(CASE WHEN shp.BT_ShareProfile_ID IS NOT NULL THEN 1 ELSE 0 END) AS UsageCountShared
	FROM THS_Subject sj
	LEFT JOIN STP_Member_Description memd
		ON memd.MemberID=sj.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN MemberNameCIC IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN memd.LangID=@@LANGID THEN 0 ELSE 1 END, memd.LangID)
	LEFT JOIN CIC_BT_SBJ pr
		On sj.Subj_ID=pr.Subj_ID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
	LEFT JOIN GBL_BT_SharingProfile shp
		ON bt.MemberID<>@MemberID AND shp.NUM=bt.NUM AND shp.ShareMemberID_Cache=@MemberID
WHERE sj.Subj_ID=@Subj_ID
GROUP BY sj.Subj_ID, sj.CREATED_DATE, sj.CREATED_BY, sj.MODIFIED_DATE, sj.MODIFIED_BY, sj.MemberID, MemberNameCIC, MemberName

SELECT c.SubjCat_ID, cn.Category
	FROM THS_Category c
	INNER JOIN THS_Category_Name cn
		ON c.SubjCat_ID=cn.SubjCat_ID AND LangID=(SELECT TOP 1 LangID FROM THS_Category_Name WHERE cn.SubjCat_ID=SubjCat_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
ORDER BY cn.Category

SELECT s.SRC_ID, sn.SourceName
	FROM THS_Source s
	INNER JOIN THS_Source_Name sn
		ON s.SRC_ID=sn.SRC_ID AND LangID=(SELECT TOP 1 LangID FROM THS_Source_Name WHERE sn.SRC_ID=SRC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)

SELECT sj.Subj_ID,
		CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive,
		CASE WHEN sjn.LangID=@@LANGID THEN sjn.Name ELSE '[' + sjn.Name + ']' END AS SubjectTerm
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@OtherSubjIDs, ',') WHERE ItemID=sj.Subj_ID)
		OR EXISTS(SELECT * FROM THS_SBJ_BroaderTerm sbt WHERE sbt.Subj_ID=@Subj_ID AND sbt.BroaderSubj_ID=sj.Subj_ID)
		OR EXISTS(SELECT * FROM THS_SBJ_RelatedTerm srt WHERE srt.Subj_ID=@Subj_ID AND srt.RelatedSubj_ID=sj.Subj_ID)
		OR EXISTS(SELECT * FROM THS_SBJ_UseInstead sui WHERE sui.Subj_ID=@Subj_ID AND sui.UsedSubj_ID=sj.Subj_ID)
		
EXEC dbo.sp_THS_SBJ_UseInstead_For_sl_Admin @Subj_ID, @MemberID

EXEC dbo.sp_THS_SBJ_BroaderTerm_Narrow_sl_Admin @Subj_ID, @MemberID

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_s_FormLists] TO [cioc_login_role]
GO
