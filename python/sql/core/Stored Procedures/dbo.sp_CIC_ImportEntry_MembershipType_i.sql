SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_MembershipType_i]
	@NUM varchar(8),
	@MembershipTypeEn nvarchar(200),
	@MembershipTypeFr nvarchar(200),
	@MT_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @MT_ID = MT_ID
	FROM CIC_MembershipType_Name
WHERE [Name]=@MembershipTypeEn OR [Name]=@MembershipTypeFr
	ORDER BY CASE
		WHEN [Name]=@MembershipTypeEn AND LangID=0 THEN 0
		WHEN [Name]=@MembershipTypeFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @MT_ID IS NOT NULL BEGIN
	INSERT INTO CIC_BT_MT (
		NUM,
		MT_ID
	)
	SELECT	NUM,
			@MT_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_MT WHERE NUM=@NUM AND MT_ID=@MT_ID)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_MembershipType_i] TO [cioc_login_role]
GO
