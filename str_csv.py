#!/bin/env python

import re
import pandas as pd
import sys

keys = ("Subject: CN", "Subject DNS name", "Not After", "Serial number")

attrs = []
all = []

if len(sys.argv) < 2:
    print("Usage: ", __file__, "input_file") 
    sys.exit(1)

with open(sys.argv[1]) as certs_file:
    certs_file_content = certs_file.readlines()


for line in certs_file_content:
    for key in keys:
        if re.search(key, line):
            attrs.append(re.sub(".+[^\d]:", '', line))
    if re.search(keys[3], line):
        all.append(attrs)
        attrs = []

pd.DataFrame(all).to_csv('out.csv') 

