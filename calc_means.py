#!/usr/bin/env python3

import pandas as pd

data_clean = pd.read_csv('data_clean.csv', quotechar='"')
means = data_clean.groupby(['Interconnect', 'Num. TitanX', 'Num. GTX980', 'Num. nodes']).mean()
means.to_csv('means_clean.csv')

