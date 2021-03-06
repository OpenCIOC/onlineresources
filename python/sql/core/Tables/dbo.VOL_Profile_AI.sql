CREATE TABLE [dbo].[VOL_Profile_AI]
(
[Profile_AI_ID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [uniqueidentifier] NOT NULL,
[AI_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Profile_AI] ADD CONSTRAINT [PK_VOL_Profile_AI] PRIMARY KEY CLUSTERED  ([Profile_AI_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Profile_AI_UniquePair] ON [dbo].[VOL_Profile_AI] ([ProfileID], [AI_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Profile_AI] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Profile_AI_VOL_Interest] FOREIGN KEY ([AI_ID]) REFERENCES [dbo].[VOL_Interest] ([AI_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Profile_AI] ADD CONSTRAINT [FK_VOL_Profile_AI_VOL_Profile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[VOL_Profile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Profile_AI] TO [cioc_login_role]
GO
