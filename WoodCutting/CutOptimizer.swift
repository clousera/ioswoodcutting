import Foundation

class CutOptimizer {
    let sourceWidth: Double
    let sourceLength: Double
    let kerf: Double
    var cuts: [Cut]

    init(sourceWidth: Double, sourceLength: Double, cuts: [Cut], kerf: Double) {
        self.sourceWidth = sourceWidth
        self.sourceLength = sourceLength
        self.cuts = cuts.flatMap { Array(repeating: $0, count: $0.quantity) }  // Expand cuts based on quantity
        self.kerf = kerf
    }

    func optimize() -> [CuttingPlan] {
        // Sort cuts by length in descending order for better packing
        cuts.sort { $0.length > $1.length }

        var remainingCuts = cuts
        var plans: [CuttingPlan] = []

        while !remainingCuts.isEmpty {
            var currentPlan: [Cut] = []
            var remainingLength = sourceLength
            var remainingWidth = sourceWidth

            for (index, cut) in remainingCuts.enumerated().reversed() {
                if cut.width <= remainingWidth && cut.length <= remainingLength {
                    currentPlan.append(cut)
                    remainingCuts.remove(at: index)
                    remainingLength -= (cut.length + kerf)
                }
            }

            plans.append(CuttingPlan(sourceIndex: plans.count, cuts: currentPlan))
        }

        return plans
    }
}
