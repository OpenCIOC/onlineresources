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
Dim	TXT_ADD_REMOVE_OPPS, _
	TXT_AREAS_SERVED, _
	TXT_BALL, _
	TXT_COMMUNITIES_IN, _
	TXT_COMMUNITIES_OUT, _
	TXT_COMMUNITY, _
	TXT_COMMUNITY_GROUP, _
	TXT_COMMUNITY_SET, _
	TXT_COMMUNITY_SETS, _
	TXT_EDIT, _
	TXT_EDIT_VOLUNTEER_COMMUNITIES, _
	TXT_EDIT_VOLUNTEER_COMMUNITY_GROUPS, _
	TXT_EDIT_VOLUNTEER_COMMUNITY_SETS, _
	TXT_ERROR_NO_GROUP_SELECTED, _
	TXT_ERROR_NO_SET_SELECTED, _
	TXT_FIND_OPPS_TO, _
	TXT_GROUP, _
	TXT_IMG_URL, _
	TXT_INST_ADD, _
	TXT_INST_DELETE, _
	TXT_INST_CG_ADD, _
	TXT_INST_CG_DELETE, _
	TXT_INST_COM_ADD, _
	TXT_INST_SEARCH_OPPS, _
	TXT_INVALID_CS, _
	TXT_NO_OPPS_SELECTED, _
	TXT_NOTE, _
	TXT_OPPORTUNITIES, _
	TXT_RETURN_TO_VC, _
	TXT_RETURN_TO_OPP_CS_MGMT, _
	TXT_SET_NAME, _
	TXT_SHOW_OPPS_DELETED, _
	TXT_SHOW_OPPS_EXPIRED, _
	TXT_SHOW_OPPS_IN_SET, _
	TXT_SHOW_OPPS_NEED_IN_COMMS, _
	TXT_VOL_OP_CS_MANAGMENT, _
	TXT_VOLUNTEER_COMMUNITIES, _
	TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS, _
	TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS_FOR, _
	TXT_VOLUNTEER_COMMUNITY_GROUPS, _
	TXT_VOLUNTEER_COMMUNITY_GROUPINGS, _
	TXT_VOLUNTEER_COMMUNITY_SETS, _
	TXT_WARN_ORPHANED_DELETED, _
	TXT_WARN_ORPHANED_RECORDS

Sub setTxtVOLProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_REMOVE_OPPS = "Ajouter/Supprimer des occasions d'un ensemble de communautés"
			TXT_AREAS_SERVED = "Région desservie"
			TXT_BALL = "Bouton"
			TXT_COMMUNITIES_IN = "Occasions comprises"
			TXT_COMMUNITIES_OUT = "Occasions non comprises"
			TXT_COMMUNITY = "Communauté"
			TXT_COMMUNITY_GROUP = "Groupe de communautés"
			TXT_COMMUNITY_SET = "Ensemble de communautés"
			TXT_COMMUNITY_SETS = "Ensembles de communautés"
			TXT_EDIT = "Modifier"
			TXT_EDIT_VOLUNTEER_COMMUNITIES = "Modifier les communautés de bénévolat"
			TXT_EDIT_VOLUNTEER_COMMUNITY_GROUPS = "Modifier les groupes de communautés de bénévolat"
			TXT_EDIT_VOLUNTEER_COMMUNITY_SETS = "Modifier les ensembles de communautés de bénévolat"
			TXT_ERROR_NO_GROUP_SELECTED = "Aucun groupe de communautés n'a été sélectionné."
			TXT_ERROR_NO_SET_SELECTED = "Aucun ensemble de communautés n'a été sélectionné."
			TXT_FIND_OPPS_TO = "5. Trouver des occasions pour :"
			TXT_GROUP = "Groupe"
			TXT_IMG_URL = "URL de l'image"
			TXT_INST_ADD = "Utiliser la boîte ci-dessous pour ajouter un nouvel ensemble de communautés."
			TXT_INST_DELETE = "Un ensemble de communauté ne peut être supprimé que s'il n'est pas utilisé dans une vue ou une occasion."
			TXT_INST_CG_ADD = "Utiliser la boîte ci-dessous pour ajouter un nouveau groupe de communautés."
			TXT_INST_CG_DELETE = "Un groupe de communautés ne peut être supprimé que s'il n'a pas de "
			TXT_INST_COM_ADD = "Utiliser la boîte ci-dessous pour ajouter une nouvelle communauté."
			TXT_INST_SEARCH_OPPS = "Utiliser le formulaire ci-dessous pour générer une liste d'occasions ; vous pourrez ensuite sélectionner des occasions individuelles à ajouter à, ou à supprimer de l'ensemble."
			TXT_INVALID_CS = "L'ID de l'ensemble de communautés est invalide."
			TXT_NO_OPPS_SELECTED = "Aucune occasion n'a été sélectionnée"
			TXT_NOTE = "Note"
			TXT_OPPORTUNITIES = "Occasions"
			TXT_RETURN_TO_VC = "Revenir aux communautés de bénévolat"
			TXT_RETURN_TO_OPP_CS_MGMT = "Revenir à la gestion des ensembles de communautés des occasions de bénévolat"
			TXT_SET_NAME = "Établir le nom"
			TXT_SHOW_OPPS_DELETED = "Afficher les occasions supprimées"
			TXT_SHOW_OPPS_EXPIRED = "Afficher les occasions périmées"
			TXT_SHOW_OPPS_IN_SET = "1. Afficher les occasions dans l'ensemble :"
			TXT_SHOW_OPPS_NEED_IN_COMMS = "2. Afficher les occasions pour des personnes dans une ou plusieurs des communautés suivantes"
			TXT_VOL_OP_CS_MANAGMENT = "Gestion des ensembles de communautés des occasions de bénévolat"
			TXT_VOLUNTEER_COMMUNITIES = "Communautés de bénévolat"
			TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS = "membre dans le groupe de communautés de bénévolat"
			TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS_FOR = "Membres du groupe de communautés de bénévolat dans :"
			TXT_VOLUNTEER_COMMUNITY_GROUPS = "Groupes de communautés de bénévolat"
			TXT_VOLUNTEER_COMMUNITY_GROUPINGS = "Groupes de communautés de bénévolat dans :"
			TXT_VOLUNTEER_COMMUNITY_SETS = "Ensembles de communautés de bénévolat"
			TXT_WARN_ORPHANED_DELETED = "de ce(s) dossier(s) sont des dossiers supprimés ou expirés."
			TXT_WARN_ORPHANED_RECORDS = "Attention : Il y a [COUNT] dossiers dans votre base de données qui n'appartienne à aucun ensemble de communautés !"
		Case Else
			TXT_ADD_REMOVE_OPPS = "Add/Remove Opportunities from Community Set"
			TXT_AREAS_SERVED = "Area Served"
			TXT_BALL = "Ball"
			TXT_COMMUNITIES_IN = "Opportunities In"
			TXT_COMMUNITIES_OUT = "Opportunities Out"
			TXT_COMMUNITY = "Community"
			TXT_COMMUNITY_GROUP = "Community Group"
			TXT_COMMUNITY_SET = "Community Set"
			TXT_COMMUNITY_SETS = "Community Sets"
			TXT_EDIT = "Edit"
			TXT_EDIT_VOLUNTEER_COMMUNITIES = "Edit Volunteer Communities"
			TXT_EDIT_VOLUNTEER_COMMUNITY_GROUPS = "Edit Volunteer Community Groups"
			TXT_EDIT_VOLUNTEER_COMMUNITY_SETS = "Edit Volunteer Community Sets"
			TXT_ERROR_NO_GROUP_SELECTED = "No Community Group selected."
			TXT_ERROR_NO_SET_SELECTED = "No Community Set selected."
			TXT_FIND_OPPS_TO = "5. Find Opportunities to:"
			TXT_GROUP = "Group"
			TXT_IMG_URL = "Image URL"
			TXT_INST_ADD = "Use the box below to add a new community set."
			TXT_INST_DELETE = "You can only delete a Community Set if it is not being used by a View or Opportunity."
			TXT_INST_CG_ADD = "Use the box below to add a new Community Group."
			TXT_INST_CG_DELETE = "You can only delete a Community Group if it does not have any "
			TXT_INST_COM_ADD = "Use the box below to add a new community."
			TXT_INST_SEARCH_OPPS = "Use the form below to generate a list of opportunities; you will then be able to select individual opportunities to add to or remove from the Set."
			TXT_INVALID_CS = "The Community Set ID is not valid."
			TXT_NO_OPPS_SELECTED = "No Opportunities Selected"
			TXT_NOTE = "Note"
			TXT_OPPORTUNITIES = "Opportunities"
			TXT_RETURN_TO_VC = "Return to Volunteer Communities"
			TXT_RETURN_TO_OPP_CS_MGMT = "Return to Volunteer Opportunity Community Set Management"
			TXT_SET_NAME = "Set Name"
			TXT_SHOW_OPPS_DELETED = "Show deleted Opportunities"
			TXT_SHOW_OPPS_EXPIRED = "Show expired Opportunities"
			TXT_SHOW_OPPS_IN_SET = "1. Show Opportunities is in the Set: "
			TXT_SHOW_OPPS_NEED_IN_COMMS = "2. Show Opportunities needing individuals in one or more of the following communities "
			TXT_VOL_OP_CS_MANAGMENT = "Volunteer Opportunity Community Set Management"
			TXT_VOLUNTEER_COMMUNITIES = "Volunteer Communities"
			TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS = "Volunteer Community Group Members"
			TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS_FOR = "Volunteer Community Group Members for:"
			TXT_VOLUNTEER_COMMUNITY_GROUPS = "Volunteer Community Groups"
			TXT_VOLUNTEER_COMMUNITY_GROUPINGS = "Volunteer Community Groupings for:"
			TXT_VOLUNTEER_COMMUNITY_SETS = "Volunteer Community Sets"
			TXT_WARN_ORPHANED_DELETED = "of these are deleted or expired records."
			TXT_WARN_ORPHANED_RECORDS = "Warning: There are [COUNT]  records in your database that do not belong to any Community Set!"
	End Select
End Sub

Call setTxtVOLProfile()
%>
