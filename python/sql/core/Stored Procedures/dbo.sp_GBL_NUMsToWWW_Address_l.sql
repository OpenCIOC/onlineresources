SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMsToWWW_Address_l]
	@MemberID int,
	@ViewType INT,
	@IdList varchar(max)
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

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT bt.NUM, btd.WWW_ADDRESS, btd.WWW_ADDRESS_PROTOCOL, CAST(CASE WHEN @MemberID IS NULL OR bt.MemberID=@MemberID THEN 1 ELSE 0 END AS BIT) AS CanEdit
FROM GBL_BaseTable bt
INNER JOIN GBL_BaseTable_Description btd
	ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
WHERE (EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@IdList, ';') n WHERE n.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI)) AND 
	(@MemberID IS NULL OR 
		(bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile pr
		INNER JOIN GBL_SharingProfile shp ON pr.ProfileID=shp.ProfileID AND shp.Active=1 AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType))
               WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID))
	)
ORDER BY bt.NUM
RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMsToWWW_Address_l] TO [cioc_login_role]
GO
