SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_STP_UsageCalculation]
	@MemberID int,
	@StartRange date,
	@EndRange date,
	@IncludeCIC bit,
	@IncludeVOL bit,
	@OnlyAgencyCodes varchar(500),
	@ExcludeAgencyCodes varchar(500)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 20-Mar-2016
	Action: NO ACTION REQUIRED
*/

IF EXISTS(SELECT * FROM dbo.CIC_Stats_RSN_Accumulator WHERE AccessDate < @EndRange) BEGIN
	EXEC sp_CIC_Stats_RSN_i_FromAccumulator
END


SELECT *
FROM dbo.fn_STP_UsageCalculation(@MemberID, @StartRange, @EndRange, @IncludeCIC, @IncludeVOL, @OnlyAgencyCodes,@ExcludeAgencyCodes)
ORDER BY Item, ItemDescription, MemberName, OwnerCode

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_STP_UsageCalculation] TO [cioc_login_role]
GO
