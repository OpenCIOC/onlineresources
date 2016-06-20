CREATE TABLE [dbo].[CIC_GeneralHeading_TAX_TM]
(
[GH_TM_ID] [int] NOT NULL IDENTITY(1, 1),
[GH_TAX_ID] [int] NOT NULL,
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE TRIGGER [dbo].[tr_CIC_GeneralHeading_TAX_TM_d] ON [dbo].[CIC_GeneralHeading_TAX_TM]
FOR DELETE AS

SET NOCOUNT ON

DELETE ght
	FROM CIC_GeneralHeading_TAX ght
	WHERE EXISTS(SELECT * FROM Deleted d WHERE ght.GH_TAX_ID=d.GH_TAX_ID)
		AND NOT EXISTS(SELECT * FROM CIC_GeneralHeading_TAX_TM fr WHERE fr.GH_TAX_ID=ght.GH_TAX_ID)

SET NOCOUNT OFF




GO
EXEC sp_settriggerorder N'[dbo].[tr_CIC_GeneralHeading_TAX_TM_d]', 'last', 'delete', null
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[tr_CIC_GeneralHeading_TAX_TM_iud] ON [dbo].[CIC_GeneralHeading_TAX_TM]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

DECLARE @SQL nvarchar(max),
		@GHIDs nvarchar(max)

UPDATE gh
	SET TaxonomyWhereClause = dbo.fn_CIC_GHIDToWhereClause(gh.GH_ID)
	FROM CIC_GeneralHeading gh
	WHERE EXISTS(SELECT * FROM CIC_GeneralHeading_TAX ght
		WHERE (
				EXISTS(SELECT * FROM inserted i WHERE i.GH_TAX_ID=ght.GH_TAX_ID)
				OR EXISTS(SELECT * FROM deleted d WHERE d.GH_TAX_ID=ght.GH_TAX_ID)
			)
		AND gh.GH_ID=ght.GH_ID
		)

SET NOCOUNT OFF


GO

ALTER TABLE [dbo].[CIC_GeneralHeading_TAX_TM] ADD CONSTRAINT [PK_CIC_GeneralHeading_TAX_TM] PRIMARY KEY CLUSTERED  ([GH_TM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_TAX_TM] ADD CONSTRAINT [IX_CIC_GeneralHeading_TAX_TM_UniquePair] UNIQUE NONCLUSTERED  ([GH_TAX_ID], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_GeneralHeading_TAX_TM_Code] ON [dbo].[CIC_GeneralHeading_TAX_TM] ([Code]) INCLUDE ([GH_TAX_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_GeneralHeading_TAX_TM_GHTAXID] ON [dbo].[CIC_GeneralHeading_TAX_TM] ([GH_TAX_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_TAX_TM] WITH NOCHECK ADD CONSTRAINT [FK_CIC_GeneralHeading_TAX_TM_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_TAX_TM] WITH NOCHECK ADD CONSTRAINT [FK_CIC_GeneralHeading_TAX_TM_CIC_GeneralHeading_TAX] FOREIGN KEY ([GH_TAX_ID]) REFERENCES [dbo].[CIC_GeneralHeading_TAX] ([GH_TAX_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_TAX_TM] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_TAX_TM] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_GeneralHeading_TAX_TM] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_GeneralHeading_TAX_TM] TO [cioc_login_role]
GO
