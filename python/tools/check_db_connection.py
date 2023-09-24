import argparse
import sys
import os

try:
    import cioc  # NOQA
except ImportError:
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import Context

from cioc.core import constants as const

const.update_cache_values()


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config", dest="configfile", action="store", default=const._config_file
    )
    parser.add_argument(
        "--config-prefix", dest="config_prefix", action="store", default=""
    )

    args = parser.parse_args(argv)
    if args.config_prefix and not args.config_prefix.endswith("."):
        args.config_prefix += "."

    return args


def main(argv):
    args = parse_args(argv)
    context = Context(args)
    retval = 0
    args.config = context.config
    for type in ("admin", "cic", "vol"):
        print("attempting", type)
        with context.connmgr.get_connection(type) as conn:
            cursor = conn.execute("SELECT @@VERSION")
            result = cursor.fetchall()
            cursor.close()
            print(type, "result", result)

    return retval


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
