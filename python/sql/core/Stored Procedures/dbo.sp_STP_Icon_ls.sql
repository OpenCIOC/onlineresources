SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_STP_Icon_ls] (
	@LimitType varchar(25),
	@Contains varchar(40)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 28-Apr-2016
	Action: NO ACTION REQUIRED
*/

SELECT *
	FROM dbo.STP_Icon
WHERE (@LimitType IS NULL OR Type=@LimitType)
	AND (@Contains IS NULL OR IconName LIKE '%' + @Contains + '%')
ORDER BY CASE WHEN IconName LIKE @Contains + '%' THEN 0 ELSE 1 END, Type, IconName

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_STP_Icon_ls] TO [cioc_login_role]
GO
