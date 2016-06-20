SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_LocationServices_u]
	@NUM varchar(8),
	@Codes xml,
	@BadNUMs varchar(max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 09-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @ServiceIDs TABLE (
	SERVICE_ID varchar(50) NOT NULL PRIMARY KEY
)

INSERT INTO @ServiceIDs
SELECT	N.value('@V', 'varchar(50)')
FROM @Codes.nodes('//SERVICE_NUM') as T(N)

MERGE INTO GBL_BT_LOCATION_SERVICE pr
USING (SELECT bt2.NUM AS LOCATION_NUM, bt1.NUM AS SERVICE_NUM
	FROM @ServiceIDs tm
	INNER JOIN GBL_BaseTable bt1
		ON bt1.NUM=(SELECT TOP 1 NUM FROM GBL_BaseTable bt WHERE bt.NUM<>@NUM AND (bt.NUM=tm.SERVICE_ID OR EXTERNAL_ID=tm.SERVICE_ID)
			ORDER BY CASE WHEN NUM=tm.SERVICE_ID THEN 0 ELSE 1 END, NUM)
	INNER JOIN GBL_BaseTable bt2
		ON bt2.NUM=@NUM) lspr
	ON pr.LOCATION_NUM=lspr.LOCATION_NUM AND pr.SERVICE_NUM=lspr.SERVICE_NUM
WHEN NOT MATCHED BY TARGET THEN
INSERT ( LOCATION_NUM, SERVICE_NUM )
	VALUES ( lspr.LOCATION_NUM, lspr.SERVICE_NUM )
WHEN NOT MATCHED BY SOURCE AND pr.LOCATION_NUM=@NUM THEN 
	DELETE
	;

SELECT @BadNUMs = COALESCE(@BadNUMs + ' ; ','') + bad.SERVICE_ID
	FROM (
		SELECT tm.SERVICE_ID FROM @ServiceIDs tm
			WHERE NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM<>@NUM AND (bt.NUM=tm.SERVICE_ID OR EXTERNAL_ID=tm.SERVICE_ID))
	) bad

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_LocationServices_u] TO [cioc_login_role]
GO
