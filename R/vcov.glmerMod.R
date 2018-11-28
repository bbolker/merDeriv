vcov.glmerMod <- function(object, ...) {
  dotdotdot <- list(...)
  if("full" %in% names(dotdotdot)){
    full <- dotdotdot$full
  } else {
    full <- FALSE
  }
  
  if (full == FALSE) {
    full_vcov <- vcov(object)
  } else {
    ## Hessian was based on deviance function, which is the 
    ## -2*LogLik. That's why divided by -2
    full_vcov_noorder <- -solve(object@optinfo$derivs$Hessian/(-2))
  
    ## Block order in Hessian was theta, beta. Reorganize to 
    ## put fixed parameter block first to match with score 
    ## matrix order.
  
    ## count parameter numbers
    p <- nrow(full_vcov_noorder)
    pfix <- length(object@beta)
    pran <- length(object@theta)
    ## reorder four blocks
    full_vcov <- matrix(NA, nrow(full_vcov_noorder), ncol(full_vcov_noorder))
    full_vcov[1:pfix, 1:pfix] <- full_vcov_noorder[(pran + 1):p, (pran + 1):p]
    full_vcov[(pfix + 1):p, (pfix + 1): p] <- full_vcov_noorder[1:pran, 1:pran]
    full_vcov[(pfix + 1):p, 1:pfix] <- full_vcov_noorder[1:pran, (pran + 1): p]
    full_vcov[1:pfix, (pfix + 1): p] <- full_vcov_noorder[(pran + 1): p, 1:pran]
    
    ## name the matrix
    parts <- getME(object, c("fixef", "theta"))
    colnames(full_vcov) <- c(names(parts$fixef), paste("cov",
                                                         names(parts$theta), sep="_"))
  }
  return(full_vcov)
}
