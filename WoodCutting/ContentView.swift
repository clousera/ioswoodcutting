import SwiftUI

struct ContentView: View {
  @State private var sourceWidth: String = ""
  @State private var sourceLength: String = ""
  @State private var selectedKerfIndex: Int = 2 // Default to 1/8 inch
  @State private var cuts: [Cut] = []
  @State private var currentCutWidth: String = ""
  @State private var currentCutLength: String = ""
  @State private var selectedQuantity: Int = 1
  @State private var results: CuttingPlanOverview? = nil
  @State private var showErrorAlert = false
  @State private var errorMessage = ""
  @State private var defaultWidthToSource = false
  @State private var defaultLengthToSource = false
  
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
                  .toolbar {
                    ToolbarItem(placement: .keyboard) {
                      HStack {
                        Spacer()
                        Button("Done") {
                          UIApplication.shared.endEditing()
                        }
                      }
                    }
                  }
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
              Toggle(isOn: $defaultWidthToSource) {
                Text("Default width to source")
              }
              .onChange(of: defaultWidthToSource) { value in
                if value {
                  if let sourceWidth = Double(sourceWidth) {
                    currentCutWidth = String(sourceWidth)
                  }
                } else {
                  currentCutWidth = ""
                }
              }
              .padding(.horizontal)
              Toggle(isOn: $defaultLengthToSource) {
                Text("Default length to source")
              }
              .onChange(of: defaultLengthToSource) { value in
                if value {
                  if let sourceLength = Double(sourceLength) {
                    currentCutLength = String(sourceLength)
                  }
                } else {
                  currentCutLength = ""
                }
              }
              .padding(.horizontal)
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
                displayCutsList()
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
            
            if let results = results {
              displayResults(results)
            }
            
            Button(action: resetAll) {
              Text("Reset")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
          }
          .padding()
        }
      }
      .dismissKeyboardOnDrag()
      .navigationTitle("Wood Cut Optimizer")
      .modifier(NavigationBarModifier())
      .alert(isPresented: $showErrorAlert) {
        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
      }
    }

  }
  
  private func displayCutsList() -> some View {
    let groupedCuts = Dictionary(grouping: cuts) { CutKey(width: $0.width, length: $0.length) }
    return ForEach(groupedCuts.keys.sorted(by: { $0.width < $1.width }), id: \.self) { key in
      let cutsForSize = groupedCuts[key] ?? []
      let quantity = cutsForSize.count
      HStack {
        Text("\(decimalToFraction(key.width)) x \(decimalToFraction(key.length))")
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(8)
        
        Picker("Quantity", selection: Binding(
          get: { quantity },
          set: { newQuantity in
            updateQuantity(for: key, newQuantity: newQuantity)
          }
        )) {
          ForEach(1...100, id: \.self) { value in
            Text("\(value)").tag(value)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 70)
        .frame(height: 52)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        Spacer()
        Button(action: {
          deleteCuts(cut: cutsForSize[0])
        }) {
          Image(systemName: "trash")
            .foregroundColor(.red)
        }
      }
      .padding(.horizontal)
    }
  }
  
  
  
  private func displayResults(_ results: CuttingPlanOverview) -> some View {
    VStack(alignment: .leading) {
      Text("Results").font(.headline)
        .id("results")
      
      Text("Total Source Materials Needed: \(results.totalSourceMaterials)")
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
      
      ForEach(results.cuttingPlans) { plan in
        VStack(alignment: .leading) {
          Text("Source Material \(plan.sourceMaterialIndex + 1)").font(.headline)
          ForEach(plan.slices) { slice in
            VStack(alignment: .leading) {
              if let cuts = slice.cuts, !cuts.isEmpty {
                Text("Slice: \(decimalToFraction(slice.width)) wide")
                ForEach(cuts) { cut in
                  Text("Cut: \(decimalToFraction(cut.width)) x \(decimalToFraction(cut.length))")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.vertical, 4)
              }
            }
          }
        }
      }
    }
    .padding(.horizontal)
  }
  
  private func addCut() {
    guard let width = Double(currentCutWidth), width > 0 else {
      showError(message: "Please enter valid dimensions for the cut.")
      return
    }
    guard let length = Double(currentCutLength), length > 0 else {
      showError(message: "Please enter valid dimensions for the cut.")
      return
    }
    guard let sourceWidth = Double(sourceWidth), let sourceLength = Double(sourceLength), width <= sourceWidth, length <= sourceLength else {
      showError(message: "Cut dimensions cannot exceed source material dimensions.")
      return
    }
    
    for _ in 0..<selectedQuantity {
      let newCut = Cut(width: width, length: length)
      cuts.append(newCut)
    }
    
    if defaultWidthToSource, let sourceWidth = Double?(sourceWidth) {
      currentCutWidth = String(sourceWidth)
    } else {
      currentCutWidth = ""
    }
    if defaultLengthToSource, let sourceLength = Double?(sourceLength) {
      currentCutLength = String(sourceLength)
    } else {
      currentCutLength = ""
    }
    selectedQuantity = 1 // Reset quantity to 1 after adding a cut
  }
  
  private func updateQuantity(for key: CutKey, newQuantity: Int) {
    cuts.removeAll { $0.width == key.width && $0.length == key.length }
    for _ in 0..<newQuantity {
      let newCut = Cut(width: key.width, length: key.length)
      cuts.append(newCut)
    }
  }
  
  private func deleteCuts(cut: Cut) {
    cuts.removeAll { $0.width == cut.width && $0.length == cut.length }
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
    results = nil
    showErrorAlert = false
    errorMessage = ""
    defaultWidthToSource = false
    defaultLengthToSource = false
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

struct CutKey: Hashable {
  let width: Double
  let length: Double
}

// Custom ViewModifier to add profile button to the navigation bar
struct NavigationBarModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .navigationBarItems(trailing: NavigationLink(destination: FeedbackView()) {
        feedbackButton
      })
  }
  
  var feedbackButton: some View {
    Image(systemName: "questionmark.circle")
      .imageScale(.large)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
