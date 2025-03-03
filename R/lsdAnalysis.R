lsdAnalysis <- function(data.anova, factor1="", factor2=NULL, factor.color = factor1,
                        factorrnd="Repetition", alpha = 0.05, hier=T, graph.out = "errorbar",
                        tittext=paste("Experiment", factor1, "(LSD intervals)"),
                        xtext = factor2){
  # Use factor 1 for the method
  # Use factor 2 for the artifact
  lsd.Analysis <- list()
  orange_rgb <- c(0.8500, 0.3250, 0.0980)
  i.metrics <- which((grepl("*radius", names(data.anova)) | grepl("*corr", names(data.anova))))
  data.anova[,factor1] <- as.factor(data.anova[,factor1])
  if(!is.null(factor2)){
    data.anova[,factor2] <- as.factor(data.anova[,factor2])
  }
  if(!is.null(factorrnd)){
    data.anova[,factorrnd] <- as.factor(data.anova[,factorrnd])
  }
  lsd.plot <- vector(mode = "list", length = length(i.metrics))
  names(lsd.plot) <-  names(data.anova)[i.metrics]
  for (j_metric in i.metrics){
    metric_name <- (colnames(data.anova)[j_metric])
    if(!is.null(factor2) & !hier){
      lsd.Analysis[[metric_name]] <- aov(data.anova[,metric_name] ~ 
                                          data.anova[,factor1] + data.anova[,factor2] + 
      																	 	Error(data.anova[,factorrnd]), 
                                        data = data.anova)
      factor.x <- factor2
    } else if(!is.null(factor2) & hier){
      lsd.Analysis[[metric_name]] <- aov(data.anova[,metric_name] ~ 
                                          data.anova[,factor1] + data.anova[,factor2] + 
      																	 	Error(data.anova[,factor2]/data.anova[,factorrnd]), 
                                        data = data.anova)
      factor.x <- factor2
    } else if(is.null(factor2) & hier){
      lsd.Analysis[[metric_name]] <- aov(data.anova[,metric_name] ~ data.anova[,factor1] + 
      																	 	+ Error(data.anova[,factor1]/data.anova[,factorrnd]), 
                                        data = data.anova)
      factor.x <- factor1
    } else {
    	if (!is.null(factorrnd)){
    		lsd.Analysis[[metric_name]] <- aov(data.anova[,metric_name] ~ 
    																			 	data.anova[,factor1] + Error(data.anova[,factorrnd]), 
    																			 data = data.anova)
    	} else {
    		lsd.Analysis[[metric_name]] <- aov(data.anova[,metric_name] ~ 
    																			 	data.anova[,factor1], 
    																			 data = data.anova)
    	}
      
      factor.x <- factor1
    }
    a.tbl <- lsd.Analysis[[metric_name]]
    # print(a.tbl)
    n.rep <- unique(data.anova$Repetition)
    m.lsd <- summary(a.tbl)[["Error: Within"]][[1]]["Residuals","Mean Sq"]
    # print(m.lsd)
    # m.lsd <- sum(a.tbl$residuals^2)/(nrow(data.anova)-2)
    if (!any(grepl("Method", colnames(data.anova)))){
      data.anova$Method <- rep("PCA", nrow(data.anova))
    }
    lsd.width <- sqrt(m.lsd*2/length(unique(data.anova$Repetition)))*
    	(qt(1-0.025,summary(a.tbl)[["Error: Within"]][[1]]["Residuals","Df"]))
    lsd.plot[[metric_name]] <- lsdfig(data.anova, metric_name, factor.x, factor.color,
                                      lsd.width, col=rgb(0,1,0,0.5), graph.out = graph.out,
                                      ytext= metric_name, xtext= xtext, 
                                      tittext = "")
  }
  return(list(l.plots = lsd.plot, l.aov = lsd.Analysis))
}
