CREATE TABLE [dbo].[VOL_View_FeedbackField]
(
[FeedbackFieldID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[FieldID] [int] NOT NULL,
[DisplayFieldGroupID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_FeedbackField] ADD CONSTRAINT [PK_VOL_View_FeedbackField] PRIMARY KEY CLUSTERED ([FeedbackFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_FeedbackField] ADD CONSTRAINT [IX_VOL_View_FeedbackField_UniquePair] UNIQUE NONCLUSTERED ([ViewType], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_FeedbackField] ADD CONSTRAINT [FK_VOL_View_FeedbackField_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_FeedbackField] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_FeedbackField_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
ALTER TABLE [dbo].[VOL_View_FeedbackField] ADD CONSTRAINT [FK_VOL_View_FeedbackField_VOL_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[VOL_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
