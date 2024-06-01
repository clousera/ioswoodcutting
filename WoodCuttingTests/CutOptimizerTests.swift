import XCTest
@testable import WoodCutting

struct CutIdentifier: Hashable {
  let width: Double
  let length: Double
}


class CutOptimizerTests: XCTestCase {
  
  func testAreAllCutsSameWidth_ShouldReturnTrue() {
    // Arrange
    let cuts = [
      Cut(width: 2.0, length: 4.0),
      Cut(width: 2.0, length: 5.0),
      Cut(width: 2.0, length: 6.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 10.0, cuts: cuts, kerf: 0.125)
    
    // Act
    let result = optimizer.areAllCutsSameWidth(cuts)
    
    // Assert
    XCTAssertTrue(result, "Expected all cuts to have the same width")
  }
  
  func testAreAllCutsSameWidth_ShouldReturnFalse() {
    // Arrange
    let cuts = [
      Cut(width: 2.0, length: 4.0),
      Cut(width: 3.0, length: 5.0),
      Cut(width: 2.0, length: 6.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 10.0, cuts: cuts, kerf: 0.125)
    
    // Act
    let result = optimizer.areAllCutsSameWidth(cuts)
    
    // Assert
    XCTAssertFalse(result, "Expected not all cuts to have the same width")
  }
  
  func testAreAllCutsSameWidthAsSource_ShouldReturnTrue() {
    // Arrange
    let cuts = [
      Cut(width: 3.0, length: 4.0),
      Cut(width: 3.0, length: 5.0),
      Cut(width: 3.0, length: 6.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 10.0, cuts: cuts, kerf: 0.125)
    
    // Act
    let result = optimizer.areAllCutsSameWidthAsSource(cuts)
    
    // Assert
    XCTAssertTrue(result, "Expected all cuts to have the same width as the source material")
  }
  
  func testAreAllCutsSameWidthAsSource_ShouldReturnFalse() {
    // Arrange
    let cuts = [
      Cut(width: 3.0, length: 4.0),
      Cut(width: 2.0, length: 5.0),
      Cut(width: 3.0, length: 6.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 10.0, cuts: cuts, kerf: 0.125)
    
    // Act
    let result = optimizer.areAllCutsSameWidthAsSource(cuts)
    
    // Assert
    XCTAssertFalse(result, "Expected not all cuts to have the same width as the source material")
  }
  
  func testGetTotalLengthOfRemainingCutsAndKerf_SingleCutLessThanSourceLength() {
    let cuts = [Cut(width: 3.0, length: 2.0)]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    
    let totalLength = optimizer.getTotalLengthOfRemainingCutsAndKerf(cuts)
    
    XCTAssertEqual(totalLength, 2.125)
  }
  
  func testGetTotalLengthOfRemainingCutsAndKerf_SingleCutEqualToSourceLength() {
    let cuts = [Cut(width: 3.0, length: 3.0)]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    
    let totalLength = optimizer.getTotalLengthOfRemainingCutsAndKerf(cuts)
    
    XCTAssertEqual(totalLength, 3.0)
  }
  
  func testGetTotalLengthOfRemainingCutsAndKerf_MultipleCutsGreaterThanSourceLength() {
    let cuts = [Cut(width: 3.0, length: 2.0),
                Cut(width: 3.0, length: 3.0),
                Cut(width: 3.0, length: 2.0)]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    
    let totalLength = optimizer.getTotalLengthOfRemainingCutsAndKerf(cuts)
    
    XCTAssertEqual(totalLength, 7.25)
  }
  
  func testGetTotalLengthOfRemainingCutsAndKerf_AllCutsEqualToSourceLength() {
    let cuts = [Cut(width: 3.0, length: 3.0),
                Cut(width: 3.0, length: 3.0),
                Cut(width: 3.0, length: 3.0)]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    
    let totalLength = optimizer.getTotalLengthOfRemainingCutsAndKerf(cuts)
    
    XCTAssertEqual(totalLength, 9.0)
  }
  
  func testCanMultipleWidthsFitInSourceWidth_AllFit() {
    let cuts = [
      Cut(width: 1.0, length: 3.0),
      Cut(width: 1.0, length: 3.0),
      Cut(width: 1.0, length: 3.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 4.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    XCTAssertTrue(optimizer.canMultipleWidthsFitInSourceWidth(cuts))
  }
  
  func testCanMultipleWidthsFitInSourceWidth_False() {
    let cuts = [
      Cut(width: 2.0, length: 3.0),
      Cut(width: 2.0, length: 3.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    XCTAssertFalse(optimizer.canMultipleWidthsFitInSourceWidth(cuts))
  }
  
  func testCanMultipleWidthsFitInSourceWidth_SomeFit() {
    let cuts = [
      Cut(width: 1.5, length: 3.0),
      Cut(width: 1.5, length: 3.0),
      Cut(width: 1.5, length: 3.0)
      
    ]
    let optimizer = CutOptimizer(sourceWidth: 3.5, sourceLength: 3.0, cuts: cuts, kerf: 0.125)
    XCTAssertTrue(optimizer.canMultipleWidthsFitInSourceWidth(cuts))
  }
  
  func testHandleSameWidthCuts_AllCutsSameWidthAsSource_LengthEqualToSource() {
    let cuts = [Cut(width: 3.0, length: 5.0),
                Cut(width: 3.0, length: 5.0),
                Cut(width: 3.0, length: 5.0)]
    let optimizer = CutOptimizer(sourceWidth: 3.0, sourceLength: 5.0, cuts: cuts, kerf: 0.125)
    
    let slices = optimizer.handleSameWidthCuts(cuts)
    
    XCTAssertEqual(slices.count, 1)
    for (index, slice) in slices.enumerated() {
      XCTAssertEqual(slice.sourceMaterialIndex, index)
      XCTAssertEqual(slice.width, 3.0)
      XCTAssertEqual(slice.widthKerf, 0)
      XCTAssertEqual(slice.remainingLength, 5.0)
    }

  }
  
  
  func testHandleSameWidthCuts_CutWidthsLessThanSourceWidth_LengthEqualToSource() {
    // Cuts where widths are less than the source width but can't fit multiple widths within the source width
    let cuts = [
      Cut(width: 1.8, length: 5.0),
      Cut(width: 1.8, length: 5.0),
      Cut(width: 1.8, length: 5.0)
    ]
    let optimizer = CutOptimizer(sourceWidth: 2.0, sourceLength: 5.0, cuts: cuts, kerf: 0.125)
    let slices = optimizer.handleSameWidthCuts(cuts)
    
    
    
    XCTAssertEqual(slices.count, 1)
    for (index, slice) in slices.enumerated() {
      XCTAssertEqual(slice.sourceMaterialIndex, index)
      
      XCTAssertEqual(slice.width, 1.8)
      XCTAssertEqual(slice.widthKerf, 0.125)
      XCTAssertEqual(slice.remainingLength, 5.0)
    }
    
    
  }

  func testHandleSameWidthCuts_MultipleWidthsFit_LengthEqualToSource() {
    let cuts = [
      Cut(width: 1, length: 3),
      Cut(width: 1, length: 3),
      Cut(width: 1, length: 3),
      Cut(width: 1, length: 3)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 3, cuts: cuts, kerf: 0.125)
    let slices = optimizer.handleSameWidthCuts(cuts)
    
    XCTAssertEqual(slices.count, 2)
    
    XCTAssertEqual(slices[0].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[0].width, 1)
    XCTAssertEqual(slices[0].widthKerf, 0.125)
    XCTAssertEqual(slices[0].remainingLength, 3.0)
    
    XCTAssertEqual(slices[1].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[1].width, 1)
    XCTAssertEqual(slices[1].widthKerf, 0.125)
    XCTAssertEqual(slices[1].remainingLength, 3.0)
    
  }
  
  func testHandleSameWidthCuts_MultipleWidthsFit_LengthsVaried() {
    let cuts = [
      Cut(width: 1, length: 3),
      Cut(width: 1, length: 1)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 5, cuts: cuts, kerf: 0.125)
    let slices = optimizer.handleSameWidthCuts(cuts)
    
    // Adjusting the assertion to match the expected slices based on the logic
    XCTAssertEqual(slices.count, 1)
    
    XCTAssertEqual(slices[0].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[0].width, 1)
    XCTAssertEqual(slices[0].widthKerf, 0.125)
    XCTAssertEqual(slices[0].remainingLength, 5.0)
  }
  
  
  
  
  func testFindBestCombination_ExactFit() {
    let optimizer = CutOptimizer(sourceWidth: 10, sourceLength: 10, cuts: [], kerf: 0.125)
    let widthMap: [Double: Int] = [2: 1, 3: 2, 5: 1]
    let remainingWidth: Double = 5
    
    let bestCombination = optimizer.findBestCombination(for: remainingWidth, in: widthMap)
    
    XCTAssertEqual(bestCombination, [3])
  }
  
  
  func testFindBestCombination_NoFit() {
    let optimizer = CutOptimizer(sourceWidth: 10, sourceLength: 10, cuts: [], kerf: 0.125)
    let widthMap: [Double: Int] = [6: 1, 7: 2]
    let remainingWidth: Double = 5
    
    let bestCombination = optimizer.findBestCombination(for: remainingWidth, in: widthMap)
    
    XCTAssertTrue(bestCombination.isEmpty)
  }
  
  func testFindBestCombination_MultipleOptions() {
    let optimizer = CutOptimizer(sourceWidth: 10, sourceLength: 10, cuts: [], kerf: 0.125)
    let widthMap: [Double: Int] = [2: 3, 3: 2, 5: 1, 1: 5]
    let remainingWidth: Double = 6.5
    
    let bestCombination = optimizer.findBestCombination(for: remainingWidth, in: widthMap)
    
    let possibleCombinations: [[Double]] = [
      [5, 1],
      [3, 3],
      [2, 2, 2],
      [1, 1, 1, 1, 2],
      [2, 2, 1, 1],
      [3, 2, 1],
      [3, 1, 1, 1]
    ]
    
    
    XCTAssertTrue(possibleCombinations.contains { $0.sorted() == bestCombination.sorted() })
  }
  
  func testFindBestCombination_SingleWidthAvailable() {
    let optimizer = CutOptimizer(sourceWidth: 10, sourceLength: 10, cuts: [], kerf: 0.125)
    let widthMap: [Double: Int] = [2: 2]
    let remainingWidth: Double = 6
    
    let bestCombination = optimizer.findBestCombination(for: remainingWidth, in: widthMap)
    
    XCTAssertEqual(bestCombination, [2, 2])
  }
  
  
  func testSortWidthsIntoDictionary_SimpleCase() {
    let cuts = [
      Cut(width: 2, length: 3),
      Cut(width: 2, length: 3),
      Cut(width: 1, length: 2),
      Cut(width: 1.5, length: 5),
      Cut(width: 1.5, length: 1),
      Cut(width: 1.5, length: 3)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 6.5, cuts: cuts, kerf: 0.125)
    let widthMap = optimizer.sortWidthsIntoDictionary(cuts)
    
    XCTAssertEqual(widthMap[2], 1)
    XCTAssertEqual(widthMap[1], 1)
    XCTAssertEqual(widthMap[1.5], 2)
  }
  
  func testSortWidthsIntoDictionary_EmptyCuts() {
    let cuts: [Cut] = []
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 6.5, cuts: cuts, kerf: 0.125)
    let widthMap = optimizer.sortWidthsIntoDictionary(cuts)
    
    XCTAssertTrue(widthMap.isEmpty)
  }
  
  func testSortWidthsIntoDictionary_SingleCut() {
    let cuts = [
      Cut(width: 2, length: 3)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 6.5, cuts: cuts, kerf: 0.125)
    let widthMap = optimizer.sortWidthsIntoDictionary(cuts)
    
    XCTAssertEqual(widthMap[2], 1)
  }
  
  func testSortWidthsIntoDictionary_MixedLengths() {
    let cuts = [
      Cut(width: 1, length: 3),
      Cut(width: 1, length: 2),
      Cut(width: 1, length: 4),
      Cut(width: 2, length: 3),
      Cut(width: 2, length: 5),
      Cut(width: 1.5, length: 5),
      Cut(width: 1.5, length: 3)
    ]
    let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 6.5, cuts: cuts, kerf: 0.125)
    let widthMap = optimizer.sortWidthsIntoDictionary(cuts)
    
    XCTAssertEqual(widthMap[1], 2)
    XCTAssertEqual(widthMap[2], 2)
    XCTAssertEqual(widthMap[1.5], 2)
  }
  
//  
//  //   Test when cuts have different widths and all can fit within the source width
  func testHandleDifferentWidthCuts_MultipleWidthsFit() {
    let cuts = [
      Cut(width: 2, length: 4),
      Cut(width: 1.5, length: 3),
      Cut(width: 1, length: 2),
      Cut(width: 1.5, length: 5)
    ]
    let optimizer = CutOptimizer(sourceWidth: 5, sourceLength: 10, cuts: cuts, kerf: 0.125)
    var slices = optimizer.handleDifferentWidthCuts(cuts)
    
    XCTAssertEqual(slices.count, 3)
    for (index, slice) in slices.enumerated() {
      XCTAssertEqual(slice.sourceMaterialIndex, 0)
    }
    
    slices.sort(by: { $0.width > $1.width })
    
    XCTAssertEqual(slices[0].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[0].width, 2)
    XCTAssertEqual(slices[0].widthKerf, 0.125)
    XCTAssertEqual(slices[0].remainingLength, 10.0)
    
    XCTAssertEqual(slices[1].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[1].width, 1.5)
    XCTAssertEqual(slices[1].widthKerf, 0.125)
    XCTAssertEqual(slices[1].remainingLength, 10.0)
    
    XCTAssertEqual(slices[2].sourceMaterialIndex, 0)
    XCTAssertEqual(slices[2].width, 1)
    XCTAssertEqual(slices[2].widthKerf, 0.125)
    XCTAssertEqual(slices[2].remainingLength, 10.0)
  }
  
//  // Test when cuts have different widths and not all can fit within the source width
  func testHandleDifferentWidthCuts_NotAllWidthsFit() {
    let cuts = [
      Cut(width: 4, length: 5),
      Cut(width: 3, length: 4),
      Cut(width: 2.5, length: 3),
      Cut(width: 2, length: 2)
    ]
    let optimizer = CutOptimizer(sourceWidth: 5, sourceLength: 10, cuts: cuts, kerf: 0.125)
    var slices = optimizer.handleDifferentWidthCuts(cuts)
    
    XCTAssertEqual(slices.count, 2)
  
  }
//  
//  // Test when cuts have varying widths and lengths, and the optimizer needs to decide the best slicing
  func testHandleDifferentWidthCuts_VaryingWidthsAndLengths() {
    let cuts = [
      Cut(width: 1, length: 6),
      Cut(width: 1, length: 3), // these two should be one slice
      Cut(width: 4, length: 7), // thise should be another
    ]
    let optimizer = CutOptimizer(sourceWidth: 5.5, sourceLength: 10, cuts: cuts, kerf: 0.125)
    var slices = optimizer.handleDifferentWidthCuts(cuts)
    
    XCTAssertEqual(slices.count, 2)
   print("testslice2", slices)
  }
  

      
      func testAllocateRemainingCutsToSlices_SimpleCase() {
          let cuts = [
              Cut(width: 2, length: 3),
              Cut(width: 2, length: 3)
          ]
        let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 6.5, cuts: cuts, kerf: 0.125)
          var slices = [
            Slice(sourceMaterialIndex: 0, width: 2, widthKerf: 0.125, remainingLength: 6.5, cuts: [])
          ]
          var remainingCuts = cuts
          optimizer.allocateRemainingCutsToSlices(&slices, remainingCuts: &remainingCuts)
          
          XCTAssertEqual(slices[0].cuts?.count, 2)
        XCTAssertEqual(slices[0].remainingLength, 0.25)
          XCTAssertTrue(remainingCuts.isEmpty)
      }
      
      func testAllocateRemainingCutsToSlices_CutsWithDifferentWidths() {
          let cuts = [
              Cut(width: 2, length: 3),
              Cut(width: 2, length: 2),
              Cut(width: 1, length: 1)
          ]
          let optimizer = CutOptimizer(sourceWidth: 4, sourceLength: 6, cuts: cuts, kerf: 0.125)
          var slices = [
              Slice(sourceMaterialIndex: 0, width: 2, widthKerf: 0.125, remainingLength: 6, cuts: [])
          ]
          var remainingCuts = cuts
          optimizer.allocateRemainingCutsToSlices(&slices, remainingCuts: &remainingCuts)
          
          XCTAssertEqual(slices[0].cuts?.count, 2)
          XCTAssertEqual(slices[0].remainingLength, 0.75)
      }
      
      func testAllocateRemainingCutsToSlices_CutsExceedingLength() {
          let cuts = [
            Cut(width: 1.5, length: 4),
            Cut(width: 2, length: 3.5),
              Cut(width: 2, length: 2)
          ]
          let optimizer = CutOptimizer(sourceWidth: 4, sourceLength: 6, cuts: cuts, kerf: 0.125)
          var slices = [
            Slice(sourceMaterialIndex: 0, width: 1.5, widthKerf: 0.125, remainingLength: 6, cuts: []),
              Slice(sourceMaterialIndex: 0, width: 2, widthKerf: 0.125, remainingLength: 6, cuts: []),
          ]
          var remainingCuts = cuts
          optimizer.allocateRemainingCutsToSlices(&slices, remainingCuts: &remainingCuts)
          
          XCTAssertEqual(slices[0].cuts?.count, 1)
          XCTAssertEqual(slices[1].cuts?.count, 2)
      }

  func testCalculateTotalRemainingArea() {
      let slices = [
          Slice(sourceMaterialIndex: 0, width: 1.0, widthKerf: 0.125, remainingLength: 5.0, cuts: nil),
          Slice(sourceMaterialIndex: 0, width: 1.0, widthKerf: 0.125, remainingLength: 4.0, cuts: nil),
          Slice(sourceMaterialIndex: 0, rowIndex: 1, width: 1.0, widthKerf: 0.125, remainingLength: 3.0, cuts: nil)
      ]
      let optimizer = CutOptimizer(sourceWidth: 4.0, sourceLength: 10.0, cuts: [], kerf: 0.125)
      let totalRemainingArea = optimizer.calculateTotalRemainingArea(from: slices)
    

    XCTAssertEqual(totalRemainingArea, 19.75)
  }

  func testCanAnyCutFitInRemainingArea_True() {
      let cuts = [
          Cut(width: 1.0, length: 2.0),
          Cut(width: 3.0, length: 4.0)
      ]
      let remainingArea = 12.0
      let optimizer = CutOptimizer(sourceWidth: 4.0, sourceLength: 10.0, cuts: [], kerf: 0.125)
      XCTAssertTrue(optimizer.canAnyCutFitInRemainingArea(cuts, remainingArea))
  }

  func testCanAnyCutFitInRemainingArea_False() {
      let cuts = [
          Cut(width: 2.0, length: 2.0),
          Cut(width: 3.0, length: 4.0)
      ]
      let remainingArea = 2.0
      let optimizer = CutOptimizer(sourceWidth: 4.0, sourceLength: 10.0, cuts: [], kerf: 0.125)
      XCTAssertFalse(optimizer.canAnyCutFitInRemainingArea(cuts, remainingArea))
  }
  
  func testOptimize_SimpleCase1() {
      let cuts = [
          Cut(width: 1, length: 2),
          Cut(width: 1, length: 2)
      ]
      let optimizer = CutOptimizer(sourceWidth: 2, sourceLength: 5, cuts: cuts, kerf: 0.125)
      let overview = optimizer.optimize()
      
      XCTAssertEqual(overview.totalSourceMaterials, 1)
      XCTAssertEqual(overview.cuttingPlans.count, 1)
      XCTAssertEqual(overview.cuttingPlans[0].slices.count, 1)
  }
  
  
  func testOptimize_SimpleCase2() {
      let cuts = [
          Cut(width: 2, length: 2),
          Cut(width: 2, length: 2),
          Cut(width: 2, length: 2)

      ]
      let optimizer = CutOptimizer(sourceWidth: 2, sourceLength: 5, cuts: cuts, kerf: 0.125)
      let overview = optimizer.optimize()
      
      XCTAssertEqual(overview.totalSourceMaterials, 2)
      XCTAssertEqual(overview.cuttingPlans.count, 2)
      XCTAssertEqual(overview.cuttingPlans[0].slices.count, 1)
  }
  
  func testOptimize_DadsCase() {
      let cuts = [
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          
          Cut(width: 3, length: 9.25),
          Cut(width: 3, length: 9.25),
          Cut(width: 3, length: 9.25),
          Cut(width: 3, length: 9.25),
          Cut(width: 3, length: 9.25),
          Cut(width: 3, length: 9.25),
          
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),
          Cut(width: 3, length: 40),

          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          Cut(width: 3, length: 10.75),
          
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          
          Cut(width: 3, length: 9),
          Cut(width: 3, length: 9),
          
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),
          Cut(width: 3, length: 21.5),

          Cut(width: 3, length: 12.25),
          Cut(width: 3, length: 12.25),
          Cut(width: 3, length: 12.25),
          Cut(width: 3, length: 12.25),
          
          Cut(width: 3, length: 28),
          Cut(width: 3, length: 28),
          
          Cut(width: 3, length: 3.25),
          Cut(width: 3, length: 3.25),
          
          Cut(width: 3, length: 27.25),
          Cut(width: 3, length: 27.25),
          Cut(width: 3, length: 27.25),
          Cut(width: 3, length: 27.25),
          
          Cut(width: 3, length: 6),
          Cut(width: 3, length: 6),
          Cut(width: 3, length: 6),
          Cut(width: 3, length: 6)



      ]
      let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 96, cuts: cuts, kerf: 0.125)
      let overview = optimizer.optimize()
      
//      XCTAssertEqual(overview.totalSourceMaterials, 2)
//      XCTAssertEqual(overview.cuttingPlans.count, 2)
//      XCTAssertEqual(overview.cuttingPlans[0].slices.count, 1)
    
    
    print("testOptimize_DadsCase_debug")
    print("totalSourceMaterials", overview.totalSourceMaterials)
    for cuttingPlan in overview.cuttingPlans {
      for slice in cuttingPlan.slices {
        print("Slice - Source Material Index: \(slice.sourceMaterialIndex), RowIndex: \(slice.rowIndex),  Width: \(slice.width), Remaining Length: \(slice.remainingLength), Cuts: \(slice.cuts?.map { "(\($0.width) x \($0.length))" } ?? [])")
      }
    }
  }
  
  
  func testOptimize_MultipleWidths() {
         let cuts = [
             Cut(width: 1, length: 2),
             Cut(width: 1.5, length: 3),
             Cut(width: 2, length: 1)
         ]
         let optimizer = CutOptimizer(sourceWidth: 4, sourceLength: 5, cuts: cuts, kerf: 0.125)
         let overview = optimizer.optimize()
         
         XCTAssertEqual(overview.totalSourceMaterials, 1)
         XCTAssertEqual(overview.cuttingPlans.count, 1)

    print("testOptimize_MultipleWidths_debug")
        for slice in overview.cuttingPlans[0].slices {
          print("Slice - Source Material Index: \(slice.sourceMaterialIndex), RowIndex: \(slice.rowIndex),  Width: \(slice.width), Remaining Length: \(slice.remainingLength), Cuts: \(slice.cuts?.map { "(\($0.width) x \($0.length))" } ?? [])")
        }
    print("remainingCuts", optimizer.remainingCuts)
//         let plan = overview.cuttingPlans[0]
//         XCTAssertEqual(plan.slices.count, 3)
//         
//         XCTAssertEqual(plan.slices[0].width, 1)
//         XCTAssertEqual(plan.slices[0].remainingLength, 3)
//         
//         XCTAssertEqual(plan.slices[1].width, 1.5)
//         XCTAssertEqual(plan.slices[1].remainingLength, 2)
//         
//         XCTAssertEqual(plan.slices[2].width, 2)
//         XCTAssertEqual(plan.slices[2].remainingLength, 4)
     }
//     
//     func testOptimize_ComplexCase() {
//         let cuts = [
//             Cut(width: 1, length: 3),
//             Cut(width: 1, length: 2),
//             Cut(width: 2, length: 2),
//             Cut(width: 1.5, length: 1),
//             Cut(width: 0.5, length: 5)
//         ]
//         let optimizer = CutOptimizer(sourceWidth: 5, sourceLength: 5, cuts: cuts, kerf: 0.125)
//         let overview = optimizer.optimize()
//         
//         XCTAssertEqual(overview.totalSourceMaterials, 1)
//         XCTAssertEqual(overview.cuttingPlans.count, 1)
//         
//         let plan = overview.cuttingPlans[0]
//         XCTAssertEqual(plan.slices.count, 5)
//         
//         XCTAssertEqual(plan.slices[0].width, 1)
//         XCTAssertEqual(plan.slices[0].remainingLength, 0)
//         
//         XCTAssertEqual(plan.slices[1].width, 1)
//         XCTAssertEqual(plan.slices[1].remainingLength, 1)
//         
//         XCTAssertEqual(plan.slices[2].width, 2)
//         XCTAssertEqual(plan.slices[2].remainingLength, 3)
//         
//         XCTAssertEqual(plan.slices[3].width, 1.5)
//         XCTAssertEqual(plan.slices[3].remainingLength, 4)
//         
//         XCTAssertEqual(plan.slices[4].width, 0.5)
//         XCTAssertEqual(plan.slices[4].remainingLength, 0)
//     }
//     
//     func testOptimize_MultipleSourceMaterials() {
//         let cuts = [
//             Cut(width: 1, length: 3),
//             Cut(width: 2, length: 4),
//             Cut(width: 2, length: 3),
//             Cut(width: 3, length: 2),
//             Cut(width: 1.5, length: 1)
//         ]
//         let optimizer = CutOptimizer(sourceWidth: 3, sourceLength: 5, cuts: cuts, kerf: 0.125)
//         let overview = optimizer.optimize()
//         
//         XCTAssertEqual(overview.totalSourceMaterials, 2)
//         XCTAssertEqual(overview.cuttingPlans.count, 2)
//         
//         let plan1 = overview.cuttingPlans[0]
//         XCTAssertEqual(plan1.slices.count, 3)
//         
//         XCTAssertEqual(plan1.slices[0].width, 1)
//         XCTAssertEqual(plan1.slices[0].remainingLength, 2)
//         
//         XCTAssertEqual(plan1.slices[1].width, 2)
//         XCTAssertEqual(plan1.slices[1].remainingLength, 0)
//         
//         XCTAssertEqual(plan1.slices[2].width, 2)
//         XCTAssertEqual(plan1.slices[2].remainingLength, 2)
//         
//         let plan2 = overview.cuttingPlans[1]
//         XCTAssertEqual(plan2.slices.count, 2)
//         
//         XCTAssertEqual(plan2.slices[0].width, 3)
//         XCTAssertEqual(plan2.slices[0].remainingLength, 3)
//         
//         XCTAssertEqual(plan2.slices[1].width, 1.5)
//         XCTAssertEqual(plan2.slices[1].remainingLength, 4)
//     }
//     
//     func testOptimize_ExactFit() {
//         let cuts = [
//             Cut(width: 2, length: 5),
//             Cut(width: 3, length: 5)
//         ]
//         let optimizer = CutOptimizer(sourceWidth: 5, sourceLength: 5, cuts: cuts, kerf: 0.125)
//         let overview = optimizer.optimize()
//         
//         XCTAssertEqual(overview.totalSourceMaterials, 1)
//         XCTAssertEqual(overview.cuttingPlans.count, 1)
//         
//         let plan = overview.cuttingPlans[0]
//         XCTAssertEqual(plan.slices.count, 2)
//         
//         XCTAssertEqual(plan.slices[0].width, 2)
//         XCTAssertEqual(plan.slices[0].remainingLength, 0)
//         
//         XCTAssertEqual(plan.slices[1].width, 3)
//         XCTAssertEqual(plan.slices[1].remainingLength, 0)
//     }
//  
}



// whole picture test cases
