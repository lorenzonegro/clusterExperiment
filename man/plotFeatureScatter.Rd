% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotFeatureScatter.R
\docType{methods}
\name{plotFeatureScatter}
\alias{plotFeatureScatter}
\alias{plotFeatureScatter,ClusterExperiment,character-method}
\alias{plotFeatureScatter,ClusterExperiment,numeric-method}
\title{Plot scatter plot of feature values colored by cluster}
\usage{
\S4method{plotFeatureScatter}{ClusterExperiment,character}(object,
  features, ...)

\S4method{plotFeatureScatter}{ClusterExperiment,numeric}(object, features,
  whichCluster = "primary", plotUnassigned = TRUE,
  unassignedColor = "grey", missingColor = "white", whichAssay = 1,
  legendLocation = NA, jitterFactor = NA, ...)
}
\arguments{
\item{object}{a ClusterExperiment object}

\item{features}{the indices of the features (either numeric or character 
matching rownames of object) to be plotted.}

\item{...}{arguments passed to \code{\link{boxplot}}}

\item{whichCluster}{argument that can be a single numeric or character value
indicating the \emph{single} clustering to be used. Giving values that result in more than one clustering will result in an error. See details of \code{\link{getClusterIndex}}.}

\item{plotUnassigned}{whether to plot the unassigned samples as a cluster
(either -1 or -2)}

\item{unassignedColor}{If not NULL, should be character value giving the
color for unassigned (-2) samples (overrides \code{clusterLegend}) default.}

\item{missingColor}{If not NULL, should be character value giving the color
for missing (-2) samples (overrides \code{clusterLegend}) default.}

\item{whichAssay}{numeric or character specifying which assay to use. See
\code{\link[SummarizedExperiment]{assay}} for details.}

\item{legendLocation}{character value passed to \code{location} argument of 
\code{plotClusterLegend} indicating where to put the legend. If NA, legend 
will not be plotted.}

\item{jitterFactor}{numeric. If NA, no jittering is done. Otherwise, passed to 
\code{factor} of function \code{\link[base]{jitter}}
 (useful for low counts)}
}
\value{
returns invisibly the results of \code{\link[graphics]{pairs}} or \code{\link[graphics]{plot}} command.
}
\description{
Plot a scatter plot of the (transformed) values for a set of
  gene expression values, colored by cluster
}
\examples{
data(simData)
#Create a ClusterExperiment object
cl <- clusterMany(simData, nReducedDims=c(5, 10, 50), reducedDim="PCA",
   clusterFunction="pam", ks=2:4, findBestK=c(TRUE,FALSE),
   removeSil=c(TRUE,FALSE))
#give names to the clusters
cl<-renameClusters(cl, whichCluster=1, 
   value=letters[1:nClusters(cl)[1]])
plotFeatureScatter(cl,feature=1:2,pch=19,legendLocation="topright")
}
