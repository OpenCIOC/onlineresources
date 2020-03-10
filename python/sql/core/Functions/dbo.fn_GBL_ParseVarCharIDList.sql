SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_ParseVarCharIDList](
	@IdList varchar(MAX),
	@Separator char(1)
)
RETURNS @ParsedList table (
	[ItemID] varchar(255) COLLATE Latin1_General_CI_AS NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 02-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @xmlData xml
IF @IdList = '' BEGIN
	RETURN
END

SET @xmlData = '<r><n>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@IdList, @Separator, CHAR(3)), '&', '&amp;'), '>', '&gt;'), '<', '&lt;'), CHAR(3), '</n><n>') + '</n></r>'

INSERT INTO @ParsedList
		(ItemID)
SELECT LTRIM(RTRIM(N.value('.', 'varchar(255)')))
FROM  @xmlData.nodes('/r/n') AS T(N)
WHERE LTRIM(RTRIM(N.value('.', 'varchar(255)'))) <> ''

RETURN

END


GO



GRANT SELECT ON  [dbo].[fn_GBL_ParseVarCharIDList] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_GBL_ParseVarCharIDList] TO [cioc_login_role]
GO
