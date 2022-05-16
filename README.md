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

<img width="770" alt="Screenshot 2022-05-16 at 15 32 29" src="https://user-images.githubusercontent.com/79599315/168617065-359d83fb-4b7e-473e-a928-58a3fc8e9b04.png">
<img width="771" alt="Screenshot 2022-05-16 at 15 31 56" src="https://user-images.githubusercontent.com/79599315/168617125-6dd17fd5-8cd0-4872-95aa-7478cc2dfa2f.png">
