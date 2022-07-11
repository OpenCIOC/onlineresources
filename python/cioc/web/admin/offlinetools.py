# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from collections import namedtuple
from operator import itemgetter
import xml.etree.ElementTree as ET

from formencode import Schema, ForEach, variabledecode
from pyramid.view import view_config

from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

import logging

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/"

EditInfo = namedtuple("EditInfo", "security_levels security_level_map machines data")


class MachineSchema(Schema):
    if_key_missing = None

    MachineID = ciocvalidators.IDValidator(not_empty=True)
    SecurityLevels = ForEach(ciocvalidators.IDValidator(not_empty=True))


class OfflineToolSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    machine = ForEach(MachineSchema())


class OfflineTools(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_offlinetools",
        request_method="POST",
        renderer=templateprefix + "offlinetools.mak",
    )
    def post(self):
        request = self.request
        user = request.user

        if not user.cic.SuperUser or not request.dboptions.UseOfflineTools:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = OfflineToolSchema()
        model_state.form.variable_decode = True

        if model_state.validate():
            # success
            machines = model_state.value("machine")
            root = ET.Element("Data")

            for machine in machines:
                machine_id = str(machine["MachineID"])
                for sl in machine["SecurityLevels"]:
                    ET.SubElement(
                        root, "MachineSL", MachineID=machine_id, SL_ID=str(sl)
                    )

            args = [user.Agency, ET.tostring(root, encoding="unicode")]

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                    DECLARE @ErrMsg as nvarchar(500),
                    @RC as int

                    EXECUTE @RC = dbo.sp_CIC_Offline_Machines_u ?, ?, @ErrMsg=@ErrMsg OUTPUT

                    SELECT @RC as [Return], @ErrMsg AS ErrMsg
                """

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                msg = _("The Offline Machines were successfully updated.", request)

                self._go_to_route("admin_offlinetools", _query=[("InfoMsg", msg)])

        else:
            ErrMsg = _("There were validation errors.")

        edit_info = self._get_edit_info()._asdict()
        edit_info["ErrMsg"] = ErrMsg

        if not model_state.validate():
            edit_info.data = variabledecode.variable_decode(model_state.form.data)

        title = _("Manage Offline Machines", request)
        return self._create_response_namespace(title, title, edit_info, no_index=True)

    @view_config(
        route_name="admin_offlinetools", renderer=templateprefix + "offlinetools.mak"
    )
    def get(self):
        request = self.request
        user = request.user

        if not user.cic.SuperUser or not request.dboptions.UseOfflineTools:
            self._security_failure()

        edit_info = self._get_edit_info()

        request.model_state.form.data = variabledecode.variable_encode(edit_info.data)

        title = _("Manage Offline Machines", request)
        return self._create_response_namespace(
            title, title, edit_info._asdict(), no_index=True
        )

    def _get_edit_info(self, all=True):
        request = self.request
        user = request.user

        security_levels = []
        offline_machines = []
        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_CIC_Offline_Machines_l ?, ?, ?",
                request.dboptions.MemberID,
                user.Agency,
                all,
            )

            security_levels = cursor.fetchall()

            cursor.nextset()

            offline_machines = cursor.fetchall()

            cursor.close()

        data = []
        if all:
            for machine in offline_machines:
                machine.SecurityLevels = list(
                    map(int, self._list_from_xml(machine.SecurityLevels, "SL_ID"))
                )
                data.append(
                    {
                        "MachineID": machine.MachineID,
                        "SecurityLevels": machine.SecurityLevels,
                    }
                )

        sl_map = dict(map(itemgetter(0, 1), security_levels))

        # XXX fill out edit info
        return EditInfo(security_levels, sl_map, offline_machines, {"machine": data})
