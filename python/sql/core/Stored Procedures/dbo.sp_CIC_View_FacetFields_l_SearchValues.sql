SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_FacetFields_l_SearchValues]
	@ViewType INT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 25-Jul-2019
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	INT
SET @Error = 0

DECLARE @MemberID INT
SELECT @MemberID = MemberID FROM dbo.CIC_View WHERE ViewType=@ViewType

DECLARE @Field1 INT, @Field2 INT, @Field3 INT, @Field4 INT

SELECT @Field1=vw.RefineField1, @Field2=vw.RefineField2, @Field3=vw.RefineField3, @Field4=vw.RefineField4
	FROM dbo.CIC_View vw
	WHERE vw.ViewType=@ViewType

DECLARE @FieldListTable TABLE (
	RefineField TINYINT NOT NULL,
	FieldID INT NOT NULL,
	FieldName VARCHAR(100) NOT NULL,
	FieldDisplay NVARCHAR(255) NOT NULL,
	FieldType VARCHAR(3) NOT NULL,
	ExtraFieldType CHAR(1) NULL,
	CheckListSearch VARCHAR(28) NULL,
	PB_ID INT NULL
)

INSERT INTO @FieldListTable
SELECT DISTINCT 
		ROW_NUMBER() OVER (ORDER BY CASE
				WHEN fo.FieldID=@Field1 THEN 1
				WHEN fo.FieldID=@Field2 THEN 2
				WHEN fo.FieldID=@Field3 THEN 3
				WHEN fo.FieldID=@Field4 THEN 4
				END
				) AS RefineField,
		fo.FieldID,
		FieldName, 
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		FieldType,
		ExtraFieldType,
		ChecklistSearch,
		PB_ID
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE
	fo.FieldID IN (@Field1,@Field2,@Field3,@Field4)
	AND fo.FacetFieldList IS NOT NULL

SELECT * FROM @FieldListTable

DECLARE 
	@ReturnFieldCount TINYINT,
	@CurrentField TINYINT,
	@FieldID INT,
	@FieldName NVARCHAR(100),
	@FieldType VARCHAR(3),
	@ExtraFieldType VARCHAR(1),
	@CheckListSearch VARCHAR(28),
	@PB_ID INT

SELECT @ReturnFieldCount = MAX(RefineField) FROM @FieldListTable
SET @CurrentField = 1

WHILE @CurrentField <= @ReturnFieldCount BEGIN
	SELECT @FieldID = FieldID,
		@FieldName = FieldName, 
		@FieldType = FieldType,
		@ExtraFieldType = ExtraFieldType,
		@CheckListSearch = CheckListSearch,
		@PB_ID = PB_ID
	FROM @FieldListTable
	WHERE RefineField = @CurrentField

	IF @PB_ID IS NOT NULL BEGIN
		SELECT 
			@FieldID AS FieldID,
			gh.GH_ID AS Facet_ID,
			CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS Facet_Value
		FROM CIC_GeneralHeading gh
		LEFT JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		WHERE PB_ID = @PB_ID AND CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END IS NOT NULL
		ORDER BY gh.DisplayOrder, Facet_Value
	END ELSE IF @CheckListSearch LIKE 'exd%' BEGIN
		SELECT @FieldID AS FieldID,
			exdn.EXD_ID AS Facet_ID,
			exdn.Name AS Facet_Value
		FROM dbo.CIC_ExtraDropDown exd
		INNER JOIN dbo.CIC_ExtraDropDown_Name exdn ON exdn.EXD_ID = exd.EXD_ID AND exdn.LangID=@@LANGID
		WHERE exd.FieldName = @FieldName
		ORDER BY DisplayOrder, Facet_Value
	END ELSE IF @CheckListSearch LIKE 'exc%' BEGIN
		SELECT @FieldID AS FieldID,
			excn.EXC_ID AS Facet_ID,
			excn.Name AS Facet_Value
		FROM dbo.CIC_ExtraCheckList exc
		INNER JOIN dbo.CIC_ExtraCheckList_Name excn ON excn.EXC_ID = exc.EXC_ID AND excn.LangID=@@LANGID
		WHERE exc.FieldName = @FieldName
		ORDER BY exc.DisplayOrder, Facet_Value
	END ELSE IF @CheckListSearch = 'ln' BEGIN
		SELECT @FieldID AS FieldID,
			ln.LN_ID AS Facet_ID,
			lnn.Name AS Facet_Value
		FROM GBL_Language ln
		INNER JOIN GBL_Language_Name lnn
			ON ln.LN_ID=lnn.LN_ID
				AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE (ln.MemberID IS NULL OR @MemberID IS NULL OR ln.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM GBL_Language_InactiveByMember WHERE LN_ID=ln.LN_ID AND MemberID=@MemberID)
		ORDER BY ln.DisplayOrder, lnn.Name
	END ELSE IF @CheckListSearch LIKE 'ols' BEGIN
		SELECT @FieldID AS FieldID,
			ols.OLS_ID AS Facet_ID,
			ISNULL(olsn.Name,ols.Code) AS Facet_Value
		FROM dbo.GBL_OrgLocationService ols
		LEFT JOIN dbo.GBL_OrgLocationService_Name olsn ON olsn.OLS_ID = ols.OLS_ID AND olsn.LangID=@@LANGID
	END ELSE IF @CheckListSearch LIKE 'lcm' BEGIN
		SELECT
			@FieldID AS FieldID,
			STUFF((SELECT ',' + CAST(cst.CM_ID AS varchar) FROM dbo.fn_GBL_Community_Search_rst(cm.CM_ID) cst FOR XML PATH('')),1,1,'') AS Facet_ID,
			ISNULL(cmn.Display,cmn.Name) AS Facet_Value
			FROM CIC_View_Community cs
			INNER JOIN GBL_Community cm
				ON cs.CM_ID = cm.CM_ID
			INNER JOIN GBL_Community_Name cmn
				ON cm.CM_ID=cmn.CM_ID
					AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE ViewType = @ViewType
		ORDER BY cs.DisplayOrder, Facet_Value
	END ELSE IF @CheckListSearch = 'ft' BEGIN
		SELECT @FieldID AS FieldID,
			ft.FT_ID AS Facet_ID,
			ftn.Name AS Facet_Value
		FROM dbo.CIC_FeeType ft
		INNER JOIN dbo.CIC_FeeType_Name ftn
			ON ft.FT_ID=ftn.FT_ID
				AND ftn.LangID=@@LANGID
		WHERE (ft.MemberID IS NULL OR @MemberID IS NULL OR ft.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_FeeType_InactiveByMember WHERE FT_ID=ft.FT_ID AND MemberID=@MemberID)
		ORDER BY ft.DisplayOrder, ftn.Name
	END ELSE IF @CheckListSearch = 'ac' BEGIN
		SELECT @FieldID AS FieldID,
			ac.AC_ID AS Facet_ID,
			acn.Name AS Facet_Value
		FROM dbo.GBL_Accessibility ac
		INNER JOIN dbo.GBL_Accessibility_Name acn
			ON ac.AC_ID=acn.AC_ID
				AND acn.LangID=@@LANGID
		WHERE (ac.MemberID IS NULL OR @MemberID IS NULL OR ac.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM GBL_Accessibility_InactiveByMember WHERE AC_ID=ac.AC_ID AND MemberID=@MemberID)
		ORDER BY ac.DisplayOrder, acn.Name
	END
	SET @CurrentField = @CurrentField + 1
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_FacetFields_l_SearchValues] TO [cioc_cic_search_role]
GO
