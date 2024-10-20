SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_ParseVarCharIDPairList](
	@IdList varchar(MAX),
	@Separator varchar(10),
	@PairSeparator varchar(10) 
)
RETURNS @ParsedList table (
	[LeftItem] varchar(255) COLLATE Latin1_General_100_CI_AS NULL,
	[RightItem] varchar(255) COLLATE Latin1_General_100_CI_AS NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

INSERT INTO @ParsedList
(
	LeftItem,
	RightItem
)

SELECT
	MIN(CASE col WHEN '1' THEN ItemID ELSE NULL END) AS LeftItem,
	MIN(CASE col WHEN '2' THEN ItemID ELSE NULL END) AS RightItem
FROM (
	SELECT items.ItemID AS TotalItemID, ROW_NUMBER() OVER (PARTITION BY items.ItemID ORDER BY (SELECT 1)) AS col, pairs.ItemID 
	FROM dbo.fn_GBL_ParseVarCharIDList2(@IdList, @Separator) AS items
	CROSS APPLY dbo.fn_GBL_ParseVarCharIDList2(items.ItemID, @PairSeparator) AS pairs
) AS t
GROUP BY t.TotalItemID

RETURN

END


GO
