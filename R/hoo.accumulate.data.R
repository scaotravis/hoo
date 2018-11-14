#' Create rENA Accumulated Model based on Horizon of Observation Algorithm
#'
#' For multimodal data, this function creates the correct rENA accumulated model that can be used to create rENA sets for analysis. 
#' @param data              The original data containing the multimodal data (input a data frame or a data table)
#' @param Units             ENA Units used on the original data (need to input a character string or a vector of character strings)
#' @param Conversation      ENA Conversations within the original data (need to input a character string or a vector of character strings)
#' @param Codes             Big C Codes used in the original data (need to input a character string or a vector of character strings)
#' @param dataModeCol       Name of the column where the types of multimodal data is stored (need to input a character string)
#' @param modeObserve       Name of the mode of data where other players can observe their actions (need to input a character string or a vector of character strings)
#' @param usersCol          Name of the column where usernames or userid (something to distinguish players in the game) is stored (need to input a character string)
#' @param windowSize        Size of the moving stanza window, for looking backwards (need to input a numeric value; for whole conversation, input 1)
#' @param ...               Additional arguments to pass onto ena.accumulate.data function
#' @return     a data frame containing the adjacency vectors of each ENA Units within your data
#' @export
#' @examples
#' accum = hoo.accumulate.data(data = mock, 
#'                             Units = c("site", "userName"), 
#'                             Conversation = c("site"), 
#'                             Codes = c("Code1", "Code2", "Code3", "Code4"), 
#'                             dataModeCol = "data", 
#'                             modeObserve = "chat", 
#'                             usersCol = "userName", 
#'                             windowSize = 4)
#'
hoo.accumulate.data = function(data, Units, Conversation, Codes, 
                               dataModeCol, modeObserve,
                               usersCol, 
                               windowSize, ...)
{
  data = as.data.frame(data)
  ena_accum = rENA::ena.accumulate.data(units = data.frame(data[, Units]), 
                                        conversation = data.frame(data[, Conversation]), 
                                        codes = data.frame(data[, Codes]), 
                                        window.size.back = windowSize, ...)
  hoo_adj = horizon(data = data, 
                    Units = Units, Conversation = Conversation, Codes = Codes, 
                    dataModeCol = dataModeCol, modeObserve = modeObserve, 
                    usersCol = usersCol, 
                    windowSize = windowSize)
  hoo_adj_ordered = hoo_adj[order(match(hoo_adj$Group.1, ena_accum$adjacency.vectors.raw$ENA_UNIT)), ]
  rownames(hoo_adj_ordered) = 1:nrow(hoo_adj_ordered)
  ena_accum$adjacency.vectors.raw[, (length(Units) + 2):(ncol(ena_accum$adjacency.vectors.raw) - 1)] = hoo_adj_ordered[, 2:(ncol(hoo_adj_ordered))]
  ena_accum$adjacency.vectors = ena_accum$adjacency.vectors.raw[, (length(Units) + 2):(ncol(ena_accum$adjacency.vectors.raw) - 1)]
  return(ena_accum)
}