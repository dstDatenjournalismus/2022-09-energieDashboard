library(jsonlite)

data_raw = fromJSON("https://wasser.bgld.gv.at/?type=200365&tx_lshydrography_annualdata[zrid]=hjpRalsA7imnA-XjIsk6qQ", simplifyVector = F, simplifyDataFrame = F)
df = data.frame(do.call("rbind", data_raw))
df_unlist = as.data.frame(apply(df, 2, FUN = unlist))
op_neusiedler_see = "R/output/wasserstand_neusiedlerSee.csv"
write.csv(df_unlist, op_neusiedler_see)
