SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExcelProfile_sf]
	@ProfileID [int],
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberID int,
		@RespectPrivacyProfile bit

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

IF @RespectPrivacyProfile=0
		AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND CanViewPrivate=0) BEGIN
	SET @RespectPrivacyProfile = NULL
END

-- View ID given ?
IF @ViewType IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ProfileID = NULL
-- View exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ProfileID = NULL
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ProfileID = NULL
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE ProfileID=@ProfileID AND Domain=1 AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
-- Profile ID in View ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_View_ExcelProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
END

DECLARE @ColumnHeaders bit,
		@FieldList varchar(max),
		@SortList varchar(max)

SET @FieldList = NULL
SET @SortList = NULL

DECLARE @DisplayTable TABLE (
	FieldName varchar(100) NOT NULL PRIMARY KEY,
	FieldDisplay nvarchar(100),
	FieldSelect nvarchar(max),
	CheckHTML bit,
	DisplayOrder tinyint,
	SortByOrder tinyint
)

SELECT @ColumnHeaders=ColumnHeaders
	FROM GBL_ExcelProfile ep
WHERE ep.ProfileID=@ProfileID

INSERT INTO @DisplayTable
SELECT
	FieldName,
	CASE WHEN @ColumnHeaders=1 THEN ISNULL(fod.FieldDisplay,fo.FieldName) ELSE fo.FieldName END AS FieldDisplay,
	dbo.fn_GBL_FieldOption_Display(
			@MemberID,
			@ViewType,
			fo.FieldID,
			fo.FieldName,
			@RespectPrivacyProfile,
			fo.PrivacyProfileIDList,
			CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
			fo.DisplayFM,
			fo.DisplayFMWeb,
			fo.FieldType,
			fo.FormFieldType,
			fo.EquivalentSource,
			fod.CheckboxOnText,
			fod.CheckboxOffText,
			0
		) AS FieldSelect,
		fo.CheckHTML,
		epf.DisplayOrder,
		epf.SortByOrder
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN GBL_ExcelProfile_Fld epf
		ON fo.FieldID=epf.GBLFieldID
	INNER JOIN GBL_ExcelProfile ep
		ON epf.ProfileID=ep.ProfileID
WHERE ep.ProfileID=@ProfileID
ORDER BY epf.DisplayOrder, CASE WHEN @ColumnHeaders=1 THEN ISNULL(fod.FieldDisplay,fo.FieldName) ELSE fo.FieldName END

SELECT @FieldList=COALESCE(@FieldList+',','') + FieldSelect + ' AS [' + FieldName + ']'
	FROM @DisplayTable
WHERE DisplayOrder IS NOT NULL

DECLARE @SortListTable TABLE (
	FieldSelect varchar(max)
)

INSERT INTO @SortListTable
SELECT TOP 10 FieldSelect
	FROM @DisplayTable
WHERE SortByOrder IS NOT NULL
GROUP BY FieldSelect
ORDER BY MIN(SortByOrder), MIN(FieldDisplay)

SELECT @SortList=COALESCE(@SortList+',','') + FieldSelect
FROM @SortListTable

SELECT @ColumnHeaders AS ColumnHeaders, @FieldList AS FieldList, @SortList AS SortList

SELECT FieldName, FieldDisplay, CheckHTML
	FROM @DisplayTable
WHERE DisplayOrder IS NOT NULL
ORDER BY DisplayOrder

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExcelProfile_sf] TO [cioc_login_role]
GO
