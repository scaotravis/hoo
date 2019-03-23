#' Create rENA Accumulated Model based on Horizon of Observation Algorithm, Utilizing Multicore Computation
#'
#' For multimodal data, this function creates the correct rENA accumulated model that can be used 
#' to create rENA sets for analysis. Specifically, this function utilizes `parallel` package's 
#' mclapply() function. If your computer supports multi-core computation, then using 
#' hoo.mc.ena.accumulate.data() could speed up your computation. 
#' @param data              Multimodal data.frame or data.table
#' @param Units             A vector of Strings describing the Units for ENA model
#' @param Conversation      A vector of Strings describing the Conversations took place in ENA model
#' @param Codes             A vector of Strings entailing the big C Codes of interest for ENA 
#' analysis
#' @param dataModeCol       Name of the column where the types of multimodal data is stored
#' @param modeObserve       Modes of data where actions are observable to all players
#' @param usersCol          Name of the column entailing the unique user tracking info
#' @param windowSize        Size of the moving stanza window, for looking backwards (for whole 
#' conversation, input 1)
#' @param ...               Additional arguments to pass along to rENA ena.accumulate.data method
#' @return     a data frame containing the adjacency vectors of each ENA Units within data
#' @export
#' @examples
#' accum = hoo.mc.ena.accumulate.data(data = mock,
#'                                    Units = c("site", "userName"),
#'                                    Conversation = c("site"),
#'                                    Codes = c("Code1", "Code2", "Code3", "Code4"),
#'                                    dataModeCol = "data",
#'                                    modeObserve = "chat",
#'                                    usersCol = "userName",
#'                                    windowSize = 4)
#'
hoo.mc.ena.accumulate.data = function(data, Units, Conversation, Codes,
                                      dataModeCol, modeObserve,
                                      usersCol,
                                      windowSize, ...)
{
  
  data = as.data.frame(data)
  #options(warn = -1) # used to suppress data.table warning coming from ena.accumulate.data()
  ena_accum = rENA::ena.accumulate.data(units = data.frame(data[, Units]),
                                        conversation = data.frame(data[, Conversation]),
                                        codes = data.frame(data[, Codes]),
                                        window.size.back = windowSize, ...)
  #options(warn = 0)
  hoo_adj = hoo.mc.horizon(data = data,
                           Units = Units, Conversation = Conversation, Codes = Codes,
                           dataModeCol = dataModeCol, modeObserve = modeObserve,
                           usersCol = usersCol,
                           windowSize = windowSize)
  hoo_adj_ordered = hoo_adj[order(match(hoo_adj$Group.1, 
                                        ena_accum$adjacency.vectors.raw$ENA_UNIT)), ]
  rownames(hoo_adj_ordered) = seq_len(nrow(hoo_adj_ordered))
  ena_accum$adjacency.vectors.raw[, (length(Units) + 1):(ncol(ena_accum$adjacency.vectors.raw) - 1)] = 
    hoo_adj_ordered[, 2:(ncol(hoo_adj_ordered))]
  ena_accum$adjacency.vectors = 
    ena_accum$adjacency.vectors.raw[, (length(Units) + 1):(ncol(ena_accum$adjacency.vectors.raw) - 1)]
  return(ena_accum)
  
}
