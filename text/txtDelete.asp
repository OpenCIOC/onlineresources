<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%
Dim TXT_ARE_YOU_SURE, _
	TXT_CANNOT_DELETE_AGENCY_ORG, _
	TXT_CANNOT_DELETE_ORG_W_OPPS, _
	TXT_CANNOT_DELETE_PARENT_ORG, _
	TXT_CANNOT_DELETE_RECORDS_IN_USE, _
	TXT_CANNOT_DELETE_SHARED_RECORDS, _
	TXT_CANNOT_DELETE_SITE, _
	TXT_CANNOT_DELETE_VOL_MEMBER_ORG, _
	TXT_CANNOT_DELETE_VOL_W_REFERRAL, _
		TXT_CHANGE_DATE, _
	TXT_CHECK_ALL, _
	TXT_CONFIRM_DELETE, _
	TXT_CURRENT_PUBLIC, _
	TXT_DELETE_FRENCH_WARNING, _
	TXT_DELETE_INSTRUCTIONS, _
	TXT_DELETE_SELECTED, _
	TXT_DELETION_DATE, _
	TXT_INST_MAKE_NP, _
	TXT_LAST_REFERRAL, _
	TXT_MANAGE_DELETED, _
	TXT_MAKE_NON_PUBLIC, _
	TXT_MARK_DELETED, _
	TXT_MARKED_DELETED, _
	TXT_NO_DELETED, _
	TXT_ONLY_MARKED, _
	TXT_PERMANENT_DELETE, _
	TXT_RECORDS_HAVE_VOL, _
	TXT_REFERRALS, _
	TXT_RESTORE, _
	TXT_RESTORED, _
	TXT_SELECT_RECORD, _
	TXT_UNCHECK_ALL, _
	TXT_VIEW_BEFORE_DELETE, _
	TXT_WARNING_INVALID_DATE

Sub setTxtDelete()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ARE_YOU_SURE = "Are you sure you want to permanently delete the selected record(s)? All related information will also be deleted."
			TXT_CANNOT_DELETE_AGENCY_ORG = "Records associated with a Record Owner or User Agency."
			TXT_CANNOT_DELETE_ORG_W_OPPS = "Records with Volunteer Opportunities associated. The Opportunity must be permanently deleted."
			TXT_CANNOT_DELETE_PARENT_ORG = "Records in use as a Parent Agency."
			TXT_CANNOT_DELETE_RECORDS_IN_USE = "You cannot delete records that are in use by other items in the database, including" & TXT_COLON
			TXT_CANNOT_DELETE_SHARED_RECORDS = "Records shared with you by another CIOC Member in this database (does not include imported records)."
			TXT_CANNOT_DELETE_SITE = "Records in use as a Service Location (Site)."
			TXT_CANNOT_DELETE_VOL_MEMBER_ORG = "Records associated with a Volunteer Centre Membership."
			TXT_CANNOT_DELETE_VOL_W_REFERRAL = "Opportunities with Referrals associated. Use the Referral management page to delete old Referrals."
			TXT_CHANGE_DATE = "Change&nbsp;Date"
			TXT_CHECK_ALL = "Check All"
			TXT_CONFIRM_DELETE = "Confirm Permanent Record Deletion"
			TXT_CURRENT_PUBLIC = "Current &amp; Public"
			TXT_DELETE_FRENCH_WARNING = "You are about to permanently delete the <strong>French version</strong> of this record."
			TXT_DELETE_INSTRUCTIONS = "Set the date to mark the record deleted. If you leave the date blank or enter an invalid date, today's date is used." & _
				"<br>Records with deletion dates of today or in the past are <strong>deleted</strong>." & _
				"<br>Records with a deletion date in the future are <strong>scheduled for deletion</strong>."
			TXT_DELETE_SELECTED = "Permanently delete selected records"
			TXT_DELETION_DATE = "Deletion Date"
			TXT_INST_MAKE_NP = "Make this a non-public record (if not already non-public)"
			TXT_LAST_REFERRAL = "Last Referral"
			TXT_MANAGE_DELETED = "Manage Deleted Records"
			TXT_MAKE_NON_PUBLIC = "Make Non-Public"
			TXT_MARK_DELETED = "Mark Record(s) Deleted"
			TXT_MARKED_DELETED = "marked deleted"
			TXT_NO_DELETED = "There are no deleted records"
			TXT_ONLY_MARKED = "Note: Only records marked deleted can be permanently deleted."
			TXT_PERMANENT_DELETE = "Permanent&nbsp;Delete"
			TXT_RECORDS_HAVE_VOL = "The following records have volunteer opportunities. Please be courteous and contact the volunteer record owner(s)."
			TXT_REFERRALS = "Referrals"
			TXT_RESTORE = "Restore"
			TXT_RESTORED = " restored"
			TXT_SELECT_RECORD = "Select Record"
			TXT_UNCHECK_ALL = "Uncheck All"
			TXT_VIEW_BEFORE_DELETE = "You should view the contents of the record before you delete it."
			TXT_WARNING_INVALID_DATE = "The date you entered was invalid. " & _
				"Today's date will be entered into the record's deletion date; you can modify this date via the <a href=""" & _
				makeLinkB("delete_manage.asp") & """>Deleted Records</a> page."
		Case CULTURE_FRENCH_CANADIAN
			TXT_ARE_YOU_SURE = "Êtes-vous sûr de vouloir supprimer définitivement ce(s) dossier(s)? Toutes les informations reliées à ce dossier seront également supprimées."
			TXT_CANNOT_DELETE_AGENCY_ORG = "Dossiers associés avec un propriétaire du dossier ou une agence de l'utilisateur."
			TXT_CANNOT_DELETE_ORG_W_OPPS = "Les dossiers avec des occasions de bénévolat associées. Il faut d'abord supprimer les occasions de bénévolat."
			TXT_CANNOT_DELETE_PARENT_ORG = "TRANSLATE -- Records in use as a Parent Agency."
			TXT_CANNOT_DELETE_RECORDS_IN_USE = "Vous ne pouvez pas supprimer les dossiers qui sont en cours d'utilisation par d'autres applications dans la base de données, y compris" & TXT_COLON
			TXT_CANNOT_DELETE_SHARED_RECORDS = "Dossiers partagés avec vous par un autre membre CIOC dans cette base de données (ne comprend pas les dossiers importés)."
			TXT_CANNOT_DELETE_SITE = "TRANSLATE -- Records in use as a Service Location (Site)."
			TXT_CANNOT_DELETE_VOL_MEMBER_ORG = "Dossiers associés à un membre de type centre de bénévolat."
			TXT_CANNOT_DELETE_VOL_W_REFERRAL = "Les occasions avec des mises en relation associées. Utilisez la page de gestion des mises en relation pour supprimer les mises en relation anciennes."
			TXT_CHANGE_DATE = "Modifier la date"
			TXT_CHECK_ALL = "Sélectionner tout"
			TXT_CONFIRM_DELETE = "Confirmation de la suppression définitive du dossier"
			TXT_CURRENT_PUBLIC = "Dossier public actif"
			TXT_DELETE_FRENCH_WARNING = "La <strong>version française</strong> de ce dossier va être supprimée."
			TXT_DELETE_INSTRUCTIONS = "Saisir la date de suppression du dossier. Si aucune date n'est indiquée ou si la date utilisée n'est pas valide, la date d'aujourd'hui sera automatiquement utilisée." & _
				"<br>Les dossiers ayant comme date de suppression la date d'aujourd'hui ou une date dans le passé seront <strong>supprimés</strong>." & _
				"<br>Les dossiers ayant comme date de suppression une date dans le futur seront <strong>conservés pour suppression ultérieure</strong>."
			TXT_DELETION_DATE = "Date de suppression"
			TXT_DELETE_SELECTED = "Supprimer les dossiers sélectionnés définitivement"
			TXT_INST_MAKE_NP = "Rendre ce dossier non disponible au public (si ce n'est pas le cas)"
			TXT_LAST_REFERRAL = "Dernière mise en relation"
			TXT_MANAGE_DELETED = "Gestion des dossiers supprimés"
			TXT_MAKE_NON_PUBLIC = "Rendre non disponible au public"
			TXT_MARK_DELETED = "Marquage des dossiers supprimés"
			TXT_MARKED_DELETED = "marqué(s) supprimé(s)"
			TXT_NO_DELETED = "Il n'y a pas de dossiers supprimés."
			TXT_ONLY_MARKED = "Note : seul les dossiers marqué supprimé peuvent être supprimés en permanence."
			TXT_PERMANENT_DELETE = "Supprimer définitivement"
			TXT_RECORDS_HAVE_VOL = "Les dossiers suivants offrent des possibilités de bénévolat. Prière de communiquer directement avec le(s) propriétaire(s) desdits dossiers."
			TXT_REFERRALS = "Mises en relation"
			TXT_RESTORE = "Restaurer"
			TXT_RESTORED = "restauré(s)"
			TXT_SELECT_RECORD = "TR_FR -- Select Record"
			TXT_UNCHECK_ALL = "Déssélectionner tout"
			TXT_VIEW_BEFORE_DELETE = "Voir le contenu du dossier avant de le supprimer."
			TXT_WARNING_INVALID_DATE = "La date fournie n'est pas valide. " & _
				"La date d'aujourd'hui sera inscrite comme date de suppression du dossier; vous pouvez modifier cette date en allant à la page <a href=""" & _
				makeLinkB("delete_manage.asp") & """>des dossiers supprimés</a>."
	End Select
End Sub

Call setTxtDelete()
%>
