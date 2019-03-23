#' Horizon of Observation Analysis for Multimodal Data
#'
#' For multimodal data, players might not fully observe other player's actions. This function takes
#' such factor into account and return the adjacency matrix for the actions players can observe.
#' @param data              Multimodal data.frame or data.table
#' @param Units             A vector of Strings describing the Units for ENA model
#' @param Conversation      A vector of Strings describing the Conversations took place in ENA model
#' @param Codes             A vector of Strings entailing the big C Codes of interest for ENA
#' analysis
#' @param dataModeCol       Name of the column where the types of multimodal data is stored
#' @param modeObserve       Modes of data where actions are observable to all players
#' @param usersCol          Name of the column entailing the unique user tracking info
#' @param windowSizeBack    Size of the moving stanza window, for looking backwards (for whole
#' conversation, input 1)
#' @return     a data frame containing the adjacency vectors of each ENA Units within data
#' @export
#' @examples
#' adj = hoo.horizon(data = mock,
#'                   Units = c("site", "userName"),
#'                   Conversation = c("site"),
#'                   Codes = c("Code1", "Code2", "Code3", "Code4"),
#'                   dataModeCol = "data",
#'                   modeObserve = "chat",
#'                   usersCol = "userName",
#'                   windowSizeBack = 4)
#'
hoo.horizon = function(data, Units, Conversation, Codes,
                       dataModeCol, modeObserve,
                       usersCol,
                       windowSizeBack)
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
    stop("ERROR: The Units specified are not valid. Check your spelling if needed.")
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
    stop("ERROR: The Conversation specified are not valid. Check your spelling if needed.")
  }
  
  data$rowid = 0
  dataSubset = data[, c("rowid", "enaunits", usersCol, dataModeCol, Codes)]
  dataSubset = data.table::data.table(dataSubset)
  adj = data.table::data.table()
  rowidToAdd = 0
  
  for (r in seq_len(nrow(combinations))) {
    for (c in seq_len(length(Conversation))) {
      rowsWithinConversation = which(data[[Conversation[c]]] %in% combinations[r, c])
      if (length(rowsWithinConversation) != 0) {
        dataConvSubset = dataSubset[rowsWithinConversation, ]
        dataConvSubset$rowid = seq_len(nrow(dataConvSubset))
        adjRow = dataConvSubset[, {
          unitsWithin = as.vector(t(.SD[, enaunits]))
          eachRow = lapply(seq_len(length(unitsWithin)), function(i) {
            personSubset = .SD[which(.SD[, enaunits] == unitsWithin[i] 
                                     | .SD[[dataModeCol]] %in% modeObserve)]
            currentLine = base::which(personSubset$rowid == i)
            currentENAUnit = personSubset[currentLine, enaunits]
            window = windowSizeBack
            while (currentLine - window < 0) {
              window = window - 1
            }
            startRow = currentLine - window + 1
            endRow = currentLine
            adjRowsToCalculate = personSubset[startRow:endRow, 5:ncol(personSubset), with=F]
            # Calculate the cross product including this row
            currentRowColSums = as.vector(colSums(adjRowsToCalculate))
            currentRowCrossProd = as.matrix(tcrossprod(currentRowColSums))
            currentRowConnections = currentRowCrossProd[col(currentRowCrossProd) 
                                                        - row(currentRowCrossProd) > 0]
            # Calculate the cross product excluding this row
            if (windowSizeBack != 1) {
              if (nrow(adjRowsToCalculate) - 1 != 0) {
                endRowPrev = nrow(adjRowsToCalculate) - 1
                previousRowColSums = as.vector(colSums(adjRowsToCalculate[1:endRowPrev]))
                previousRowCrossProd = as.matrix(tcrossprod(previousRowColSums))
                previousRowConnections = previousRowCrossProd[col(previousRowCrossProd) 
                                                              - row(previousRowCrossProd) > 0]
              } else {
                previousRowConnections = vector(mode = "numeric", 
                                                length = choose(n = length(Codes), k = 2))
              }
            } else {
              previousRowConnections = vector(mode = "numeric", 
                                              length = choose(n = length(Codes), k = 2))
            }
            # Calculate the adj vector of this row
            adjVector = currentRowConnections - previousRowConnections
            append(currentENAUnit, adjVector, )
          })
          binded = data.table::data.table(t(data.table::rbindlist(list(eachRow))))
          cols = colnames(binded)
          cols = cols[2:length(cols)]
          binded[, (cols) := lapply(.SD, as.numeric), .SDcols = cols]
        }]
      } else {
        adjRow = data.table::data.table()
      }
      adj = data.table::rbindlist(list(adj, adjRow))
    }
  }
  
  adjAccum = stats::aggregate(x = adj[, -1], by = list(adj$V1), FUN = sum)
  return(adjAccum)
  
}
