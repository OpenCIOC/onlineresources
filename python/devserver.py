import os
import sys

# curdir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(curdir)

from pyramid.scripts.pserve import main

sys.exit(main(sys.argv))
