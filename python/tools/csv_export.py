# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

import argparse
from io import StringIO
import datetime
import os
import subprocess
import sys
import traceback
from urllib.parse import urljoin
from zipfile import ZipFile

import requests

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import fakerequest

from cioc.core import constants as const, config, email

const.update_cache_values()


class FileWriteDetector:
    def __init__(self, obj):
        self.__obj = obj
        self.__dirty = False

    def is_dirty(self):
        return self.__dirty

    def write(self, string):
        self.__dirty = True
        return self.__obj.write(string)

    def __getattr__(self, key):
        return getattr(self.__obj, key)


class DEFAULT:
    pass


def update_environ(target, extra):
    files = os.environ.get(target, "").split()
    os.environ[target] = " ".join(files + [extra])


def get_config_item(args, key, default=DEFAULT):
    config_prefix = args.config_prefix
    config = args.config
    if default is DEFAULT:
        try:
            return config[config_prefix + key]
        except KeyError:
            return config[key]

    return args.config.get(config_prefix + key, config.get(key, default))


def get_config_dict(args, key):
    """Return a dictionary of values based on a prefix from the config"""
    config_prefix = args.config_prefix
    config = args.config

    key_prefix = key + "."

    result = {
        k[len(key_prefix) :]: v for k, v in config.items() if k.startswith(key_prefix)
    }
    key_prefix = config_prefix + key_prefix
    result.update(
        (k[len(key_prefix) :], v) for k, v in config.items() if k.startswith(key_prefix)
    )

    return result


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config", dest="configfile", action="store", default=const._config_file
    )
    parser.add_argument("url", action="store")
    parser.add_argument("dest", action="store", default=None, nargs="?")
    parser.add_argument("--file", dest="file", action="store", default=None)
    parser.add_argument(
        "--email", dest="email", action="store_const", const=True, default=False
    )
    parser.add_argument(
        "--verbose", dest="verbose", action="store_const", const=True, default=False
    )
    parser.add_argument(
        "--nosslverify",
        dest="nosslverify",
        action="store_const",
        const=True,
        default=False,
    )
    parser.add_argument(
        "--config-prefix", dest="config_prefix", action="store", default=""
    )

    args = parser.parse_args(argv)
    if args.config_prefix and not args.config_prefix.endswith("."):
        args.config_prefix += "."

    try:
        args.config = config.get_config(args.configfile, const._app_name)
    except Exception:
        sys.stderr.write("ERROR: Could not process config file:\n")
        sys.stderr.write(traceback.format_exc())
        raise

    if args.dest is None:
        args.dest = get_config_item(args, "csv_export_dest")

    return args


def stream_download(dest_file, url, **kwargs):
    # remove possible conflicting arg
    kwargs.pop("stream", None)

    r = requests.get(url, stream=True, **kwargs)
    r.raise_for_status()
    size = 0
    with open(dest_file, "wb") as fd:
        for chunk in r.iter_content(chunk_size=8192):
            size += len(chunk)
            fd.write(chunk)

    update_environ("ALLEXPORTFILES", dest_file)
    print("downloaded", size, "bytes to ", dest_file)


def download_content(url, data, **kwargs):
    r = requests.get(url, data=data, **kwargs)
    r.raise_for_status()

    return r.json()


def download_url_start(baseurl):
    return urljoin(baseurl, "export2.asp")


def download_url_fetch(urls):
    return urls["zipped"]


def data_paramter(args):
    data = [
        ("API", "on"),
        ("ExportType", "3"),
        ("ExcelFormat", "C"),
        ("DSTID", get_config_item(args, "csv_export_distributions", "")),
        ("PBID", get_config_item(args, "csv_export_publications", "")),
        ("ExcelProfileID", get_config_item(args, "csv_export_profile")),
    ]

    ln = get_config_item(args, "csv_export_lang", None)
    if ln:
        data.append(("Ln", ln))

    return data


def download_kwargs(args):
    kwargs = {
        "auth": (
            get_config_item(args, "csv_export_user"),
            get_config_item(args, "csv_export_password"),
        ),
    }

    if args.nosslverify:
        kwargs["verify"] = False

    return kwargs


def open_zipfile(dest_file):
    zip = ZipFile(dest_file, "r")
    files = zip.namelist()
    return zip.open(files[0], "r")


def email_log(args, outputstream, is_error, success_email, error_email):
    author = get_config_item(args, "csv_export_notify_from", const.CIOC_ADMIN_EMAIL)
    to = []
    if success_email:
        to.extend(x.strip() for x in success_email.split(","))
    if error_email and is_error:
        to.extend(x.strip() for x in error_email.split(","))
    name = get_config_item(args, "csv_export_title", "")
    if name:
        name = " " + name
    if not to:
        return
    email.send_email(
        fakerequest(args.config),
        author,
        to,
        "Automated CSV Export{}{}".format(name, " -- ERRORS!" if is_error else ""),
        outputstream.getvalue(),
    )


def main(argv):
    args = parse_args(argv)
    retval = 0

    success_email = get_config_item(args, "csv_export_notify_success", None)
    error_email = get_config_item(args, "csv_export_notify_error", None)
    if args.email:
        if not success_email and not error_email:
            sys.stderr.write(
                "ERROR: No value for csv_export_notify_success or csv_export_notify_error set in config\n"
            )
            return 1
        else:
            sys.stdout = StringIO()
            sys.stderr = FileWriteDetector(sys.stdout)

    before_cmd = get_config_item(args, "csv_export_run_before_cmd", None)
    after_cmd = get_config_item(args, "csv_export_run_after_cmd", None)

    if before_cmd:
        subprocess.call(before_cmd, shell=True)

    url = None
    kwargs = {}
    try:
        args.now = datetime.datetime.now()
        args.dest_file = args.now.strftime(args.dest)
        url = download_url_start(args.url)
        kwargs = download_kwargs(args)

        try:
            urls = download_content(url, data_paramter(args), **kwargs)
            stream_download(args.dest_file, download_url_fetch(urls), **kwargs)
        except requests.HTTPError as e:
            body = ""
            if e.response:
                body = ": " + e.response.text
            sys.stderr.write(f"Unable to download file: {e}{body}\n")
            retval = 1

    except requests.HTTPError:
        pass

    except Exception:
        sys.stderr.write("ERROR: Something went wrong generating the CSV export:\n")
        sys.stderr.write(traceback.format_exc())
        retval = 1

    if after_cmd:
        env = dict(os.environ)
        env.update(get_config_dict(args, "csv_export_run_after_cmd"))
        if args.verbose:
            print("running after_cmd:", after_cmd)
            print("ALLEXPORTFILES=", os.environ.get("ALLEXPORTFILES"))
        p = subprocess.Popen(
            after_cmd,
            shell=True,
            env=env,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        stdoutdata, stderrdata = p.communicate()
        if stdoutdata:
            print("post_cmd stdout:\n", stdoutdata.decode("latin1"))
        if stderrdata:
            print("post_cmd stderr:\n", stderrdata.decode("latin1"))
        if p.returncode:
            print(
                "Post processing command returned an error result",
                p.returncode,
                file=sys.stderr,
            )

    if args.email:
        email_log(args, sys.stdout, sys.stderr.is_dirty(), success_email, error_email)

    return retval


if __name__ == "__main__":
    normalstdout = sys.stdout
    normalstderr = sys.stderr
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.stdout = normalstdout
        sys.stderr = normalstderr

        raise
