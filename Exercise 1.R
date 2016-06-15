#--- load packages ---
library(dplyr)
library(tidyr)
library(reshape2)

#---- load data, create data frame, and view ---
df <- read.csv('refine_original.csv')
data <- tbl_df(df)
data %>% View()


#--- turn company column to lower case and correct spelling ----
data$company <- tolower(data$company)

#find out how companies are mispelled. After next step, re-run this code to make sure all companies are unique
data %>% 
  select(company) %>% 
  unique()

#correct mispelled words
data$company <- gsub('fillips|phillips|phllips|phlips|phillps', 'philips', data$company)
data$company <- gsub('akz0|ak zo', 'akzo', data$company)
data$company <- gsub('unilver', 'unilever', data$company)


#--- separate product code and number ---

#create new columns using reshape2 (colsplit), then bind together
product <- colsplit(data$Product.code...number, "-", c("product_code", "product_number"))
data <- cbind(data, product)

#delete old column
data$Product.code...number = NULL


#--- add product categories ---
product_category <- data$product_code
data <- cbind(data, product_category)

#make sure product categories are unique. Re-run code after adding product categories
data %>% 
  select(product_category) %>% 
  unique()

data$product_category <- gsub('p', 'Smartphone', data$product_category)
data$product_category <- gsub('v', 'TV', data$product_category)
data$product_category <- gsub('x', 'Laptop', data$product_category)
data$product_category <- gsub('q', 'Tablet', data$product_category)

#--- add full address for geocoding ---
data <- mutate(data, full_address = paste(data$address, data$city, data$country, sep = ','))

#remove redundant columns
data$address = NULL
data$city = NULL
data$country = NULL


#--- create dummy variables for company and product category ---

#create columns and convert to binary
company_philips <- as.numeric(data$company == 'philips')
company_akzo <- as.numeric(data$company == 'akzo')
company_van_houten <- as.numeric(data$company == 'van houten')
company_unilever <- as.numeric(data$company == 'unilever')

#bind columns to dataframe
data <- cbind(data, company_philips, company_akzo, company_van_houten, company_unilever)

#create columns and convert to binary
product_smartphone <- as.numeric(data$product_category == 'Smartphone')
product_tv <- as.numeric(data$product_category == 'TV')
product_laptop <- as.numeric(data$product_category == 'Laptop')
product_tablet <- as.numeric(data$product_category == 'Tablet')

#bind columns to dataframe
data <- cbind(data, product_smartphone, product_tv, product_laptop, product_tablet)


data %>% View()

