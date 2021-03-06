#############################################################
#############################################################
############### ClusterFunction Class #####################
#############################################################
#############################################################

#' @title Class ClusterFunction
#'
#' @description \code{ClusterFunction} is a class for holding functions that can
#'   be used for clustering in the clustering algorithms in this package.
#'
#' @docType class
#' @aliases ClusterFunction ClusterFunction-class ClusterFunction
#' @slot clusterFUN a function defining the clustering function. See details for
#'   required arguments.
#' @slot inputType a character defining what type of input \code{clusterFUN}
#'   takes. Must be one of either "diss","X", or "either"
#' @slot algorithmType a character defining what type of clustering algorithm
#'   \code{clusterFUN} is. Must be one of either "01" or "K". \code{clusterFUN}
#'   must take the corresponding required arguments (see details below).
#' @slot classifyFUN a function that takes as input new data and the output of
#'   \code{clusterFUN} (when \code{cluster.only=TRUE}) and results in cluster
#'   assignments of the new data.  Used in
#'   subsampling clustering. Note that the function should assume that the
#'   input 'x' is not the same samples that were input to the ClusterFunction
#'   (but does assume that it is the same number of features/columns).  
#'   If given value \code{NULL} then subsampling type can
#'   only be \code{"InSample"}, see \code{\link{subsampleClustering}}.
#' @slot inputClassifyType the input type for the classification function (if
#'   not NULL); like \code{inputType}, must be one of "diss","X", or "either"
#' @slot outputType the type of output given by \code{clusterFUN}. Must either
#'   be "vector" or "list". If "vector" then the output should be a vector of
#'   length equal to the number of observations   with integer-valued elements
#'   identifying them to different clusters; the vector assignments should be in
#'   the same order as the original input of the data. Samples that are not
#'   assigned to any cluster should be given a '-1' value.  If "list", then it
#'   must be a list equal to the length of the number of clusters, and the
#'   elements of the list contain the indices of the samples in that cluster.
#'   Any indices not in any of the list elements are assumed to be -1. The main
#'   advantage of "list" is that it can preserve the order of the clusters if
#'   the \code{clusterFUN} desires to do so. In which case the \code{orderBy}
#'   argument of \code{\link{mainClustering}} can preserve this ordering
#'   (default is to order by size).
#' @slot requiredArgs Any additional required arguments for \code{clusterFUN}
#'   (beyond those required of all \code{clusterFUN}, described in details).
#' @slot checkFunctions logical. If TRUE, the validity check of the
#'   \code{ClusterFunction} object will check the \code{clusterFUN} with simple
#'   toy data using the function \code{internalFunctionCheck}.
#' @details Required arguments for \code{clusterFUN}: 
#' \itemize{ 
#'	\item{"x or diss"}{either \code{x} and/or \code{diss} must be an argument 
#'		depending on \code{inputType}. If
#'   	\code{x}, then \code{x} is assumed to be nfeatures x nsamples (like
#'   	assay(CEObj) would give)} 
#'  \item{"checkArgs"}{logical argument. If
#'   	\code{checkArgs=TRUE}, the \code{clusterFUN} should check if the arguments
#'   	passed in \code{...} are valid and return an error if not; otherwise, no
#'   	error will be given, but the check should be done and only valid arguments
#'   	in \code{...} passed along. This is necessary for the function to work with
#'   	\code{clusterMany} which passes all arguments to all functions without
#'   	checking. } 
#'	\item{"cluster.only"}{logical argument. If
#'   	\code{cluster.only=TRUE}, then \code{clusterFUN} should return only the
#'   	vector of cluster assignments (or list if \code{outputType="list"}). If
#'   	\code{cluster.only=FALSE} then the \code{clusterFUN} should return a named
#'   	list where one of the elements entitled \code{clustering} contains the
#'   	vector described above (no list!); anything else needed by the
#'   	\code{classifyFUN} to classify new data should be contained in the output
#'   	list as well. \code{cluster.only} is set internally depending on whether
#'   	\code{classifyFUN} will be used by subsampling or only for clustering the
#'   	final product.} 
#'  \item{"..."}{Any additional arguments specific to the
#'   algorithm used by \code{clusterFUN} should be passed via \code{...} and NOT
#'   passed via arguments to \code{clusterFUN}} \item{"Other required
#'   arguments"}{\code{clusterFUN} must also accept arguments required for its
#'   \code{algorithmType} (see Details below).} }
#'
#'
#' @details \code{algorithmType}: Type "01" is for clustering functions that
#'   expect as an input a dissimilarity matrix that takes on 0-1 values (e.g.
#'   from subclustering) with 1 indicating more dissimilarity between samples.
#'   "01" algorithm types must also have \code{inputType} equal to
#'   \code{"diss"}. It is also generally expected that "01" algorithms use the
#'   0-1 nature of the input to set criteria as to where to find clusters. "01"
#'   functions must take as an argument \code{alpha} between 0 and 1 to
#'   determine the clusters, where larger values of \code{alpha} require less
#'   similarity between samples in the same cluster. "K" is for clustering
#'   functions that require an argument \code{k} (the number of clusters), but
#'   arbitrary \code{inputType}.  On the other hand, "K" algorithms are assumed
#'   to need a predetermined 'k' and are also assumed to cluster all samples to
#'   a cluster. If not, the post-processing steps in
#'   \code{\link{mainClustering}} such as \code{findBestK} and \code{removeSil}
#'   may not operate correctly since they rely on silhouette distances.
#' @name ClusterFunction-class
#' @aliases ClusterFunction
#' @rdname ClusterFunction-class
#' @export
#'
setClass(
	Class = "ClusterFunction",
	slots = list(
  	  	clusterFUN="function",
  		inputType = "character",
  		algorithmType = "character",
  		inputClassifyType = "character",
		classifyFUN="functionOrNULL",
		outputType = "character",
		requiredArgs= "character",
		checkFunctions="logical"
  	)
)
.inputTypes<-c("X","diss","either")
.algTypes<-c("01","K")
.required01Args<-c("alpha")
.requiredKArgs<-c("k")
.outputTypes<-c("vector","list")


setValidity("ClusterFunction", function(object) {
    if(is.na(object@outputType)) {
      return("Must define outputType.")
    }
	if(!object@outputType%in%.outputTypes) return(paste("outputType must be one of",paste(.outputTypes,collapse=",")))
    #----
	# inputType
	#----
    if(is.na(object@inputType)) {
      return("Must define inputType.")
    }
	if(!object@inputType%in%.inputTypes) return(paste("inputType must be one of",paste(.inputTypes,collapse=",")))
	if(is.null(object@classifyFUN)& !is.na(object@inputClassifyType)) return("should not define inputClassifyType if classifyFUN is not defined")
    if(!is.null(object@classifyFUN) & is.na(object@inputClassifyType)) {
      return("Must define inputClassifyType if define classifyFUN.")
    }
	if(!is.null(object@classifyFUN) & !object@inputClassifyType%in%.inputTypes) return(paste("inputClassifyType must be one of",paste(.inputTypes,collapse=",")))
    #----
	# algorithmType
	#----
	if(is.na(object@algorithmType)) return("Must define algorithmType")
	if(!object@algorithmType%in%.algTypes) return(paste("algorithmType must be one of",paste(.algTypes,collapse=",")))
	### Add additional checks that 'k' and '01' work as expected... in particular that take particular arguments, etc. that 'k' and '01' are expected to take.


	#----
	# function arguments are as needed
	#----
	if(object@inputType%in%c("X","either") & !.checkHasArgs(FUN=object@clusterFUN,requiredArgs="x")) return("inputType is either 'X' or 'either' but arguments to ClusterFunction doesn't contain 'x'")
		if(object@inputType%in%c("diss","either") & !.checkHasArgs(FUN=object@clusterFUN,requiredArgs="diss")) return("inputType is either 'diss' or 'either' but arguments to ClusterFunction doesn't contain 'diss'")
	if(object@algorithmType=="K" & !.checkHasArgs(FUN=object@clusterFUN,requiredArgs=.requiredKArgs)) return("algorithmType is 'K' but arguments to ClusterFunction doesn't contain",paste(.requiredKArgs,collapse=","))
	if(object@algorithmType=="01" & !.checkHasArgs(FUN=object@clusterFUN, requiredArgs=.required01Args)) return("algorithmType is '01' but arguments to ClusterFunction doesn't contain", paste(.required01Args,collapse=","))


	if(object@checkFunctions){ #user can skip the check.
		out<-internalFunctionCheck(object@clusterFUN,object@inputType,object@algorithmType,object@outputType)
		if(!is.logical(out) || !out) return(out)

	}
	return(TRUE)
  })

#'@description The constructor \code{ClusterFunction} creates an object of the
#'  class \code{ClusterFunction}.
#'
#'@param clusterFUN function passed to slot \code{clusterFUN}.
#'@param inputType character for slot \code{inputType}
#'@param algorithmType character for slot \code{inputType}
#'@param classifyFUN function for slot \code{classifyFUN}
#'@param outputType character for slot \code{outputType}
#'@param inputClassifyType character for slot \code{inputClassifyType}
#'@param requiredArgs character for slot \code{requiredArgs}
#'@param checkFunctions logical for whether to check the input functions with
#'  \code{internalFunctionsCheck}
#'@param ... arguments passed to different methods of \code{ClusterFunction}
#'@return A \code{ClusterFunction} object.
#'
#' @aliases ClusterFunction
#' @rdname ClusterFunction-class
#' @export
setGeneric(
	name = "ClusterFunction",
	def = function(clusterFUN,...) {
	  standardGeneric("ClusterFunction")
	}
)
#' @rdname ClusterFunction-class
#' @export
setMethod(
	f = "ClusterFunction",
	signature = signature("function"),
	definition = function(clusterFUN, inputType,outputType,algorithmType,inputClassifyType=NA_character_,requiredArgs=NA_character_,classifyFUN=NULL,checkFunctions=TRUE){
		out <- new("ClusterFunction",
	         clusterFUN=clusterFUN,
	         inputType=inputType,
	         algorithmType = algorithmType,
			 inputClassifyType=inputClassifyType,
			 classifyFUN=classifyFUN,
			 outputType=outputType,
			 requiredArgs=requiredArgs,
			 checkFunctions=checkFunctions
			 )
		return(out)
	}
)