CREATE TABLE [dbo].[CIC_BT_TAX]
(
[BT_TAX_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_TAX_NUMBTTAXID] ON [dbo].[CIC_BT_TAX] ([NUM], [BT_TAX_ID]) ON [PRIMARY]

GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BT_TAX_d] ON [dbo].[CIC_BT_TAX]
FOR DELETE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 10-May-2016
	Action: NO ACTION REQUIRED
*/

UPDATE cbtd
	SET SRCH_Taxonomy_U = 1
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN Deleted d 
		ON d.NUM=cbtd.NUM
	WHERE cbtd.SRCH_Taxonomy_U = 0

DECLARE @SQL nvarchar(max),
		@GHIDs nvarchar(max),
		@UpdateGUID uniqueidentifier

SET @UpdateGUID = NEWID()

UPDATE pr
	SET GHTaxCache_u = @UpdateGUID
FROM CIC_BT_PB pr
WHERE (
		EXISTS(SELECT * FROM inserted i WHERE pr.NUM=i.NUM)
		OR EXISTS(SELECT * FROM deleted d WHERE pr.NUM=d.NUM)
	)
	AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE pr.PB_ID=gh.PB_ID AND gh.Used IS NULL AND gh.TaxonomyWhereClause IS NOT NULL)

SELECT @GHIDs = COALESCE(@GHIDs + ',','') + CAST(gh.GH_ID AS varchar)
	FROM CIC_GeneralHeading gh
	WHERE EXISTS(SELECT * FROM CIC_BT_PB pb WHERE gh.PB_ID=pb.PB_ID AND pb.GHTaxCache_u=@UpdateGUID)
		AND gh.Used IS NULL AND gh.TaxonomyWhereClause IS NOT NULL

SELECT @SQL = STUFF((SELECT N' INSERT INTO @TmpGHID (GH_ID, BT_PB_ID, NUM_Cache) SELECT ' + CAST(gh.GH_ID AS varchar) + ' AS GH_ID, pb.BT_PB_ID, pb.NUM AS NUM_Cache FROM GBL_BaseTable bt INNER JOIN CIC_BT_PB pb ON bt.NUM=pb.NUM AND pb.PB_ID=' + CAST(gh.PB_ID AS varchar) + ' WHERE pb.GHTaxCache_u=@UpdateGUID AND (' + gh.TaxonomyWhereClause + ')'
	FROM CIC_GeneralHeading gh
	WHERE EXISTS(SELECT * FROM CIC_BT_PB pb WHERE gh.PB_ID=pb.PB_ID AND pb.GHTaxCache_u=@UpdateGUID)
		AND gh.Used IS NULL
	FOR XML PATH(N'')), 1, 1, N'')

IF @SQL IS NOT NULL AND @SQL <> '' BEGIN
	SET @SQL = '
	
	DECLARE @TmpGHID TABLE (
		GH_ID int NOT NULL,
		BT_PB_ID int NOT NULL,
		NUM_Cache varchar(8) NOT NULL
	)
	
	' + @SQL + '
	
	MERGE INTO CIC_BT_PB_GH dst
		USING @TmpGHID src
			ON dst.BT_PB_ID=src.BT_PB_ID AND dst.GH_ID=src.GH_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (BT_PB_ID, GH_ID, NUM_Cache)
				VALUES (src.BT_PB_ID, src.GH_ID, src.NUM_Cache)
		WHEN NOT MATCHED BY SOURCE AND dst.GH_ID IN (' + @GHIDs + ')
				AND EXISTS(SELECT * FROM CIC_BT_PB pb WHERE GHTaxCache_u=@UpdateGUID AND pb.BT_PB_ID=dst.BT_PB_ID) THEN
			DELETE
			;
	'
	
	EXEC sp_executesql @SQL, N'@UpdateGUID uniqueidentifier', @UpdateGUID=@UpdateGUID
	
END

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[CIC_BT_TAX] ADD CONSTRAINT [PK_CIC_BT_TAX] PRIMARY KEY CLUSTERED  ([BT_TAX_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_BT_TAX_INCNUM] ON [dbo].[CIC_BT_TAX] ([BT_TAX_ID]) INCLUDE ([NUM]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CIC_BT_TAX] ADD CONSTRAINT [FK_CIC_BT_TAX_CIC_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CIC_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_TAX] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_TAX] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_TAX] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_TAX] TO [cioc_login_role]
GO
