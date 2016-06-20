
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy_UnitType_rst](
	@NUM varchar(8)
)
RETURNS @UnitType TABLE (
	[UnitName] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[ServiceTitle] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[TargetPopulations] nvarchar(max) COLLATE Latin1_General_100_CI_AI NULL,
	[Capacity] smallint,
	[FundedCapacity] smallint NULL,
	[Vacancy] smallint NULL,
	[HoursPerDay] [decimal](6, 1) NULL,
	[DaysPerWeek] [decimal](6, 1) NULL,
	[WeeksPerYear] [decimal](6, 1) NULL,
	[FullTimeEquivalent] [decimal](6, 1) NULL,
	[WaitList] bit NULL,
	[WaitListDate] smalldatetime NULL,
	[Notes] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL,
	[MODIFIED_DATE] smalldatetime NULL,
	[BT_VUT_ID] int
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @UnitType
SELECT	ISNULL(vutn.Name,cioc_shared.dbo.fn_SHR_STP_ObjectName('units')),
		ISNULL(prn.ServiceTitle,cioc_shared.dbo.fn_SHR_STP_ObjectName('#') + CAST(ROW_NUMBER() OVER(ORDER BY prn.ServiceTitle, vut.DisplayOrder, vutn.Name, pr.MODIFIED_DATE) AS varchar)),
		dbo.fn_CIC_NumToVacancy_TargetPop(pr.BT_VUT_ID),
		Capacity,
		FundedCapacity,
		Vacancy,
		HoursPerDay,
		DaysPerWeek,
		WeeksPerYear,
		FullTimeEquivalent,
		WaitList,
		WaitListDate,
		prn.Notes,
		pr.MODIFIED_DATE,
		pr.BT_VUT_ID
	FROM CIC_BT_VUT pr
	LEFT JOIN CIC_BT_VUT_Notes prn
		ON pr.BT_VUT_ID=prn.BT_VUT_ID
			AND prn.LangID=@@LANGID
	INNER JOIN CIC_Vacancy_UnitType vut
		ON pr.VUT_ID=vut.VUT_ID
	LEFT JOIN CIC_Vacancy_UnitType_Name vutn
		ON vut.VUT_ID=vutn.VUT_ID
			AND vutn.LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_UnitType_Name WHERE VUT_ID=vut.VUT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE NUM = @NUM
ORDER BY prn.ServiceTitle, vut.DisplayOrder, vutn.Name, pr.MODIFIED_DATE

RETURN

END
GO
