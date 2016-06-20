CREATE TABLE [dbo].[CIC_GeneralHeading_TAX]
(
[GH_TAX_ID] [int] NOT NULL IDENTITY(1, 1),
[GH_ID] [int] NOT NULL,
[MatchAny] [bit] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[tr_CIC_GeneralHeading_TAX_d] ON [dbo].[CIC_GeneralHeading_TAX]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

DECLARE @SQL nvarchar(max),
		@GHIDs nvarchar(max)

UPDATE gh
	SET TaxonomyWhereClause = dbo.fn_CIC_GHIDToWhereClause(gh.GH_ID)
	FROM CIC_GeneralHeading gh
	WHERE EXISTS(SELECT * FROM deleted d WHERE d.GH_ID=gh.GH_ID)

SET NOCOUNT OFF


GO
ALTER TABLE [dbo].[CIC_GeneralHeading_TAX] ADD CONSTRAINT [PK_CIC_GeneralHeading_TAX] PRIMARY KEY CLUSTERED  ([GH_TAX_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_TAX] ADD CONSTRAINT [FK_CIC_GeneralHeading_TAX_CIC_GeneralHeading] FOREIGN KEY ([GH_ID]) REFERENCES [dbo].[CIC_GeneralHeading] ([GH_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
