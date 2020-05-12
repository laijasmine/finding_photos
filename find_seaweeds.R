library(tidyverse)
library(googlesheets4)
library(here)
#requires martone lab server access
# read the martone lab google sheet
pml <- "https://docs.google.com/spreadsheets/d/1vzVIT5gjQ0yCGwbAyqB4f8pltOkLfWz27TIFTxnm9hk/edit#gid=0"
ptm <- googlesheets4::read_sheet(pml, sheet = "Copy of All PTM data", skip = 1,
                                 col_types = "iccccccDcccccccccccccccccccccccccc-iiccc")

#the name of the seaweeds you want
seaweeds <- c("Mazzaella splendens", "Ulva fenestrata", "Ulva intestinalis", "Petrocelis", 
              "Ralfsia", "Sargassum muticum")

#filters the masterlist for ones with photos
search_ptm <- function(name){
  ptm %>% 
    filter(str_detect(ptm$`Final determination`, name) |
             str_detect(ptm$`Determination in the field`, name),
           !is.na(ptm$`Photos on server`))
}

#prep the dataframe to be searched
find_photo <- map_dfr(seaweeds, search_ptm) %>% 
  select(`PTM#`) %>% 
  mutate(ptm = paste0("PTM",`PTM#`))

#path to the server
path <- "/Volumes/martonelab/Photos/1501-2000"

my_files <- find_photo$ptm %>% 
  map(~list.files(path = path,
                  pattern = .,
                  all.files = T,
                  full.names = T))

# identify the folders
new_folder <- paste0(here(),"/results")

# copy the files to the new folder
my_files <- my_files %>% 
  map(~file.copy(., new_folder))

photo_meta <- map_dfr(seaweeds, search_ptm)

#save the frame
write_csv(photo_meta, "results/found_seaweeds.csv",
          na = "")
