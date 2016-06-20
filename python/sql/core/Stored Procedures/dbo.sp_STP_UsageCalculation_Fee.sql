SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_STP_UsageCalculation_Fee]
	@MemberID int,
	@StartRange date,
	@EndRange date,
	@IncludeCIC bit,
	@IncludeVOL bit,
	@OnlyAgencyCodes varchar(500),
	@ExcludeAgencyCodes varchar(500),
	@BaseFee decimal(7,2),
	@CostPerUser decimal(7,2),
	@CostPerBaseRecord decimal(7,2),
	@CostPerLangRecord decimal(7,2),
	@CostPerDeletedRecord decimal(7,2),
	@CostPerAccess decimal(7,5),
	@CostPerProfile decimal(7,2),
	@Discount decimal(3,2)
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

DECLARE @DaysInRange int,
		@ProratedAmount decimal(7,3),
		@QuarterForecastMultiplier decimal(7,3),
		@YearForecastMultiplier decimal(7,3)

IF @Discount IS NULL OR @Discount >= 1 OR @Discount <=0 BEGIN
	SET @Discount=1
END ELSE BEGIN
	SET @Discount = 1 - @Discount
END


IF @EndRange IS NULL SET @EndRange = GETDATE()
IF @StartRange IS NULL SET @StartRange = DATEADD(QUARTER,-1,GETDATE())
SET @DaysInRange = DATEDIFF(DAY,@StartRange,@EndRange)
SET @ProratedAmount = CAST(@DaysInRange AS float)/365
SET @QuarterForecastMultiplier = (1/CAST(@DaysInRange AS float))*91.3125
SET @YearForecastMultiplier = (1/CAST(@DaysInRange AS float))*365.25

SELECT @StartRange AS StartRange, @EndRange AS EndRange, @DaysInRange AS DaysInRange, @QuarterForecastMultiplier AS QuarterForcastMultiplier, @YearForecastMultiplier AS YearForecastMultiplier 

SELECT *,
	CAST(
	CASE
		WHEN Item = '1-BASE' THEN ItemCount * @BaseFee * @ProratedAmount * @Discount
		WHEN Item = '2-USER' THEN ItemCount * @CostPerUser * @ProratedAmount * @Discount
		WHEN Item = '3-RECORD' THEN ItemCount * @CostPerBaseRecord * @ProratedAmount * @Discount
		WHEN Item = '4-RECORDLANG' THEN ItemCount * @CostPerLangRecord * @ProratedAmount * @Discount
		WHEN Item = '5-RECORDDEL' THEN ItemCount * @CostPerDeletedRecord * @ProratedAmount * @Discount
		WHEN Item = '6-ACCESS' THEN ItemCount * @CostPerAccess * @Discount
		WHEN Item = '7-PROFILE' THEN ItemCount * @CostPerProfile * @ProratedAmount * @Discount
	ELSE 0
	END AS money) AS FeeForPeriod,
	CAST(
	CASE
		WHEN Item = '1-BASE' THEN ItemCount * @BaseFee * 0.25 * @Discount
		WHEN Item = '2-USER' THEN ItemCount * @CostPerUser * 0.25 * @Discount
		WHEN Item = '3-RECORD' THEN ItemCount * @CostPerBaseRecord * 0.25 * @Discount
		WHEN Item = '4-RECORDLANG' THEN ItemCount * @CostPerLangRecord * 0.25 * @Discount
		WHEN Item = '5-RECORDDEL' THEN ItemCount * @CostPerDeletedRecord * 0.25 * @Discount
		WHEN Item = '6-ACCESS' THEN ItemCount * @CostPerAccess * @QuarterForecastMultiplier * @Discount
		WHEN Item = '7-PROFILE' THEN ItemCount * @CostPerProfile * 0.25 * @Discount
	ELSE 0
	END AS money) AS QuarterlyEstimate,
	CAST(
	CASE
		WHEN Item = '1-BASE' THEN ItemCount * @BaseFee * @Discount
		WHEN Item = '2-USER' THEN ItemCount * @CostPerUser * @Discount
		WHEN Item = '3-RECORD' THEN ItemCount * @CostPerBaseRecord * @Discount
		WHEN Item = '4-RECORDLANG' THEN ItemCount * @CostPerLangRecord * @Discount
		WHEN Item = '5-RECORDDEL' THEN ItemCount * @CostPerDeletedRecord * @Discount
		WHEN Item = '6-ACCESS' THEN ItemCount * @CostPerAccess * @YearForecastMultiplier  * @Discount
		WHEN Item = '7-PROFILE' THEN ItemCount * @CostPerProfile * @Discount
	ELSE 0
	END AS money) AS YearlyEstimate
FROM dbo.fn_STP_UsageCalculation(@MemberID, @StartRange, @EndRange, @IncludeCIC, @IncludeVOL, @OnlyAgencyCodes,@ExcludeAgencyCodes)
WHERE CAST(
	CASE
		WHEN Item = '1-BASE' THEN ItemCount * @BaseFee * @ProratedAmount * @Discount
		WHEN Item = '2-USER' THEN ItemCount * @CostPerUser * @ProratedAmount * @Discount
		WHEN Item = '3-RECORD' THEN ItemCount * @CostPerBaseRecord * @ProratedAmount * @Discount
		WHEN Item = '4-RECORDLANG' THEN ItemCount * @CostPerLangRecord * @ProratedAmount * @Discount
		WHEN Item = '5-RECORDDEL' THEN ItemCount * @CostPerDeletedRecord * @ProratedAmount * @Discount
		WHEN Item = '6-ACCESS' THEN ItemCount * @CostPerAccess * @Discount
		WHEN Item = '7-PROFILE' THEN ItemCount * @CostPerProfile * @ProratedAmount * @Discount
	ELSE 0
	END AS money) > 0
ORDER BY Item, ItemDescription, MemberName, OwnerCode

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_STP_UsageCalculation_Fee] TO [cioc_login_role]
GO
