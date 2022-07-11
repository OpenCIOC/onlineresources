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

import optparse
import sys
import textwrap

import pyramid

assert pyramid

from pyramid.paster import bootstrap


def main(argv=sys.argv, quiet=False):
    command = PRoutesCommand(argv, quiet)
    return command.run()


class PRoutesCommand:
    description = """\
    Print all URL dispatch routes used by a Pyramid application in the
    order in which they are evaluated.  Each route includes the name of the
    route, the pattern of the route, and the view callable which will be
    invoked when the route is matched.

    This command accepts one positional argument named "config_uri".  It
    specifies the PasteDeploy config file to use for the interactive
    shell. The format is "inifile#name". If the name is left off, "main"
    will be assumed.  Example: "proutes myapp.ini".

    """
    bootstrap = (bootstrap,)
    stdout = sys.stdout
    usage = "%prog config_uri"

    parser = optparse.OptionParser(usage, description=textwrap.dedent(description))

    def __init__(self, argv, quiet=False):
        self.options, self.args = self.parser.parse_args(argv[1:])
        self.quiet = quiet

    def _get_mapper(self, registry):
        from pyramid.config import Configurator

        config = Configurator(registry=registry)
        return config.get_routes_mapper()

    def out(self, msg):  # pragma: no cover
        if not self.quiet:
            print(msg)

    def run(self, quiet=False):
        if not self.args:
            self.out("requires a config file argument")
            return 2
        config_uri = self.args[0]
        env = self.bootstrap[0](config_uri)
        registry = env["registry"]
        introspector = registry.introspector

        urls = set()
        for route in introspector.get_category("routes"):
            rout_intr = route["introspectable"]
            pattern = rout_intr["pattern"]
            if not pattern.startswith("/"):
                pattern = "/" + pattern
            if pattern.endswith("{action}"):
                for view in route["related"]:
                    if view.category_name != "views":
                        continue
                    match_param = view.get("match_param")
                    if match_param:
                        urls.add(
                            pattern.replace("{action}", match_param.split("=")[-1])
                        )
                    else:
                        # import pdb
                        # pdb.set_trace()
                        urls.add(pattern)
            else:
                urls.add(pattern)

        print("\n".join(sorted(urls)))

        return 0


if __name__ == "__main__":
    main()
