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
Some examples of the help pages:
<img width="773" alt="help_page_1" src="https://user-images.githubusercontent.com/79599315/168616545-c1e7c7c5-9f60-456c-96f2-e2edee94823e.png">
<img width="775" alt="Screenshot 2022-05-16 at 15 30 56" src="https://user-images.githubusercontent.com/79599315/168616722-94dbdde0-7422-4e30-a909-0a0a0baaa3ab.png">
