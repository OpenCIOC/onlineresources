CREATE TABLE [dbo].[CIC_iCarolImport]
(
[ResourceAgencyNum] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[service] [bit] NOT NULL,
[ImportDate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ImportStatus] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Refresh] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PublicName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AlternateName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OfficialName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyLevelName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ParentAgency] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ParentAgencyNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[RecordOwner] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UniqueIDPriorSystem] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingAttentionName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingAddress1] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingAddress2] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingCity] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingStateProvince] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingPostalCode] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingCountry] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MailingAddressIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalAddress1] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalAddress2] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalCity] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalCounty] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalStateProvince] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalPostalCode] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalCountry] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalAddressIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherAddress1] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherAddress2] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherCity] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherCounty] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherStateProvince] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherPostalCode] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OtherCountry] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Latitude] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Longitude] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[HoursOfOperation] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone1Number] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone1Name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone1Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone1IsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone1Type] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone2Number] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone2Name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone2Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone2IsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone2Type] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone3Number] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone3Name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone3Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone3IsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone3Type] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone4Number] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone4Name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone4Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone4IsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone4Type] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone5Number] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone5name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone5Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone5IsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Phone5Type] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneFax] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneFaxDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneFaxIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTTY] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTTYDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTTYIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTollFree] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTollFreeDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneTollFreeIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberHotline] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberHotlineDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberHotlineIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberBusinessLine] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberBusinessLineDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberBusinessLineIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberOutOfArea] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberOutOfAreaDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberOutOfAreaIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberAfterHours] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberAfterHoursDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhoneNumberAfterHoursIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EmailAddressMain] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[WebsiteAddress] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyStatus] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyClassification] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AgencyDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SearchHints] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CoverageArea] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CoverageAreaText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Eligibility] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityAdult] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityChild] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityFamily] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityFemale] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityMale] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EligibilityTeen] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SeniorWorkerName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SeniorWorkerTitle] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SeniorWorkerEmailAddress] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SeniorWorkerPhoneNumber] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SeniorWorkerIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactTitle] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactEmailAddress] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactPhoneNumber] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactType] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MainContactIsPrivate] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LicenseAccreditation] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[IRSStatus] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FEIN] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[YearIncorporated] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AnnualBudgetTotal] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LegalStatus] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SourceOfFunds] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ExcludeFromWebsite] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ExcludeFromDirectory] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DisabilitiesAccess] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PhysicalLocationDescription] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BusServiceAccess] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PublicAccessTransportation] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PaymentMethods] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FeeStructureSource] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ApplicationProcess] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ResourceInfo] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DocumentsRequired] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LanguagesOffered] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LanguagesOfferedList] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailabilityNumberOfTimes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailabilityFrequency] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailabilityPeriod] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ServiceNotAlwaysAvailability] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CapacityType] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ServiceCapacity] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NormalWaitTime] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TemporaryMessage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TemporaryMessageAppears] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TemporaryMessageExpires] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EnteredOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UpdatedOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MadeInactiveOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[InternalNotes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[InternalNotesForEditorsAndViewers] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[HighlightedResource] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerifiedOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerifiedByName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerifiedByTitle] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerifiedByPhoneNumber] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerifiedByEmailAddress] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LastVerificationApprovedBy] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailableForDirectory] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailableForReferral] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AvailableForResearch] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PreferredProvider] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToSiteNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToProgramNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LanguageOfRecord] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CurrentWorkflowStepCode] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerOpportunities] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerDuties] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[IsLinkOnly] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ProgramAgencyNamePublic] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SiteAgencyNamePublic] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Categories] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyTerm] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyTerms] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyTermsNotDeactivated] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyCodes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Coverage] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Hours] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_A1) Does your organization consent to participate in the] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Public Comments] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_A2) What is the likelihood that within the next 2-5 year] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S1) Does your organization own/rent/sublease the space] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S2) If your organization rents the space please state fr] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S3) What type of facilities do you have at the space (Ch] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S4) What is the approximate square footage of the space] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S5) In what type of building is the space located] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_S6) If your organization plans to move from the space in] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_211 Record] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Former Names] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Headings] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Legal Name] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Pub Codes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Record Owner (211 Central)] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Record Owner (controlled)] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_SINV] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_iCarol-managed record] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Facebook] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Instagram] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_LinkedIn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_Twitter] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Custom_YouTube] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SYNC_DATE] [smalldatetime] NULL,
[IMPORTED_DATE] [smalldatetime] NULL,
[RECORD_OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[InternalMemoGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CIC_iCarolImport_InternalMemoGUID] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_iCarolImport] ADD CONSTRAINT [PK_CIC_iCarolImport2] PRIMARY KEY CLUSTERED  ([ResourceAgencyNum], [LangID], [service]) ON [PRIMARY]
GO
