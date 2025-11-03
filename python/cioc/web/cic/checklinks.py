import json
import logging
from concurrent.futures import ThreadPoolExecutor
from functools import partial
from uuid import uuid4

from pyramid.view import view_config, view_defaults
from redis import Redis
import requests

# this app
from cioc.core import validators, constants as const

from cioc.core.i18n import gettext as _
from cioc.web.cic.viewbase import CicViewBase

log = logging.getLogger(__name__)

templateprefix = "cioc.web.cic:templates/checklinks/"

threadpool = ThreadPoolExecutor(2)


def pager(iterable, page_size=10):
    page = []
    count = 0
    for x in iterable:
        count += 1
        page.append(x)
        if count >= page_size:
            yield page
            count = 0
            page = []

    if page:
        yield page


def try_link(get, link):
    try:
        r = get(link)
        if r.status_code == requests.codes.ok:
            r.close()
            if r.history:
                return ("has_update", r.url, None)
            return ("success", link, None)

        r.raise_for_status()
    except requests.exceptions.RequestException as e:
        # failed to connect fallback to http if needed
        if e.response:
            e.response.close()
        return ("failed", link, e)

    return ("unknown", link, "An unexpected error occured")


def check_links(redispool, records, key_prefix):
    session = requests.Session()
    session.headers["user-agent"] = "cioc-link-checker/1.0 (https://www.cioc.ca/)"
    redis_expire = 120
    timeout = 3.5
    done_key = f"{key_prefix}done"
    results_key = f"{key_prefix}results"
    records_key = f"{key_prefix}records"

    get = partial(session.get, allow_redirects=True, stream=True, timeout=timeout)

    with Redis.from_pool(redispool) as redis:
        redis.expire(done_key, redis_expire)
        for batch in pager(records):
            batch_result = []
            for record in batch:
                address = record["WWW_ADDRESS"]
                protocol = record["WWW_ADDRESS_PROTOCOL"]
                num = record["NUM"]
                if not address:
                    batch_result.append({"NUM": num, "result": "no_address"})
                    continue
                link = (protocol or "https://") + address
                result, updated_link, error = try_link(get, link)
                if error is None:
                    if result == "success" and protocol is None:
                        result = "has_updated_protocol"
                    batch_result.append(
                        {
                            "NUM": num,
                            "result": result,
                            "final_link": updated_link,
                        }
                    )
                    continue

                # if the WWW_ADDRESS_PROTOCOL was already https:// then return error info and move on
                if protocol == "https://":
                    batch_result.append(
                        {"NUM": num, "result": result, "error": str(error)}
                    )

                # https failed, try http
                link = "http://" + address
                result, updated_link, error = try_link(get, link)
                if error is None:
                    batch_result.append(
                        {
                            "NUM": num,
                            "result": result,
                            "final_link": updated_link,
                        }
                    )

                else:
                    batch_result.append(
                        {"NUM": num, "result": result, "error": str(error)}
                    )

            with redis.pipeline(transaction=False) as p:
                p.rpush(results_key, *map(json.dumps, batch_result))
                p.expire(done_key, redis_expire)
                p.expire(results_key, redis_expire)
                p.expire(records_key, redis_expire)
                p.execute()

        with redis.pipeline(transaction=False) as p:
            p.set(done_key, "true", ex=600)
            p.expire(results_key, 600)
            p.expire(records_key, 600)
            p.execute()


def schedule_check_links(request, key_prefix, records):
    with Redis.from_pool(request.redispool) as redis:
        redis.set(f"{key_prefix}done", "false", ex=5)
        redis.set(f"{key_prefix}records", json.dumps(records), 5)
        redis.delete(f"{key_prefix}results")
    threadpool.submit(check_links, request.redispool, records, key_prefix)


def is_user_link_check_already_running(request, key_prefix):
    with Redis.from_pool(request.redispool) as redis:
        val = redis.get(f"{key_prefix}done")

    log.debug("check if user has something running: %s", val)
    return val and val != b"true"


def check_results(request, key_prefix):
    with Redis.from_pool(request.redispool) as redis:
        done = redis.get(f"{key_prefix}done")

        all_results = []
        for i in range(0, 100):
            results = redis.lrange(f"{key_prefix}results", i, i + 99)
            if results is None:
                break

            all_results.extend(results)
            if len(results) < 100:
                break
    log.debug("key_prefix=%s done=%s all_results=%s", key_prefix, done, all_results)
    return done, all_results


class CheckLinksListSchema(validators.RootSchema):
    if_key_missing = None

    NUM = validators.ForEach(
        validators.NumValidator(), convert_to_list=True, not_empty=True
    )
    checkid = validators.UnicodeString(not_empty=True)


@view_defaults(route_name="cic_checklinks")
class Publication(CicViewBase):
    def __init__(self, request, require_login=True):
        super().__init__(request, require_login)

        user = request.user
        # NOTE: We check for CIC Super User so that should be enough, to view
        # www_address, but we'll still need to check that the record is shared
        # to view, and owned by this member to update
        if not (user.cic and user.cic.SuperUser):
            self._security_failure()

    @view_config(
        route_name="cic_checklinks_index",
        renderer=templateprefix + "index.mak",
    )
    def index(self):
        request = self.request

        model_state = request.model_state
        model_state.schema = CheckLinksListSchema()

        if not model_state.validate():
            # not valid, something went wrong
            self._error_page(_("Invalid record ID list", request))

        checkid = model_state.value("checkid")
        key_prefix = f"{const._app_name}:checklinks:{request.user.User_ID}:"
        session_checkid = request.session.get("checklinks-checkid")
        if session_checkid and checkid != session_checkid:
            if is_user_link_check_already_running(
                request, f"{key_prefix}{session_checkid}"
            ):
                return self._error_page(
                    _(
                        "An existing link check is already running. Please wait for it to finish",
                        request,
                    )
                )

        if session_checkid and checkid == session_checkid:
            # cache and fetch all the addresses?
            with Redis.from_pool(request.redispool) as redis:
                worker_has_been_launched = (
                    redis.get(f"{key_prefix}{checkid}:done") is not None
                )
                records = redis.get("f{key_prefix}{checkid}:records")

            if worker_has_been_launched:
                return self._render_page(records)

        with request.connmgr.get_connection("admin") as conn:
            sql = "EXEC dbo.sp_GBL_NUMsToWWW_Address_l ?, ?, ?"
            cursor = conn.execute(
                sql,
                request.dboptions.MemberID,
                request.viewdata.cic.ViewType,
                ";".join(model_state.value("NUM")),
            )

            records = cursor.fetchall()
            colnames = [t[0] for t in cursor.description]

        key_prefix = f"{key_prefix}{checkid}:"
        fixfn = lambda x: dict(zip(colnames, x))
        records = list(map(fixfn, records))

        schedule_check_links(request, key_prefix, records)
        return self._render_page(records)

    def _render_page(self, records):
        title = _("Check Web Links", self.request)
        return self._create_response_namespace(
            title, title, {"records": records}, no_cache=True, no_index=True
        )

    @view_config(renderer="json", match_param="action=check")
    def check_status(self):
        check_id = self.request.params.get("checkid")
        key_prefix = (
            f"{const._app_name}:checklinks:{self.request.user.User_ID}:{check_id}:"
        )
        done, results = check_results(self.request, key_prefix)
        return {
            "done": done is None or done == b"true",
            "results": list(map(json.loads, results)),
        }
