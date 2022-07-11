from __future__ import absolute_import
from __future__ import print_function
import os
import sys
import subprocess
import argparse
from cioc.core.utils import write_file

site_root = os.path.abspath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
)

config_tmpl = """
[global]
server=%(server)s
database=%(database)s
driver=SQL Server Native Client 10.0
provider=SQLNCLI10

session.type=redis
session.url=127.0.0.1:6379
cache.type=redis
cache.url=127.0.0.1:6379

admin_uid=%(username)s
admin_pwd=%(password)s

cic_uid=%(username)s
cic_pwd=%(password)s

vol_uid=%(username)s
vol_pwd=%(password)s
"""


def parse_args():
    parser = argparse.ArgumentParser(description="Configure IIS Site for CIO")
    parser.add_argument(
        "--db-server", dest="db_server", default="(local),1433", help="database server"
    )
    parser.add_argument(
        "--db-name", dest="db_name", default="cioc", help="database name"
    )
    parser.add_argument(
        "--user-name",
        dest="user_name",
        default="cioc_login",
        help="db login for cioc databse",
    )
    parser.add_argument(
        "--password", default="cioc_login", help="db password for cioc databse"
    )

    return parser.parse_args()


def populate_config_file(args):
    config_dir = os.path.abspath(os.path.join(site_root, "..", "..", "config"))
    if not os.path.exists(config_dir):
        print("creating config directory", config_dir)
        os.mkdir(config_dir)

    config_file = os.path.join(config_dir, os.path.basename(site_root) + ".ini")
    if not os.path.exists(config_file):
        print("creating config file", config_file)
        contents = config_tmpl % {
            "server": args.db_server,
            "database": args.db_name,
            "username": args.user_name,
            "password": args.password,
        }
        write_file(config_file, contents)


def main():
    args = parse_args()

    subprocess.call(
        [
            os.path.join(sys.prefix, "scripts", "mkvirtualenv.bat"),
            "--system-site-packages",
            "ciocenv4py3",
        ]
    )
    env_python = os.path.join(
        os.environ["HOMEPATH"], "Envs", "ciocenv4py3", "scripts", "python.exe"
    )
    subprocess.call([env_python, "-m", "pip", "install", "-U", "pip"])
    subprocess.call([env_python, "-m", "pip", "install", "-r", "requirements.txt"])

    populate_config_file(args)


if __name__ == "__main__":
    main()
