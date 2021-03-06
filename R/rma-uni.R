#-------------------------------------
# vcovCR with defaults
#-------------------------------------

#' Cluster-robust variance-covariance matrix for a rma.uni object.
#' 
#' \code{vcovCR} returns a sandwich estimate of the variance-covariance matrix 
#' of a set of regression coefficient estimates from a 
#' \code{\link[metafor]{rma.uni}} object.
#' 
#' @param cluster Expression or vector indicating which observations 
#'   belong to the same cluster. Required for \code{rma.uni} objects.
#' @param target Optional matrix or vector describing the working 
#'   variance-covariance model used to calculate the \code{CR2} and \code{CR4} 
#'   adjustment matrices. If not specified, the target is taken to be diagonal
#'   with entries equal to the estimated marginal variance of the effect sizes. 
#' @inheritParams vcovCR
#'   
#' @return An object of class \code{c("vcovCR","clubSandwich")}, which consists 
#'   of a matrix of the estimated variance of and covariances between the 
#'   regression coefficient estimates.
#'   
#' @seealso \code{\link{vcovCR}}
#'   
#' @export
#' 
#' @examples
#' library(metafor)
#' data(corrdat, package = "robumeta")
#' 
#' mfor_fit <- rma.uni(effectsize ~ males + college + binge,
#'                      vi = var, data = corrdat, method = "FE")
#' mfor_fit
#' mfor_CR2 <- vcovCR(mfor_fit, type = "CR2", cluster = corrdat$studyid)
#' mfor_CR2
#' coef_test(mfor_fit, vcov = mfor_CR2, test = c("Satterthwaite", "saddlepoint"))
#' Wald_test(mfor_fit, constraints = 2:4, vcov = mfor_CR2)
#' 


vcovCR.rma.uni <- function(obj, cluster, type, target, inverse_var) {
  if (missing(cluster)) stop("You must specify a clustering variable.")
  if (missing(target)) {
    target <- NULL
    if (missing(inverse_var)) inverse_var <- is.null(obj$weights) & obj$weighted
  } else {
    if (missing(inverse_var)) inverse_var <- FALSE
  }
  vcov_CR(obj, cluster = cluster, type = type, target = target, inverse_var = inverse_var)
}

# coef()
# residuals_CR()
# vcov()
# model_matrix()

#-------------------------------------
# Get (model-based) working variance matrix 
#-------------------------------------

targetVariance.rma.uni <- function(obj) {
  obj$vi + obj$tau2
}

#-------------------------------------
# Get weighting matrix
#-------------------------------------

weightMatrix.rma.uni <- function(obj) {
  if (obj$weighted) {
    if (is.null(obj$weights)) {
      wi <- 1 / (obj$vi + obj$tau2)  
    } else {
      wi <- obj$weights
    }
  } else {
    wi <- rep(1, obj$k)
  }
  wi
}
