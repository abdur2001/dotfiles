import io
import json
import re
from pprint import pformat, pprint

error = False
try:
    import numpy as np
except ImportError:
    error = True
    print("no numpy, you dumpy")

try:
    import pandas as pd
except ImportError:
    error = True
    print("no pandas, you dumpy")

try:
    import pyarrow as pa
except ImportError:
    error = True
    print("no pyarrow, you numpty")

try:
    import requests
except ImportError:
    error = True
    print("no requests, you numpty")

if error:
    print("you may not be reeadddyyyy yet :/")
else:
    print("you are reeadddyyyy")
