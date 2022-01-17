SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_Add_lc]
	@EF_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 13-Mar-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@MemberID int,
		@UsePubNamesOnly bit,
		@ViewPBID int
		
SELECT	@MemberID=MemberID,
		@UsePubNamesOnly=UsePubNamesOnly,
		@ViewPBID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

DECLARE	@MemberObjectName	nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

IF @Error = 0 BEGIN
	;WITH HasDeletes AS (
		SELECT ER_ID, MAX(CASE WHEN iedl.DELETION_DATE IS NOT NULL THEN 1 ELSE 0 END) AS Deletions, MAX(CAST(iedl.NON_PUBLIC AS INT)) AS NonPublics
		FROM dbo.CIC_ImportEntry_Data_Language iedl
		WHERE EXISTS(SELECT * FROM CIC_ImportEntry_Data ied WHERE ied.EF_ID=@EF_ID AND iedl.ER_ID=ied.ER_ID)
		GROUP BY ER_ID
	)
	SELECT SUM(CASE WHEN ied.IMPORTED=0 THEN 1 ELSE 0 END) AS RecordCount, SUM(CAST(ied.IMPORTED AS INT)) AS RetryRecordCount, SUM(hd.Deletions) AS Deletions, SUM(hd.NonPublics) AS NonPublics
		FROM CIC_ImportEntry_Data ied
		INNER JOIN HasDeletes hd
			ON hd.ER_ID=ied.ER_ID
	WHERE ied.EF_ID=@EF_ID
		AND ied.DATA IS NOT NULL
	AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)

	SELECT DISTINCT OWNER
		FROM CIC_ImportEntry_Data ied
	WHERE ied.EF_ID=@EF_ID
		AND ied.DATA IS NOT NULL
	AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
	
	SELECT pb.PB_ID,
		CASE
			WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode)
			ELSE Name
		END AS PubName
		FROM CIC_Publication pb
		LEFT JOIN CIC_Publication_Name pbn
			ON pb.PB_ID=pbn.PB_ID AND LangID=@@LANGID
		LEFT JOIN CIC_View_AutoAddPub aap
			ON pb.PB_ID=aap.PB_ID AND aap.ViewType=@ViewType
	WHERE (MemberID IS NULL OR MemberID=@MemberID)
		AND (aap.PB_ID IS NOT NULL OR pb.PB_ID=@ViewPBID)
	ORDER BY CASE WHEN @UsePubNamesOnly=1 THEN ISNULL(pbn.Name, pb.PubCode) ELSE pb.PubCode END

END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_Add_lc] TO [cioc_login_role]
GO
