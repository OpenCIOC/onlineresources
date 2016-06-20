CREATE TABLE [dbo].[CIC_View_FeedbackField]
(
[FeedbackFieldID] [int] NOT NULL IDENTITY(1, 1),
[FieldID] [int] NOT NULL,
[DisplayFieldGroupID] [int] NOT NULL,
[RT_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_FeedbackField] ADD CONSTRAINT [PK_CIC_View_FeedbackField] PRIMARY KEY CLUSTERED  ([FeedbackFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_FeedbackField_UniquePair] ON [dbo].[CIC_View_FeedbackField] ([FieldID], [DisplayFieldGroupID], [RT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_FeedbackField] ADD CONSTRAINT [FK_CIC_View_FeedbackField_CIC_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[CIC_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_FeedbackField] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_FeedbackField_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_FeedbackField] ADD CONSTRAINT [FK_CIC_View_FeedbackField_CIC_RecordType] FOREIGN KEY ([RT_ID]) REFERENCES [dbo].[CIC_RecordType] ([RT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
