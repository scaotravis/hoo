#' Horizon of Observation Analysis for Multimodal Data
#'
#' For multimodal data, players might not fully observe other player's actions. This function takes such factor into account and return the adjacency matrix for the actions players can observe.
#' @param data              The original data containing the multimodal data (input a data frame or a data table)
#' @param Units             ENA Units used on the original data (need to input a character string or a vector of character strings)
#' @param Conversation      ENA Conversations within the original data (need to input a character string or a vector of character strings)
#' @param Codes             Big C Codes used in the original data (need to input a character string or a vector of character strings)
#' @param dataModeCol       Name of the column where the types of multimodal data is stored (need to input a character string)
#' @param modeObserve       Name of the mode of data where other players can observe their actions (need to input a character string or a vector of character strings)
#' @param usersCol          Name of the column where usernames or userid (something to distinguish players in the game) is stored (need to input a character string)
#' @param windowSize        Size of the moving stanza window, for looking backwards (need to input a numeric value; for whole conversation, input 1)
#' @return     a data frame containing the adjacency vectors of each ENA Units within your data
#' @export
#' @examples
#' adj = horizon(data = mock, 
#'               Units = c("site", "userName"), 
#'               Conversation = c("site"), 
#'               Codes = c("Code1", "Code2", "Code3", "Code4"), 
#'               dataModeCol = "data", 
#'               modeObserve = "chat", 
#'               usersCol = "userName", 
#'               windowSize = 4)
#'
horizon = function(data, Units, Conversation, Codes, 
                   dataModeCol, modeObserve, 
                   usersCol, 
                   windowSize)
{
  data = as.data.frame(data)
  if (all(Units %in% colnames(data)) == T) {
    if (length(Units) == 1) {
      data$enaunits = data[, Units]
    }
    if (length(Units) == 2) {
      data$enaunits = paste(data[, Units[1]], data[, Units[2]], sep = ".")
    }
    if (length(Units) > 2) {
      data$enaunits = paste(data[, Units[1]], data[, Units[2]], sep = ".")
      for (i in 3:length(Units)) {
        data$enaunits = paste(data$enaunits, data[, Units[i]], sep = ".")
      }
    }
  } else {
    stop("ERROR: The Units specified are not valid. At least one Unit is needed. Check your spelling if needed.")
  }
  if (all(Conversation %in% colnames(data)) == T) {
    levelsWithinConv = list()
    combinations = data.frame()
    for (i in seq_len(length(Conversation))) {
      levelsWithinConv[[i]] = unique(data[[Conversation[i]]])
      combinations = tidyr::crossing(combinations, levelsWithinConv[[i]])
    }
    combinations = data.frame(lapply(combinations, as.character), stringsAsFactors = F)
  } else {
    stop("ERROR: The Conversation specified are not valid. At least one Conversation is needed. Check your spelling if needed.")
  }
  data$rowid = 1:nrow(data)
  dataSubset = data[, c("rowid", "enaunits", usersCol, dataModeCol, Codes)]
  adjDF = data.frame(matrix(nrow = 0, ncol = choose(n = length(Codes), k = 2) + 1))
  for (r in seq_len(nrow(combinations))) { # Account for Conversations
    rowsCriteria = list()
    for (c in seq_len(length(Conversation))) {
      rowsCriteria[[c]] = which(data[[Conversation[c]]] %in% combinations[r, c])
      if (c == 1) {
        rowsWithinConversation = rowsCriteria[[c]]
      } else {
        rowsWithinConversation = base::intersect(rowsWithinConversation, rowsCriteria[[c]])
      }
    }
    if (length(rowsWithinConversation) == 0) {
      next
    } else {
      dataConvSubset = dataSubset[rowsWithinConversation, ]
      dataConvSubset$rowid = 1:nrow(dataConvSubset)
      adjDFWithinOneConv = data.frame(matrix(nrow = nrow(dataConvSubset), ncol = choose(n = length(Codes), k = 2) + 1))
      adjDFWithinOneConv[, 1] = dataConvSubset[, "enaunits"]
      for (i in seq_len(nrow(dataConvSubset))) {
        # Obtain the correct stanza window for adj vector calculation
        person = dataConvSubset[i, usersCol]
        rowsSubset = dataConvSubset[dataConvSubset[[usersCol]] == person | dataConvSubset[[dataModeCol]] %in% modeObserve, ]
        currentLine = which(rowsSubset$rowid == i)
        window = windowSize
        while (currentLine - window < 0) {
          window = window - 1
        }
        startRow = currentLine - window + 1
        endRow = currentLine
        adjSubset = rowsSubset[startRow:endRow, 5:ncol(rowsSubset)]
        # Calculate the cross product including this row
        currentRowColSums = as.vector(colSums(adjSubset))
        currentRowCrossProd = as.matrix(tcrossprod(currentRowColSums))
        currentRowConnections = currentRowCrossProd[col(currentRowCrossProd) - row(currentRowCrossProd) > 0]
        # Calculate the cross product excluding this row
        if (windowSize != 1) {
          if (nrow(adjSubset) - 1 != 0) {
            endRowPrev = nrow(adjSubset) - 1
            previousRowColSums = as.vector(colSums(adjSubset[1:endRowPrev, ]))
            previousRowCrossProd = as.matrix(tcrossprod(previousRowColSums))
            previousRowConnections = previousRowCrossProd[col(previousRowCrossProd) - row(previousRowCrossProd) > 0]
          } else {
            previousRowConnections = vector(mode = "numeric", length = choose(n = length(Codes), k = 2))
          }
        } else {
          previousRowConnections = vector(mode = "numeric", length = choose(n = length(Codes), k = 2))
        }
        # Calculate the adj vector of this row, and assign it to the data frame that stores adj vectors
        adjVector = currentRowConnections - previousRowConnections
        adjDFWithinOneConv[i, 2:(choose(n = length(Codes), k = 2) + 1)] = adjVector
      }
      adjDF = rbind(adjDF, adjDFWithinOneConv)
    }
  }
  adjDFAccum = stats::aggregate(x = adjDF[, -1], by = list(adjDF$X1), FUN = sum)
  return(adjDFAccum)
}
