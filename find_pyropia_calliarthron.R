library(tidyverse)
library(ptm)
library(googlesheets4)
library(here)

# more general script for finding everything of a certain genus
pml <- "https://docs.google.com/spreadsheets/d/1vzVIT5gjQ0yCGwbAyqB4f8pltOkLfWz27TIFTxnm9hk/edit#gid=0"
ptm <- googlesheets4::read_sheet(pml, sheet = "Copy of All PTM data", skip = 1,
                                 col_types = "iccccccDcccccccccccccccccccccccccc-iiccc")

pyr <- ptm %>% 
  filter(str_detect(`Final determination`, "Pyropia") |
           str_detect(`Determination in the field`, "Pyropia"),
         !is.na(`Photos on server`))

cal <- ptm %>% 
  filter(str_detect(`Final determination`, "Calliarthron") |
           str_detect(`Determination in the field`, "Calliarthron"),
         !is.na(`Photos on server`))

find_photo <- rbind(pyr, cal) %>% 
  select(`PTM#`) %>% 
  mutate(ptm = paste0("PTM",`PTM#`))

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

photo_meta <- rbind(pyr, cal)

write_csv(photo_meta, "results/found_pyropia_calliarthron.csv",
          na = "")
