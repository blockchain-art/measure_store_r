#' Generates a random unique key. Intended usage is for the creation of temporary bitmaps
#' @export
#' @return "redis:bitops:dbhhg8i2hga7ee7g6bh5hjhdd5217bjh075jh94c"
unique_key <- function() {
  key <- tolower(paste("redis:bitops:", paste(sample(c(0:9, LETTERS[1:10]), 40, T), collapse = ''), sep=""))

  return(key)
}

#' Writes given indexes to RedisRoaring under a uniquely generated key
#' @export
#' @param indexes character variable e.g.: \code{c("1, 3, 4", "2")}
#' @param roaring_client a Redis client e.g.:\cr
#' \code{roaring_client <- redis_client('redis://127.0.0.1:6380/0')}
#' @return "redis:bitops:8dd1b989996gg8523633c06h7d4026067fc1cfc6" "redis:bitops:06d01cfc2gijj2da3hjdc36271ga6g15bcbc0773"
write_respondent_indexes <- function(indexes, roaring_client) {
  root_keys <- c()

  for (i in indexes) {
    key <- i
    dest_key <- unique_key()

    roaring_client$command(c("R.APPENDINTARRAY", dest_key, as.numeric(strsplit(key,split=", ",fixed=TRUE)[[1]])))
    root_keys <- append(root_keys, dest_key)
  }

  return(root_keys)
}

#' Expand bitmaps to respondent level data
#' @export
#' @param bitmaps a bitmap dataframe
#' @param roaring_client a Redis client e.g.:\cr
#' \code{roaring_client <- redis_client('redis://127.0.0.1:6380/0')}
#' @return \tabular{rrrrr}{
#'  brand \tab usage\tab               respondent_id\cr
#'  Pepsi \tab    1 \tab               2\cr
#'  Fanta \tab    1 \tab               3\cr
#'  Fanta \tab    1 \tab               4\cr
#'  Coke  \tab    1 \tab               1\cr
#'  Coke  \tab    1 \tab               2\cr
#' }
to_respondent_level_data <- function(bitmaps, roaring_client) {
  bitmaps <- as.data.frame(bitmaps)
  respondents <- get_respondent_indexes(bitmaps$root_key, roaring_client)

  duptimes <- list()
  for (column_number in 1:nrow(bitmaps)) {
    duptimes[[column_number]] <- length(as.numeric(respondents[[column_number]]))
  }

  idx <- rep(1:nrow(bitmaps), duptimes)
  respondent_level_bitmaps <- bitmaps[idx,]

  respondent_level_bitmaps$respondent_id <- unlist(respondents)
  respondent_level_bitmaps <- respondent_level_bitmaps %>%
    select(-root_key)

  return(respondent_level_bitmaps)
}

#' Generates member counts
#' @export
#' @param respondent_level_bitmaps a respondent level bitmap dataframe
#' @param roaring_client a Redis client e.g.:\cr
#' \code{roaring_client <- redis_client('redis://127.0.0.1:6380/0')}
#' @return \tabular{rrrrr}{
#' member_count \tab root_key\cr
#' <int> \tab <chr>\cr
#'  1 \tab redis:bitops:3gfbiagag29bdeh199hab4482adgcbd94h97847f\cr
#'  2 \tab redis:bitops:0hb9f0ciii1cbcb7che274b36792a82h5gef1agf\cr
#' }
member_count <- function(respondent_level_bitmaps, roaring_client) {
  member_counts <- respondent_level_bitmaps %>%
    group_by(respondent_id) %>%
    summarise(member_count = n()) %>%
    group_by(member_count) %>%
    summarize(indexes = paste(sort(unique(respondent_id)),collapse=", ")) %>%
    mutate(root_key = write_respondent_indexes(indexes, roaring_client)) %>%
    select(-indexes)

  return(member_counts)
}

#' Performs R.BITCOUNT operation on bitmaps to produce counts
#' @export
#' @param bitmaps a bitmap dataframe
#' @param roaring_client a Redis client e.g.:\cr
#' \code{roaring_client <- redis_client('redis://127.0.0.1:6380/0')}
#' @return \tabular{rrrrr}{
#' brand \tab usage \tab counts\cr
#' Pepsi \tab   1  \tab    1\cr
#' Fanta \tab    1 \tab    2\cr
#' Coke  \tab   1  \tab    2\cr
#' }
generate_counts_for_bitmaps <- function(bitmaps, roaring_client) {
  bitmaps <- as.data.frame(bitmaps)
  results <- c()

  for (key in bitmaps$root_key) {
    value <- roaring_client$command(c("R.BITCOUNT", key))
    results[[key]] <- value
  }

  results <- bitmaps %>%
    mutate(counts = as.integer(results)) %>%
    select(-root_key)

  df <- as.data.frame(results)
  return(df)
}

#' Create a Redis client
#' @export
#' @param url example: \code{'redis://127.0.0.1:6380/1'}
#' @return a client for connecting to Redis
redis_client <- function(url) {
  confl <- redis_config(url=url)
  client <- redux::hiredis(confl)

  return(client)
}

#' Retrieve respondent indexes for given root_keys
#' @export
#' @param root_keys a vector of root keys e.g.: \code{c("redis:bitops:f0f03fec88a8effcd6e131fdc9407232de0387eb")}
#' @param roaring_client a Redis client e.g.:\cr
#' \code{roaring_client <- redis_client('redis://127.0.0.1:6380/0')}
get_respondent_indexes <- function(root_keys, roaring_client) {
  commands <- list()
  for (i in seq_along(root_keys)) {
    root_key <- root_keys[i]
    commands[[i]] <- c("R.GETINTARRAY", root_key)
  }
  respondent_indexes <- roaring_client$pipeline(.commands = commands)

  return(respondent_indexes)
}
