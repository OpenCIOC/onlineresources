CREATE TABLE [dbo].[VOL_OP_SharingProfile]
(
[OP_ShareProfile_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ProfileID] [int] NOT NULL,
[ShareMemberID_Cache] [int] NOT NULL,
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_VOL_OP_SharingProfile_CREATED_DATE] DEFAULT (getdate())
) ON [PRIMARY]
ALTER TABLE [dbo].[VOL_OP_SharingProfile] ADD 
CONSTRAINT [PK_VOL_OP_SharingProfile] PRIMARY KEY CLUSTERED  ([OP_ShareProfile_ID]) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_OP_SharingProfile_VNUMShareMemberIDInclProfileID] ON [dbo].[VOL_OP_SharingProfile] ([VNUM], [ShareMemberID_Cache]) INCLUDE ([ProfileID]) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_OP_SharingProfile] ADD
CONSTRAINT [CK_VOL_OP_SharingProfile_Ownership] CHECK (([dbo].[fn_VOL_VNUMToMemberID]([VNUM])=[dbo].[fn_GBL_SharingProfileToMemberID]([ProfileID])))
GO

ALTER TABLE [dbo].[VOL_OP_SharingProfile] ADD CONSTRAINT [FK_VOL_OP_SharingProfile_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_SharingProfile] ADD CONSTRAINT [FK_VOL_OP_SharingProfile_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_SharingProfile] ADD CONSTRAINT [FK_VOL_OP_SharingProfile_STP_Member] FOREIGN KEY ([ShareMemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_OP_SharingProfile] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[VOL_OP_SharingProfile] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_SharingProfile] TO [cioc_vol_search_role]
GO
