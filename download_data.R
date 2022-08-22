#######################
# Download the data
#
# Daten von: https://github.com/martin-illarion/covid-age-bl/blob/master/Readme.md
#######################

library(tidyverse)
library(lubridate)

temp <- tempfile()
.path <-"~/CovidR/Covid Data/"

##
# AGES
##

# Download AGES Dashboard Daten als zip
tryCatch({
download.file("https://covid19-dashboard.ages.at/data/data.zip", destfile=temp, method="wget")
unzip(temp, list=FALSE, exdir=paste0(tempdir()))
message("Successfully downloaded AGES data")
},
error = function(e) { 
  message("Error downloading AGES data!")
  print(e)
},
warning = function(w) {
  message("Warning downloading AGES data!")
  print(w)
})

## Extract CovidFaelle_Altersgruppe.csv
read_delim(paste0(tempdir(), "/CovidFaelle_Altersgruppe.csv"), delim=";") |>
  select(
    Datum = Time, Altersgruppe, Bundesland, Einwohner = AnzEinwohner, Geschlecht, Faelle.cumsum = Anzahl, Genesen.cumsum = AnzahlGeheilt, Gestorben.cumsum = AnzahlTot
  ) |>
  group_by(Altersgruppe, Bundesland, Geschlecht) |>
  mutate(
    Datum = as_date(dmy_hms(Datum)),
    Geschlecht = str_to_lower(Geschlecht),
    Faelle.neu = Faelle.cumsum - lag(Faelle.cumsum, order_by = Datum),
    Genesen.neu = Genesen.cumsum - lag(Genesen.cumsum, order_by = Datum),
    Gestoben.neu = Gestorben.cumsum - lag(Gestorben.cumsum, order_by = Datum)
  ) |>
  write_csv(paste0(.path, "raw data/ages.altersgruppe.csv"))

## Extract CovidFaelle_Timeline.csv
read_delim(paste0(tempdir(), "/CovidFaelle_Timeline.csv"), delim=";") |>
  select(
    Datum = Time, Bundesland, Einwohner = AnzEinwohner, Faelle.neu = AnzahlFaelle, Genesen.neu = AnzahlGeheiltTaeglich, Gestorben.neu = AnzahlTotTaeglich
  ) |>
  mutate(
    Datum = as_date(dmy_hms(Datum))
  ) |>
  write_csv(paste0(.path, "raw data/ages.timeline.csv"))

## Extract CovidFallzahlen.csv
read_delim(paste0(tempdir(), "/CovidFallzahlen.csv"), delim=";") |>
  select(
    Meldedatum = Meldedat, Bundesland, Tests.gesamt = TestGesamt, 
    Normalstation.Faelle = FZHosp,  Normalstation.Frei = FZHospFree, ICU.Faelle = FZICU, ICU.Frei = FZICUFree
  ) |>
  mutate(
    Meldedatum = dmy(Meldedatum),
    Normalstation.Gesamt = Normalstation.Faelle + Normalstation.Frei,
    ICU.Gesamt = ICU.Faelle + ICU.Frei
  ) |>
  write_csv(paste0(.path, "raw data/ages.fallzahlen.csv"))

## Extract Hospitalisierung.csv
read_delim(paste0(tempdir(), "/Hospitalisierung.csv"), delim=";") |>
  select(
    Meldedatum, Bundesland, Tests.gesamt = TestGesamt, 
    Normalbetten.belegt = NormalBettenBelCovid19, 
    ICU.belegt.Cov19 = IntensivBettenBelCovid19, ICU.belegt.nichtCov19 = IntensivBettenBelNichtCovid19, ICU.frei = IntensivBettenFrei, ICU.kapazität = IntensivBettenKapGes
  ) |>
  mutate(
    Meldedatum = as_date(dmy_hms(Meldedatum))
  ) |>
  write_csv(paste0(.path, "raw data/ages.hospitalisierung.csv"))


##
# EMS
##

tryCatch({
download.file("https://info.gesundheitsministerium.gv.at/data/timeline-faelle-ems.csv", destfile=temp, method="wget")
read_delim(temp, delim=";") |>
  select(
    Datum, Bundesland = Name, Faelle.cumsum = BestaetigteFaelleEMS
  ) |>
  group_by(Bundesland) |>
  mutate(
    Datum = as_date(ymd_hms(Datum)),
    Faelle.neu = Faelle.cumsum - lag(Faelle.cumsum, order_by = Datum)
  ) |>
  write_csv(paste0(.path, "raw data/ems.timeline.csv"))
message("Successfully downloaded EMS data")
},
error = function(e) {
  message("Error downloading EMS data!")
  print(e)
},
warning = function(w) {
  message("Warning downloading EMS data!")
  print(w)
})

##
# Gesundheitsministerium
##

tryCatch({
download.file("https://info.gesundheitsministerium.gv.at/data/timeline-faelle-bundeslaender.csv", destfile=temp, method="wget")
read_delim(temp, delim=";") |>
  select(
    Datum, Bundesland = Name, Tests.gesamt = Testungen, Tests.AG = TestungenAntigen, Tests.PCR = TestungenPCR, Faelle.cumsum = BestaetigteFaelleBundeslaender, Genesen.cumsum = Genesen, Gestorben.cumsum = Todesfaelle, Hospitalisierung, Intensivstation
  ) |>
  group_by(Bundesland) |>
  mutate(
    Datum = as_date(ymd_hms(Datum)),
    Faelle.neu = Faelle.cumsum - lag(Faelle.cumsum, order_by = Datum)
  ) |>
  write_csv(paste0(.path, "raw data/BMSGPK.timeline.csv"))
message("Successfully downloaded BMSGPK timeline data")
},
error = function(e) {
  message("Error downloading BMSGPK timeline data!")
  print(e)
},
warning = function(w) {
  message("Warning downloading BMSGPK timeline data!")
  print(w)
})   

tryCatch({
download.file("https://info.gesundheitsministerium.gv.at/data/COVID19_vaccination_doses_timeline.csv", destfile=temp, method="wget")
read_delim(temp, delim=";") |>
  select(
    Datum = date, Bundesland = state_name, Impfstoff = vaccine, Dosis = dose_number, Anzahl.kumulativ = doses_administered_cumulative
  ) |>
  mutate(
    Datum = as_date(ymd_hms(Datum))
  ) |>
  write_csv(paste0(.path, "raw data/BMSGPK.vaccination .csv"))
message("Successfully downloaded BMSGPK vaccination data")
},
error = function(e) {
  message("Error downloading BMSGPK vaccination data!")
  print(e)
},
warning = function(w) {
  message("Warning downloading BMSGPK vaccination data!")
  print(w)
}) 

