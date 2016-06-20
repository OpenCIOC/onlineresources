SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_s]
	@BT_PB_ID int,
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 30-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
	FROM CIC_BT_PB pr 
WHERE BT_PB_ID=@BT_PB_ID

-- ID given ?
IF @BT_PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE BT_PB_ID=@BT_PB_ID) BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @PublicationObjectName)
-- View given ?
END ELSE IF @MemberID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END

IF @BT_PB_ID IS NULL BEGIN
	SET @NUM = NULL
	SET @PB_ID = NULL
END

-- Errors
SELECT @Error AS Error, @ErrMsg AS ErrMsg

-- Org info
SELECT dbo.fn_GBL_DisplayFullOrgName(@NUM,@@LANGID) AS ORG_NAME_FULL

-- Record publication info
SELECT pr.*, pb.PubCode, pbn.Name AS PubName
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID=pb.PB_ID
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE BT_PB_ID=@BT_PB_ID

-- Descriptions
SELECT prd.Description, l.Culture, btd.DESCRIPTION as RecordDescription
FROM GBL_BaseTable_Description btd
INNER JOIN STP_Language l
	ON btd.LangID=l.LangID AND l.Active=1
LEFT JOIN CIC_BT_PB_Description prd
	ON l.LangID=prd.LangID AND prd.BT_PB_ID=@BT_PB_ID
WHERE btd.NUM=@NUM

-- General Headings
SELECT gh.GH_ID, CASE WHEN pr.GH_ID IS NULL THEN 0 ELSE 1 END AS SELECTED,
	ISNULL((SELECT TOP 1 CASE WHEN LangID=@@LANGID THEN Name ELSE '[' + Name + ']' END 
				FROM CIC_GeneralHeading_Name ghn 
				WHERE ghn.GH_ID=gh.GH_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END),cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')) AS Name
	FROM CIC_GeneralHeading gh
	LEFT JOIN CIC_BT_PB_GH pr
		ON pr.GH_ID=gh.GH_ID AND pr.BT_PB_ID=@BT_PB_ID
WHERE gh.PB_ID = @PB_ID
	AND gh.Used=1
ORDER BY DisplayOrder, Name

-- Taxonomy General Headings
SELECT gh.GH_ID, 
	CASE WHEN TaxonomyName=1
		THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID)
		ELSE ISNULL((SELECT TOP 1 CASE WHEN LangID=@@LANGID THEN Name ELSE '[' + Name + ']' END 
				FROM CIC_GeneralHeading_Name ghn 
				WHERE ghn.GH_ID=gh.GH_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END),cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
		END AS Name
	FROM CIC_GeneralHeading gh
	INNER JOIN CIC_BT_PB_GH pr
		ON pr.GH_ID=gh.GH_ID AND pr.BT_PB_ID=@BT_PB_ID
WHERE gh.PB_ID = @PB_ID
	AND gh.Used IS NULL
ORDER BY DisplayOrder, Name

-- Feedback
EXEC dbo.sp_CIC_Feedback_Pub_l @BT_PB_ID, @User_ID, @ViewType

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_s] TO [cioc_login_role]
GO
