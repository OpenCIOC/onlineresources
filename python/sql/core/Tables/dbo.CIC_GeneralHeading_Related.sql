CREATE TABLE [dbo].[CIC_GeneralHeading_Related]
(
[RLGH_ID] [int] NOT NULL IDENTITY(1, 1),
[GH_ID] [int] NOT NULL,
[RelatedGH_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Related] ADD CONSTRAINT [CK_CIC_GH_RelatedTerm] CHECK (([GH_ID]<>[RelatedGH_ID]))
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Related] ADD CONSTRAINT [PK_CIC_GH_RelatedTerm] PRIMARY KEY CLUSTERED  ([RLGH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Related] ADD CONSTRAINT [IX_CIC_GH_RelatedTerm_UniquePair] UNIQUE NONCLUSTERED  ([GH_ID], [RelatedGH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Related] ADD CONSTRAINT [FK_CIC_GeneralHeading_Related_CIC_GeneralHeading] FOREIGN KEY ([GH_ID]) REFERENCES [dbo].[CIC_GeneralHeading] ([GH_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Related] ADD CONSTRAINT [FK_CIC_GeneralHeading_Related_CIC_GeneralHeading_RelatedTo] FOREIGN KEY ([RelatedGH_ID]) REFERENCES [dbo].[CIC_GeneralHeading] ([GH_ID])
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Related] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Related] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_GeneralHeading_Related] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_GeneralHeading_Related] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_GeneralHeading_Related] TO [cioc_login_role]
GO
