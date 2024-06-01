////
////  CutOptimizerBeforeTryingToUpdateToOneMaterialAtATime.swift
////  WoodCutting
////
////  Created by Amanada Clouser on 5/29/24.
////
//
//import Foundation
//import Foundation
//
//struct Cut: Identifiable {
//  let id = UUID()
//  let width: Double
//  let length: Double
//  let column: Int
//}
//
//struct Slice: Identifiable {
//  let id = UUID()
//  let sourceMaterialIndex: Int
//  let width: Double
//  let widthKerf: Double
//  let remainingLength: Double
//  var cuts: [Cut]?
//}
//
//struct CuttingPlanOverview: Identifiable {
//  let id = UUID()
//  let totalSourceMaterials: Int
//  let totalRemainingMaterialArea: Double
//  var cuttingPlans: [CuttingPlan]
//}
//
//struct CuttingPlan {
//  let sourceMaterialIndex: Int
//  let slices: [Slice]
//  let remainingMaterialArea: Double
//}
//
//class CutOptimizer {
//  let sourceWidth: Double
//  let sourceLength: Double
//  let cuts: [Cut]
//  let kerf: Double
//  
//  init(sourceWidth: Double, sourceLength: Double, cuts: [Cut], kerf: Double) {
//    self.sourceWidth = sourceWidth
//    self.sourceLength = sourceLength
//    self.cuts = cuts
//    self.kerf = kerf
//  }
//  
//  func optimize() -> [Slice] {
//    var remainingCuts = cuts
//    logRemainingCuts(remainingCuts)
//    var slices: [Slice] = []
//    
//    while remainingCuts.count > 0 {
//      if areAllCutsSameWidth(remainingCuts) {
//        slices.append(contentsOf: handleSameWidthCuts(remainingCuts))
//      } else {
//        slices.append(contentsOf: handleDifferentWidthCuts(remainingCuts))
//      }
//      
//      allocateRemainingCutsToSlices(&slices, remainingCuts: &remainingCuts)
//    }
//    return slices
//  }
//  
//  func allocateRemainingCutsToSlices(_ slices: inout [Slice], remainingCuts: inout [Cut]) {
//    for i in 0..<slices.count {
//      var slice = slices[i]
//      var cutsForSlice: [Cut] = []
//      var remainingLength = slice.remainingLength
//      
//      let cutsWithSameWidth = remainingCuts.filter { $0.width == slice.width }
//      let sortedCuts = cutsWithSameWidth.sorted { $0.length > $1.length }
//      
//      for cut in sortedCuts {
//        if cut.length <= remainingLength {
//          remainingLength -= (cut.length + kerf)
//          cutsForSlice.append(cut)
//          if let index = remainingCuts.firstIndex(where: { $0.id == cut.id }) {
//            remainingCuts.remove(at: index)
//          }
//        }
//        if remainingLength <= 0 {
//          break
//        }
//      }
//      
//      slices[i].cuts = cutsForSlice
//      slices[i].remainingLength = remainingLength
//    }
//  }
//  
//  func handleDifferentWidthCuts(_ cuts: [Cut]) -> [Slice] {
//    var slices: [Slice] = []
//    
//    var widthMap = sortWidthsIntoDictionary(cuts)
//    print("widthMap", widthMap)
//    var totalCount = widthMap.values.reduce(0, +)
//    print("totalCount", totalCount)
//    var sourceMaterialIndex = 0
//    
//    while totalCount > 0 {
//      var remainingWidth = sourceWidth
//      let bestCombination = findBestCombination(for: remainingWidth, in: widthMap)
//      
//      print("bestcomb", bestCombination)
//      for width in bestCombination {
//        remainingWidth -= (width + kerf)
//        widthMap[width]! -= 1
//        slices.append(Slice(sourceMaterialIndex: sourceMaterialIndex, width: width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil))
//      }
//      
//      print("slicesafterbestcomb", slices)
//      print("remainingwidthafterbestcomb", remainingWidth)
//      print("widthmapafterbestcomb", widthMap)
//      
//      while let (width, count) = widthMap.first(where: { $0.value > 0 && $0.key + kerf <= remainingWidth }) {
//        remainingWidth -= (width + kerf)
//        widthMap[width]! -= 1
//        slices.append(Slice(sourceMaterialIndex: sourceMaterialIndex, width: width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil))
//      }
//      
//      sourceMaterialIndex += 1
//      totalCount = widthMap.values.reduce(0, +)
//    }
//    
//    return slices
//  }
//  
//  func findBestCombination(for remainingWidth: Double, in widthMap: [Double: Int]) -> [Double] {
//    var bestCombination: [Double] = []
//    var bestRemainingWidth = remainingWidth
//    
//    func recurse(currentCombination: [Double], currentRemainingWidth: Double, widthMap: [Double: Int]) {
//      if currentRemainingWidth < bestRemainingWidth {
//        bestCombination = currentCombination
//        bestRemainingWidth = currentRemainingWidth
//      }
//      if currentRemainingWidth <= 0 {
//        return
//      }
//      
//      for (width, count) in widthMap {
//        if count > 0 && width + kerf <= currentRemainingWidth {
//          var newWidthMap = widthMap
//          newWidthMap[width]! -= 1
//          
//          var newCombination = currentCombination
//          newCombination.append(width)
//          
//          recurse(currentCombination: newCombination, currentRemainingWidth: currentRemainingWidth - (width + kerf), widthMap: newWidthMap)
//        }
//      }
//    }
//    
//    recurse(currentCombination: [], currentRemainingWidth: remainingWidth, widthMap: widthMap)
//    return bestCombination
//  }
//  
//  func handleSameWidthCuts(_ cuts: [Cut]) -> [Slice] {
//    var slices: [Slice] = []
//    
//    if areAllCutsSameWidthAsSource(cuts) {
//      let totalLengthOfAllCuts = getTotalLengthOfRemainingCutsAndKerf(cuts)
//      let numSourceMaterialsNeeded = Int(ceil(totalLengthOfAllCuts / sourceLength))
//      
//      for i in 0..<numSourceMaterialsNeeded {
//        let slice = Slice(sourceMaterialIndex: i, width: cuts[0].width, widthKerf: 0, remainingLength: sourceLength, cuts: nil)
//        slices.append(slice)
//      }
//    } else if !canMultipleWidthsFitInSourceWidth(cuts) {
//      let totalLengthOfAllCuts = getTotalLengthOfRemainingCutsAndKerf(cuts)
//      let numSourceMaterialsNeeded = Int(ceil(totalLengthOfAllCuts / sourceLength))
//      
//      for i in 0..<numSourceMaterialsNeeded {
//        let slice = Slice(sourceMaterialIndex: i, width: cuts[0].width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil)
//        slices.append(slice)
//      }
//    } else {
//      let totalCutsPerSource = Int(sourceWidth / (cuts[0].width + kerf))
//      let totalLengthOfAllCuts = getTotalLengthOfRemainingCutsAndKerf(cuts)
//      
//      let numSlicesNeeded = Int(ceil(totalLengthOfAllCuts / sourceLength))
//      let totalSourceMaterialsNeeded = Int(ceil(Double(numSlicesNeeded) / Double(totalCutsPerSource)))
//      
//      for i in 0..<totalSourceMaterialsNeeded {
//        for _ in 0..<totalCutsPerSource {
//          if let firstCut = cuts.first {
//            let slice = Slice(sourceMaterialIndex: i, width: firstCut.width, widthKerf: kerf, remainingLength: sourceLength, cuts: nil)
//            slices.append(slice)
//          }
//        }
//      }
//    }
//    
//    return slices
//  }
//  
//  func areAllCutsSameWidth(_ cuts: [Cut]) -> Bool {
//    guard let firstCutWidth = cuts.first?.width else {
//      return true
//    }
//    return cuts.allSatisfy { $0.width == firstCutWidth }
//  }
//  
//  func areAllCutsSameWidthAsSource(_ cuts: [Cut]) -> Bool {
//    return cuts.allSatisfy { $0.width == sourceWidth }
//  }
//  
//  func getTotalLengthOfRemainingCutsAndKerf(_ cuts: [Cut]) -> Double {
//    return cuts.reduce(0) { total, cut in
//      if cut.length == sourceLength {
//        return total + cut.length
//      } else {
//        return total + cut.length + kerf
//      }
//    }
//  }
//  
//  func canMultipleWidthsFitInSourceWidth(_ cuts: [Cut]) -> Bool {
//    guard cuts.count > 1 else { return false }
//    return (cuts[0].width + cuts[1].width + kerf) <= sourceWidth
//  }
//  
//  func sortWidthsIntoDictionary(_ cuts: [Cut]) -> [Double: Int] {
//    var widthMap: [Double: Double] = [:]
//    
//    for cut in cuts {
//      widthMap[cut.width, default: 0] += cut.length
//    }
//    
//    for (width, totalLength) in widthMap {
//      let slicesNeeded = Int(ceil(totalLength / sourceLength))
//      widthMap[width] = Double(slicesNeeded)
//    }
//    
//    return widthMap.mapValues { Int($0) }
//  }
//  
//  private func logRemainingCuts(_ cuts: [Cut]) {
//    print("Remaining Cuts:")
//    for cut in cuts {
//      print(" - Cut: \(cut.width) x \(cut.length)")
//    }
//  }
//}
