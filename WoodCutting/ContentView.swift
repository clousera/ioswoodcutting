import SwiftUI

struct ContentView: View {
    @State private var sourceWidth: String = ""
    @State private var sourceLength: String = ""
    @State private var selectedKerfIndex: Int = 2 // Default to 1/8 inch
    @State private var cuts: [Cut] = []
    @State private var currentCutWidth: String = ""
    @State private var currentCutLength: String = ""
    @State private var selectedQuantity: Int = 1
    @State private var results: [CuttingPlan] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    let kerfOptions = [0.0625, 0.09375, 0.125, 0.1875, 0.25]
    let kerfFractions = ["1/16", "3/32", "1/8", "3/16", "1/4"]
    let quantities = Array(1...100)

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            Text("Source Material (in)").font(.headline)
                            HStack {
                                TextField("Width", text: $sourceWidth)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .frame(height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                TextField("Length", text: $sourceLength)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .frame(height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            Text("Kerf (blade width, in)").font(.headline)
                            Picker("Kerf (blade width, in)", selection: $selectedKerfIndex) {
                                ForEach(0..<kerfOptions.count) { index in
                                    Text(kerfFractions[index])
                                        .tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        Group {
                            Text("Add Required Cuts (in)").font(.headline)
                            HStack {
                                TextField("Cut Width", text: $currentCutWidth)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .frame(height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                TextField("Cut Length", text: $currentCutLength)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .frame(height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                Picker("Quantity", selection: $selectedQuantity) {
                                    ForEach(quantities, id: \.self) { quantity in
                                        Text("\(quantity)").tag(quantity)
                                    }
                                }
                                .pickerStyle(DefaultPickerStyle())
                                .frame(height: 44)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            Button(action: addCut) {
                                Text("Add Cut")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)

                        Group {
                            Text("Cuts List").font(.headline)
                            if cuts.isEmpty {
                                Text("No cuts added yet.")
                                    .padding()
                            } else {
                                ForEach(cuts) { cut in
                                    HStack {
                                        Text("\(decimalToFraction(cut.width)) x \(decimalToFraction(cut.length)) (\(cut.quantity))")
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        Spacer()
                                        Button(action: {
                                            deleteCut(cut: cut)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Button(action: {
                            calculateCuts()
                            withAnimation {
                                proxy.scrollTo("results", anchor: .top)
                            }
                        }) {
                            Text("Calculate")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        Button(action: resetAll) {
                            Text("Reset")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        if !results.isEmpty {
                            Group {
                                Text("Results").font(.headline)
                                    .id("results")
                                ForEach(results) { plan in
                                    VStack(alignment: .leading) {
                                        Text("Source Material \(plan.sourceIndex + 1)").font(.headline)
                                        ForEach(plan.cuts) { cut in
                                            Text("Cut: \(decimalToFraction(cut.width)) x \(decimalToFraction(cut.length))")
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .dismissKeyboardOnDrag()
            .navigationTitle("Wood Cut Optimizer")
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addCut() {
        guard let width = Double(currentCutWidth), let length = Double(currentCutLength), width > 0, length > 0 else {
            showError(message: "Please enter valid dimensions for the cut.")
            return
        }
        
        guard let sourceWidth = Double(sourceWidth), let sourceLength = Double(sourceLength), width <= sourceWidth, length <= sourceLength else {
            showError(message: "Cut dimensions cannot exceed source material dimensions.")
            return
        }
        
        cuts.append(Cut(width: width, length: length, quantity: selectedQuantity))
        currentCutWidth = ""
        currentCutLength = ""
        selectedQuantity = 1 // Reset quantity to 1 after adding a cut
    }

    private func deleteCut(cut: Cut) {
        if let index = cuts.firstIndex(where: { $0.id == cut.id }) {
            cuts.remove(at: index)
        }
    }

    private func calculateCuts() {
        guard let sourceWidth = Double(sourceWidth), let sourceLength = Double(sourceLength), sourceWidth > 0, sourceLength > 0 else {
            showError(message: "Please enter valid dimensions for the source material.")
            return
        }

        let kerf = kerfOptions[selectedKerfIndex]

        let optimizer = CutOptimizer(sourceWidth: sourceWidth, sourceLength: sourceLength, cuts: cuts, kerf: kerf)
        results = optimizer.optimize()
    }

    private func resetAll() {
        sourceWidth = ""
        sourceLength = ""
        selectedKerfIndex = 2
        cuts.removeAll()
        currentCutWidth = ""
        currentCutLength = ""
        selectedQuantity = 1
        results.removeAll()
        showErrorAlert = false
        errorMessage = ""
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }

    func decimalToFraction(_ value: Double) -> String {
        let wholeNumber = Int(value)
        let fractionPart = value - Double(wholeNumber)
        
        let denominator = 32
        var numerator = Int(fractionPart * Double(denominator))
        
        // Simplify the fraction
        let gcd = greatestCommonDivisor(numerator, denominator)
        numerator /= gcd
        let simplifiedDenominator = denominator / gcd
        
        if numerator == 0 {
            return "\(wholeNumber)"
        } else {
            if wholeNumber == 0 {
                return "\(numerator)/\(simplifiedDenominator)"
            } else {
                return "\(wholeNumber) \(numerator)/\(simplifiedDenominator)"
            }
        }
    }

    func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        if b == 0 {
            return a
        } else {
            return greatestCommonDivisor(b, a % b)
        }
    }
}

struct Cut: Identifiable {
    let id = UUID()
    let width: Double
    let length: Double
    let quantity: Int
}

struct CuttingPlan: Identifiable {
    let id = UUID()
    let sourceIndex: Int
    let cuts: [Cut]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
