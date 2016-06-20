
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_l_Refresh]
	@MemberID [int],
	@ViewType [int],
	@BT_VUT_ID_List varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @FieldID int, 
	 @SharingProfileIDList varchar(MAX),
	 @SQL nvarchar(MAX),
	 @Today smalldatetime

SELECT @FieldID=FieldID FROM GBL_FieldOption WHERE FieldName = 'VACANCY_INFO'

IF EXISTS(SELECT * FROM CIC_View_DisplayField df INNER JOIN CIC_View_DisplayFieldGroup fg ON fg.DisplayFieldGroupID = df.DisplayFieldGroupID WHERE fg.ViewType=@ViewType AND df.FieldID=@FieldID) BEGIN
	SET @SharingProfileIDList = dbo.fn_GBL_SharingProfile_CIC_Fld_l(@MemberID,@ViewType,@FieldID)
	SET @Today = GETDATE()

	SET @SQL = N'SELECT
	 CASE
		WHEN Vacancy IS NULL THEN '' '' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''Vacancy is unknown'')
		WHEN Vacancy=0 THEN '' '' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''No vacancy'')
		ELSE '' '' + CAST(Vacancy AS varchar) + '' '' + vutn.Name + '' '' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''are available'')
	END
	+ CASE 
		WHEN pr.MODIFIED_DATE IS NOT NULL THEN '' ('' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''as of'') + '' '' + cioc_shared.dbo.fn_SHR_GBL_DateString(pr.MODIFIED_DATE) + '')''
		ELSE ''''
	END AS [Text],
	BT_VUT_ID
	FROM CIC_BT_VUT pr
	INNER JOIN CIC_Vacancy_UnitType vut
		ON pr.VUT_ID=vut.VUT_ID
	LEFT JOIN CIC_Vacancy_UnitType_Name vutn
		ON vut.VUT_ID=vutn.VUT_ID
			AND vutn.LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_UnitType_Name WHERE VUT_ID=vut.VUT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@BT_VUT_ID_List, '','') idlist
		ON pr.BT_VUT_ID=idlist.ItemID
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=pr.NUM
	WHERE dbo.fn_CIC_RecordInView(bt.NUM, @ViewType, @@LANGID, 0, @Today)=1 AND (bt.MemberID=@MemberID' + CASE WHEN @SharingProfileIDList IS NULL THEN ')' ELSE ' OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ProfileID IN (' + @SharingProfileIDList + ')))' END

	EXEC sp_executesql @SQL, N'@BT_VUT_ID_List varchar(max), @MemberID int, @ViewType int, @Today smalldatetime', @BT_VUT_ID_List=@BT_VUT_ID_list, @MemberID=@MemberID, @ViewType=@ViewType, @Today=@Today


END ELSE BEGIN

	SELECT '' AS Text, 0 AS [Count], 0 AS BT_VUT_ID
	WHERE 0=1

END

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_l_Refresh] TO [cioc_login_role]
GO
