library(dplyr)
library(magrittr)
library(factoextra)
library(qqplotr)
library(tictoc)
library(caret)
library(keras)
library(ggplot2)
library(tidyr)
library(tensorflow)
source(here::here("R","pcals.R"))
source(here::here("R","autoencoder.R"))
source(here::here("R","autoencoder_opt.R"))
source(here::here("R","pca_functions.R"))
source(here::here("R","pcambtsrR.R"))
source(here::here("R","lsdAnalysis.R"))
source(here::here("R","lsdfig.R"))


## ----load data----------------------------------------------------------------------------------------------------
dat <- read.csv(here::here("data","pedestrian-count-dcc-2022.csv")) %>%
	select_if(is.numeric) %>%
	filter(complete.cases(.))


## ----delnullvar, out.width='70%'----------------------------------------------------------------------------------
print("These variables show null variance. Consider their deletion before the PCA")
summary(dat[,(apply(dat,2,var)==0),drop=F])
dat.or <- dat
dat <- dat[,!(apply(dat,2,var)==0),drop=F]
dat <- dat[,seq(1,ncol(dat),by=3)]
act.fun <- "relu"
load("DFref_models.RData")
load(file="DFref_loadings.RData")

modelA.DF <- keras_model_sequential()
modelA.DF %>%
	layer_dense(units=ncol(dat), activation = act.fun, input_shape = ncol(dat),
							use_bias = TRUE, name = "input") %>%
	layer_dense(units=16, activation = act.fun, input_shape = ncol(dat),
							use_bias = TRUE, name = paste0("hidden_in_1")) %>%
	layer_dense(units= 4, activation = act.fun, input_shape = 16,
							use_bias = TRUE, name = "latent") %>%
	layer_dense(units=16, activation = act.fun, input_shape = 4,
							use_bias = TRUE, name = paste0("hidded_out_1")) %>%
	layer_dense(units=ncol(dat), activation = act.fun, input_shape = 16,
							use_bias = TRUE, name = "output")




## ----remrows, results="hide",out.width="50%",fig.asp=0.9----------------------------------------------------------
pca_remrows <- vpca_removerows(data = dat, 4, ref.P = P.pca.ref, k_ho = 20, 
															 rm_pctges = c(2,5,10,seq(20,80,by=20)))
autoencoder_remrows <- vautoencoder_removerows(data = dat, 4, ref.P = P.ae.ref,
																							 model.ae = modelA.DF, k_ho = 20, 
																							 ho.part = pca_remrows$ho,
																							 rm_pctges = c(2,5,10,seq(20,80,by=20)))
save(list = c("pca_remrows", "autoencoder_remrows"),file="DF_RemRows_models.RData")
