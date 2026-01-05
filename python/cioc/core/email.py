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

# stdlib
import os
import textwrap
from threading import Thread
from email.utils import parseaddr, formataddr

# 3rd party
from markupsafe import Markup, escape_silent
from marrow.mailer import Mailer, Message
from marrow.mailer.exc import DeliveryException
from concurrent.futures import ThreadPoolExecutor
from marrow.mailer.manager.dynamic import DynamicManager, ScalingPoolExecutor

# this app
from cioc.core.i18n import gettext as _
from cioc.core import constants as const


class ScalingPoolExecutorHotFix(ScalingPoolExecutor):
    def __init__(self, workers, divisor, timeout):
        super().__init__(workers, divisor, timeout)
        ThreadPoolExecutor.__init__(self)


class DynamicManagerHotFix(DynamicManager):
    Executor = ScalingPoolExecutorHotFix


DeliveryException


_mailer = None
_last_change = None


def stop_mailer(mailer):
    """stopping mailer can take a long time. Don't block request thread"""

    def do_stop():
        mailer.stop()

    t = Thread(target=do_stop)
    t.start()


def _get_mailer(request):
    global _mailer, _last_change

    if _mailer:
        if _last_change != request.config["_last_change"]:
            mailer = _mailer
            _mailer = None
            stop_mailer(mailer)

    if not _mailer:
        transport = {
            "use": "smtp",
            "host": os.environ.get("CIOC_MAIL_HOST", "127.0.0.1"),
            "username": os.environ.get("CIOC_MAIL_USERNAME"),
            "password": os.environ.get("CIOC_MAIL_PASSWORD"),
            "port": os.environ.get("CIOC_MAIL_PORT"),
            "tls": "ssl" if os.environ.get("CIOC_MAIL_USE_SSL") else False,
        }
        # print transport['host']
        transport = {k: v for k, v in transport.items() if v is not None}

        manager = request.config.get("mailer.manager", "immediate")
        if manager == "dynamic":
            manager = DynamicManagerHotFix

        _mailer = Mailer({"transport": transport, "manager": {"use": manager}})
        _mailer.start()

    return _mailer


def send_email(
    request, author, to, subject, message, ignore_block=False, domain_override=None
):

    if not isinstance(to, (list, tuple, set)):
        to = [x.strip() for x in to.split(",")]

    to = [formataddr(parseaddr(str(x), strict=False)) for x in to if x]
    dboptions = request.dboptions
    TrainingMode = dboptions.TrainingMode
    NoEmail = dboptions.NoEmail
    domain = domain_override or request.pageinfo.DbArea
    if domain == const.DM_VOL:
        from_email = dboptions.DefaultEmailVOL or dboptions.DefaultEmailCIC
        from_name = dboptions.DefaultEmailNameVOL or dboptions.DefaultEmailNameCIC or ""
    else:
        from_email = dboptions.DefaultEmailCIC or dboptions.DefaultEmailVOL
        from_name = dboptions.DefaultEmailNameCIC or dboptions.DefaultEmailNameVOL or ""

    if from_email:
        reply = formataddr(parseaddr(author, strict=False))
        author = parseaddr(author, strict=False)
        author = formataddr((author[0] or from_name, from_email))
    else:
        reply = None

    if TrainingMode:
        # XXX Fill message
        request.email_notice(
            Markup(
                """
                <p>Sending Email...<br><br>
                <strong>From:</strong> %s<br><br>
                <strong>To:</strong> %s<br><br>
                <strong>Reply-To:</strong> %s<br><br>
                <strong>Subject:</strong> %s<br><br>
                <strong>Message:</strong><br>%s</p>"""
            )
            % (
                author,
                ", ".join(to),
                reply or "",
                subject,
                escape_silent(message).replace("\n", Markup("<br>")).replace("\r", ""),
            )
        )

    elif not ignore_block and NoEmail:
        # XXX Fill message
        request.email_notice(
            _("This database has been configured to block all outgoing Email.", request)
        )

    if (
        (not TrainingMode or ignore_block)
        and (not NoEmail or ignore_block)
        and to
        and author
    ):
        mailer = _get_mailer(request)
        args = dict(author=[str(author)], to=to, subject=subject, plain=message)
        if reply:
            args["reply"] = [str(reply)]
        message = Message(**args)
        mailer.send(message)


def format_message(message):
    return "\n\n".join(textwrap.fill(x, width=80) for x in message.split("\n\n"))
