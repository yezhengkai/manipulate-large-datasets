from pathlib import Path

import dask
import datatable
import modin
import vaex


def datadir(*args):
    return Path(__file__, "..", "data", *args).resolve()

data_path = datadir("GridFlexHeetenDataset.csv")  # 61.49GB
