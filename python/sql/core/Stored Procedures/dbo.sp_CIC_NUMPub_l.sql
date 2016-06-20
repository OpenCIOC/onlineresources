SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_l]
	@NUM varchar(8),
	@ViewType int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 30-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @MemberID int,
		@CanSeeNonPublicPub bit

SELECT @MemberID=MemberID, @CanSeeNonPublicPub=CanSeeNonPublicPub
	FROM CIC_View
WHERE ViewType=@ViewType

IF @NUM IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM) BEGIN
	SET @NUM = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @OrganizationProgramObjectName)
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @NUM = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END ELSE IF @MemberID IS NULL BEGIN
	SET @NUM = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
END ELSE IF (SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)<>@MemberID
	AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
			AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanUpdatePubs=1)
		) BEGIN
	SET @NUM = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END

SELECT dbo.fn_GBL_DisplayFullOrgName(@NUM,@@LANGID) AS ORG_NAME_FULL

SELECT pr.BT_PB_ID, pb.PB_ID, pb.PubCode, pbn.Name AS PubName,
		CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_Description WHERE BT_PB_ID=pr.BT_PB_ID) THEN 1 ELSE 0 END AS HAS_DESCRIPTION,
		CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE BT_PB_ID=pr.BT_PB_ID) THEN 1 ELSE 0 END AS HAS_GENHEADINGS,
		CASE WHEN EXISTS(SELECT * FROM CIC_Feedback_Publication WHERE BT_PB_ID=pr.BT_PB_ID) THEN 1 ELSE 0 END AS HAS_FEEDBACK
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID=pb.PB_ID
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE NUM=@NUM
	AND (
		pb.MemberID=@MemberID
		OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=pb.PB_ID AND pbi.MemberID=@MemberID))
	)
	AND (
		@CanSeeNonPublicPub=1
		OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
		OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
	)
ORDER BY pb.PubCode

SELECT pb.PubCode, pbn.Name AS PubName
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID=pb.PB_ID
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE NUM=@NUM
	AND (
		(
			(pb.MemberID<>@MemberID AND pb.MemberID IS NOT NULL)
			OR (pb.MemberID IS NULL AND EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=pb.PB_ID AND pbi.MemberID=@MemberID))
		)
		OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=1)
		OR (@CanSeeNonPublicPub IS NULL AND NOT EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
	)
ORDER BY pb.PubCode

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_l] TO [cioc_login_role]
GO
