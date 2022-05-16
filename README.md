# measure_store_r
## Installation

Add the following to the top of your R file:
```
library(devtools)
install_github('blockchain-art/measure_store_r')
library(MeasureStoreR)
```

## Usage example
```
print(unique_key())
> "redis:bitops:c6f57338hd1e6b20b8380hg8i26b3fhc5g2iea3c"
```


## Help
To view the help pages:
```
help(package="MeasureStoreR")
```

Or to get more info about a specific method:
```
help("convert_bitmaps_to_counts", package="MeasureStoreR")
```