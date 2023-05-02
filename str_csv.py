#!/bin/env python

import re
import pandas as pd
import sys
import time

keys = ("Subject: CN", "Subject DNS name", "Serial number")
until = "Not After"

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
    if re.search(until, line):
        sub_date = re.sub(".+[^\d]:", '', line).strip()
        stripped_date = sub_date.removesuffix('UTC').strip()
        time_obj = time.strptime(stripped_date)
        time_formatted = time.strftime('%d.%m.%Y', time_obj)
        attrs.append(time_formatted)
    if re.search(keys[2], line):
        all.append(attrs)
        attrs = []

pd.DataFrame(all).to_csv('out.csv') 

