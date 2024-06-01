import Foundation

struct Cut: Identifiable, Hashable, Equatable {
  let id = UUID()
  let width: Double
  let length: Double
}

struct Slice: Identifiable {
  let id = UUID()
  let sourceMaterialIndex: Int
  var rowIndex: Int = 0
  let width: Double
  let widthKerf: Double
  var remainingLength: Double
  var cuts: [Cut]?
}

struct CuttingPlanOverview: Identifiable {
  let id = UUID()
  let totalSourceMaterials: Int
  let totalRemainingMaterialArea: Double
  var cuttingPlans: [CuttingPlan]
}

struct CuttingPlan: Identifiable {
  let id = UUID()
  let sourceMaterialIndex: Int
  let slices: [Slice]
  let remainingMaterialArea: Double
}

class CutOptimizer {
  let sourceWidth: Double
  let sourceLength: Double
  let cuts: [Cut]
  let kerf: Double
  var currentSourceMaterialIndex: Int
  var slices: [Slice] = []
  var remainingCuts: [Cut]
  
  init(sourceWidth: Double, sourceLength: Double, cuts: [Cut], kerf: Double) {
    self.sourceWidth = sourceWidth
    self.sourceLength = sourceLength
    self.cuts = cuts
    self.kerf = kerf
    self.currentSourceMaterialIndex = 0
    self.remainingCuts = self.cuts
  }
  
  func optimize() -> CuttingPlanOverview {
    remainingCuts = cuts
    var cuttingPlans: [CuttingPlan] = []
    
    while remainingCuts.count > 0 {
      // Do first round of making vertical slices out of a single source material
      if areAllCutsSameWidth(remainingCuts) {
        slices.append(contentsOf: handleSameWidthCuts(remainingCuts))
      } else {
        slices.append(contentsOf: handleDifferentWidthCuts(remainingCuts))
      }
      
      allocateRemainingCutsToSlices(&slices, remainingCuts: &remainingCuts)
      
      handleRemainingMaterial(&slices, remainingCuts: &remainingCuts)
      
      // Calculate the remaining material area for the current source material
      let remainingMaterialArea = calculateTotalRemainingArea(from: slices.filter { $0.sourceMaterialIndex == currentSourceMaterialIndex })
      
      // Create a cutting plan for the current source material
      let cuttingPlanSlices = slices.filter { $0.sourceMaterialIndex == currentSourceMaterialIndex }
      let cuttingPlan = CuttingPlan(
        sourceMaterialIndex: currentSourceMaterialIndex,
        slices: cuttingPlanSlices,
        remainingMaterialArea: remainingMaterialArea
      )
      
      cuttingPlans.append(cuttingPlan)
      
      currentSourceMaterialIndex += 1
    }
    
    // Calculate the total remaining material area for all source materials
    let totalRemainingMaterialArea = cuttingPlans.reduce(0) { $0 + $1.remainingMaterialArea }
    
    // Create and return the CuttingPlanOverview
    let cuttingPlanOverview = CuttingPlanOverview(
      totalSourceMaterials: currentSourceMaterialIndex,
      totalRemainingMaterialArea: totalRemainingMaterialArea,
      cuttingPlans: cuttingPlans
    )
    
    return cuttingPlanOverview
  }
  
  func handleRemainingMaterial(_ slices: inout [Slice], remainingCuts: inout [Cut]) {
    var cutsAllocatedToPreviousRow = false
    var nextRowIndex = 1
    
    repeat {
      cutsAllocatedToPreviousRow = false
      
      // Calculate total remaining area
      let totalRemainingArea = calculateTotalRemainingArea(from: slices.filter { $0.sourceMaterialIndex == currentSourceMaterialIndex })
    
      // Check if any of the remaining cuts can fit in the remaining area
      if canAnyCutFitInRemainingArea(remainingCuts, totalRemainingArea) {
        let totalRemainingWidth = sourceWidth - slices.reduce(0) { $0 + $1.width + $1.widthKerf }
        if totalRemainingWidth > 0 {
          slices.append(Slice(sourceMaterialIndex: currentSourceMaterialIndex, rowIndex: 0, width: totalRemainingWidth, widthKerf: 0, remainingLength: sourceLength, cuts: nil))
        }
        
        // Make potential cuts only be cuts that could potentially fit in the total remaining area
        var potentialCuts = remainingCuts.filter { $0.width * $0.length <= totalRemainingArea }
        
        // Set remaining length to 0 in the current slices and make new slices
        var newSlices: [Slice] = []
        for i in 0..<slices.count where slices[i].sourceMaterialIndex == currentSourceMaterialIndex && slices[i].rowIndex == 0 {
          let slice = slices[i]
          let newSlice = Slice(sourceMaterialIndex: slice.sourceMaterialIndex, rowIndex: nextRowIndex, width: slice.width, widthKerf: slice.widthKerf, remainingLength: slice.remainingLength, cuts: [])
          slices[i].remainingLength = 0
          newSlices.append(newSlice)
        }
        slices.append(contentsOf: newSlices)
        
        // Order all the current slices with the new row index by descending remaining length
        slices.sort { $0.remainingLength > $1.remainingLength }
        
        // Combine slices that have the same remaining length by adding the width+kerf together (excluding the final kerf)
        var sliceMap: [Double: Slice] = [:]
        for slice in slices where slice.sourceMaterialIndex == currentSourceMaterialIndex && slice.rowIndex == nextRowIndex {
          if let existingSlice = sliceMap[slice.remainingLength] {
            let combinedWidth = existingSlice.width + existingSlice.widthKerf + slice.width
            sliceMap[slice.remainingLength] = Slice(sourceMaterialIndex: existingSlice.sourceMaterialIndex, rowIndex: existingSlice.rowIndex, width: combinedWidth - slice.widthKerf, widthKerf: slice.widthKerf, remainingLength: existingSlice.remainingLength, cuts: existingSlice.cuts)
          } else {
            sliceMap[slice.remainingLength] = slice
          }
        }
        
        slices = slices.filter { $0.sourceMaterialIndex != currentSourceMaterialIndex || $0.rowIndex != nextRowIndex }
        slices.append(contentsOf: sliceMap.values)
        
        // Check if any potential cuts fit into the slices from the new row and split slices accordingly
        for cut in potentialCuts {
          for i in 0..<slices.count where slices[i].sourceMaterialIndex == currentSourceMaterialIndex && slices[i].rowIndex == nextRowIndex {
            if cut.width <= slices[i].width && cut.length <= slices[i].remainingLength {
              let newWidth = slices[i].width - cut.width - slices[i].widthKerf
              slices[i].remainingLength -= (cut.length + kerf)
              if slices[i].cuts == nil {
                slices[i].cuts = []
              }
              slices[i].cuts?.append(cut)
              
              if let index = remainingCuts.firstIndex(where: { $0.id == cut.id }) {
                remainingCuts.remove(at: index)
              }
              
              // Add a new slice with the remaining width
              if newWidth > 0 {
                slices.append(Slice(sourceMaterialIndex: currentSourceMaterialIndex, rowIndex: nextRowIndex, width: newWidth, widthKerf: slices[i].widthKerf, remainingLength: slices[i].remainingLength, cuts: nil))
              }
              
              cutsAllocatedToPreviousRow = true
            }
          }
        }
        
        // Allocate remaining cuts to the slices
        allocateRemainingCutsToSlices(&slices, remainingCuts: &potentialCuts)
      }
      
      nextRowIndex += 1
    } while canAnyCutFitInRemainingArea(remainingCuts, calculateTotalRemainingArea(from: slices.filter { $0.sourceMaterialIndex == currentSourceMaterialIndex })) && cutsAllocatedToPreviousRow
  }
  
  func calculateTotalRemainingArea(from slices: [Slice]) -> Double {
    let totalRemainingWidth = sourceWidth - slices.reduce(0) { $0 + $1.width + $1.widthKerf }
    
    // Calculate the remaining area for each slice based on its remaining length and width
    let remainingAreas = slices.map { ($0.width + $0.widthKerf) * $0.remainingLength }
    
    // Sum up all the remaining areas
    let totalRemainingArea = remainingAreas.reduce(0, +) + (totalRemainingWidth * sourceLength)
    
    return totalRemainingArea
  }
  
  func canAnyCutFitInRemainingArea(_ cuts: [Cut], _ remainingArea: Double) -> Bool {
    return cuts.contains { $0.width * $0.length <= remainingArea }
  }
  
  func allocateRemainingCutsToSlices(_ slices: inout [Slice], remainingCuts: inout [Cut]) {
    for i in 0..<slices.count {
      var slice = slices[i]
      var cutsForSlice: [Cut] = slice.cuts ?? [] // Initialize with existing cuts if any
      var remainingLength = slice.remainingLength
      
      let cutsWithSameWidth = remainingCuts.filter { $0.width == slice.width }
      let sortedCuts = cutsWithSameWidth.sorted { $0.length > $1.length }
      
      for cut in sortedCuts {
        if cut.length <= (remainingLength - kerf) || (cut.length == sourceLength && remainingLength == sourceLength) {
          remainingLength -= (cut.length + kerf)
          cutsForSlice.append(cut)
          if let index = remainingCuts.firstIndex(where: { $0.id == cut.id }) {
            remainingCuts.remove(at: index)
          }
        }
        if remainingLength <= 0 {
          break
        }
      }
      
      slices[i].cuts = cutsForSlice
      slices[i].remainingLength = remainingLength
    }
  }
  
  func handleDifferentWidthCuts(_ cuts: [Cut]) -> [Slice] {
    var slices: [Slice] = []
    
    var widthMap = sortWidthsIntoDictionary(cuts)
    var totalCount = widthMap.values.reduce(0, +)
    
    var remainingWidth = sourceWidth
    let bestCombination = findBestCombination(for: remainingWidth, in: widthMap)
    
    for width in bestCombination {
      remainingWidth -= (width + kerf)
      widthMap[width]! -= 1
      slices.append(Slice(sourceMaterialIndex: currentSourceMaterialIndex, width: width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil))
    }
    
    while let (width, count) = widthMap.first(where: { $0.value > 0 && $0.key + kerf <= remainingWidth }) {
      remainingWidth -= (width + kerf)
      widthMap[width]! -= 1
      slices.append(Slice(sourceMaterialIndex: currentSourceMaterialIndex, width: width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil))
    }
    
    return slices
  }
  
  func findBestCombination(for remainingWidth: Double, in widthMap: [Double: Int]) -> [Double] {
    var bestCombination: [Double] = []
    var bestRemainingWidth = remainingWidth
    
    func recurse(currentCombination: [Double], currentRemainingWidth: Double, widthMap: [Double: Int]) {
      if currentRemainingWidth < bestRemainingWidth {
        bestCombination = currentCombination
        bestRemainingWidth = currentRemainingWidth
      }
      if currentRemainingWidth <= 0 {
        return
      }
      
      for (width, count) in widthMap {
        if count > 0 && width + kerf <= currentRemainingWidth {
          var newWidthMap = widthMap
          newWidthMap[width]! -= 1
          
          var newCombination = currentCombination
          newCombination.append(width)
          
          recurse(currentCombination: newCombination, currentRemainingWidth: currentRemainingWidth - (width + kerf), widthMap: newWidthMap)
        }
      }
    }
    
    recurse(currentCombination: [], currentRemainingWidth: remainingWidth, widthMap: widthMap)
    return bestCombination
  }
  
  func handleSameWidthCuts(_ cuts: [Cut]) -> [Slice] {
    var slices: [Slice] = []
    
    if areAllCutsSameWidthAsSource(cuts) {
      let slice = Slice(sourceMaterialIndex: currentSourceMaterialIndex, width: cuts[0].width, widthKerf: 0, remainingLength: sourceLength, cuts: nil)
      slices.append(slice)
    } else if !canMultipleWidthsFitInSourceWidth(cuts) {
      let slice = Slice(sourceMaterialIndex: currentSourceMaterialIndex, width: cuts[0].width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil)
      slices.append(slice)
    } else {
      let totalCutsPerSource = Int(sourceWidth / (cuts[0].width + kerf))
      
      let totalLengthOfAllCuts = getTotalLengthOfRemainingCutsAndKerf(cuts)
      
      let totalSlicesNeeded = Int(ceil(totalLengthOfAllCuts / sourceLength))
      
      var numSlicesForThisMaterial = totalCutsPerSource
      if totalCutsPerSource > totalSlicesNeeded {
        numSlicesForThisMaterial = totalSlicesNeeded
      }
      
      for _ in 0..<numSlicesForThisMaterial {
        if let firstCut = cuts.first {
          let slice = Slice(sourceMaterialIndex: currentSourceMaterialIndex, width: firstCut.width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil)
          slices.append(slice)
        }
      }
    }
    
    return slices
  }
  
  func areAllCutsSameWidth(_ cuts: [Cut]) -> Bool {
    guard let firstCutWidth = cuts.first?.width else {
      return true
    }
    return cuts.allSatisfy { $0.width == firstCutWidth }
  }
  
  func areAllCutsSameWidthAsSource(_ cuts: [Cut]) -> Bool {
    return cuts.allSatisfy { $0.width == sourceWidth }
  }
  
  func getTotalLengthOfRemainingCutsAndKerf(_ cuts: [Cut]) -> Double {
    return cuts.reduce(0) { total, cut in
      if cut.length == sourceLength {
        return total + cut.length
      } else {
        return total + cut.length + kerf
      }
    }
  }
  
  func canMultipleWidthsFitInSourceWidth(_ cuts: [Cut]) -> Bool {
    guard cuts.count > 1 else { return false }
    return (cuts[0].width + cuts[1].width + kerf) <= sourceWidth
  }
  
  func sortWidthsIntoDictionary(_ cuts: [Cut]) -> [Double: Int] {
    var widthMap: [Double: Double] = [:]
    
    for cut in cuts {
      widthMap[cut.width, default: 0] += cut.length
    }
    
    for (width, totalLength) in widthMap {
      let slicesNeeded = Int(ceil(totalLength / sourceLength))
      widthMap[width] = Double(slicesNeeded)
    }
    
    return widthMap.mapValues { Int($0) }
  }
}
