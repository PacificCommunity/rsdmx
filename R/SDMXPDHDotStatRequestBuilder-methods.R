#' @name SDMXPDHDotStatRequestBuilder
#' @rdname SDMXPDHDotStatRequestBuilder
#' @aliases SDMXPDHDotStatRequestBuilder,SDMXPDHDotStatRequestBuilder-method
#'
#' @usage
#'  SDMXPDHDotStatRequestBuilder(regUrl, repoUrl, accessKey, unsupportedResources,
#'                            skipProviderId, forceProviderId)
#'
#' @param regUrl an object of class "character" giving the base Url of the SDMX
#'        service registry
#' @param repoUrl an object of class "character" giving the base Url of the SDMX
#'        service repository
#' @param accessKey an object of class "character" indicating the name of request parameter for which
#'        an authentication or subscription user key/token has to be provided to perform requests
#' @param unsupportedResources an object of class "list" giving eventual unsupported
#'        REST resources. Default is an empty list object
#' @param skipProviderId an object of class "logical" indicating that the provider
#'        agencyIdshould be skipped. Used to control lack of strong SDMX REST compliance
#'        from data providers. For now, it applies only for the "data" resource.
#' @param forceProviderId an object of class "logical" indicating if the provider
#'        agencyId has to be added at the end of the request. Default value is
#'        \code{FALSE}. For some providers, the \code{all} value for the provider
#'        agency id is not allowed, in this case, the \code{agencyId} of the data
#'        provider has to be forced in the web-request
#'
#' @examples
#'   #how to create a SDMXPDHDotStatRequestBuilder
#'   requestBuilder <- SDMXPDHDotStatRequestBuilder(
#'     regUrl = "http://www.myorg/registry",
#'     repoUrl = "http://www.myorg/repository")
#'
SDMXPDHDotStatRequestBuilder <- function(regUrl, repoUrl, accessKey = NULL,
                                   unsupportedResources = list(),
                                   skipProviderId = FALSE, forceProviderId = FALSE){

  #params formatter
  formatter = list(
    #dataflow
    dataflow = function(obj){return(obj)},
    #datastructure
    datastructure = function(obj){ return(obj)},
    #data
    data = function(obj){return(obj)}
  )

  #resource handler
  handler <- list(

    #'dataflow' resource (path="dataflow/{resourceID}")
    #------------------------------------------------------
    dataflow = function(obj){
      if(is.null(obj@resourceId)) obj@resourceId = "ALL"
      req <- sprintf("%s/dataflow/%s/",obj@regUrl, obj@resourceId)

      #require key
      if(!is.null(accessKey)){
        if(!is.null(obj@accessKey)){
          if(length(grep("\\?",req))==0) req <- paste0(req, "?")
          req <- paste(req, sprintf("%s=%s", accessKey, obj@accessKey), sep = "&")
        }else{
          stop("Requests to this service endpoint requires an API key")
        }
      }

      return(req)
    },

    #'datastructure' resource (path="datastructure/{resourceID}/{agencyID}")
    #--------------------------------------------------------------------------
    datastructure = function(obj){
      if(is.null(obj@resourceId)) obj@resourceId = "all"
      if(is.null(obj@version)) obj@version = "latest"
      req <- sprintf("%s/datastructure/%s",obj@regUrl, obj@resourceId)
      if(forceProviderId) req <- paste(req, obj@providerId, sep = "/")

      #require key
      if(!is.null(accessKey)){
        if(!is.null(obj@accessKey)){
          if(length(grep("\\?",req))==0) req <- paste0(req, "?")
          req <- paste(req, sprintf("%s=%s", accessKey, obj@accessKey), sep = "&")
        }else{
          stop("Requests to this service endpoint requires an API key")
        }
      }

      return(req)
    },

    #'data' resource (path="data/{flowRef}/{key}/{agencyId}")
    #----------------------------------------------------------
    data = function(obj){
      if(is.null(obj@flowRef)) stop("Missing flowRef value")
      if(is.null(obj@key)) obj@key = "all"
      req <- sprintf("%s/data/%s/%s", obj@repoUrl, obj@flowRef, obj@key)
      if(skipProviderId){
        req <- paste0(req, "/")
      }else{
        req <- paste(req, ifelse(forceProviderId, obj@providerId, "all"), sep = "/")
      }

      #DataQuery
      #-> temporal extent (if any)
      addParams = FALSE
      if(!is.null(obj@start)){
        req <- paste0(req, "?")
        addParams = TRUE
        req <- paste0(req, "startPeriod=", obj@start)
      }
      if(!is.null(obj@end)){
        if(!addParams){
          req <- paste0(req, "?")
        }else{
          req <- paste0(req, "&")
        }
        req <- paste0(req, "endPeriod=", obj@end)
      }

      #require key
      if(!is.null(accessKey)){
        if(!is.null(obj@accessKey)){
          if(length(grep("\\?",req))==0) req <- paste0(req, "?")
          req <- paste(req, sprintf("%s=%s", accessKey, obj@accessKey), sep = "&")
        }else{
          stop("Requests to this service endpoint requires an API key")
        }
      }

      return(req)
    }
  )


  new("SDMXPDHDotStatRequestBuilder",
      regUrl = regUrl,
      repoUrl = repoUrl,
      accessKey = accessKey,
      formatter = formatter,
      handler = handler,
      compliant = FALSE,
      unsupportedResources = unsupportedResources)
}
