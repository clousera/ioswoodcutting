import SwiftUI
import FirebaseFirestore

struct FeedbackView: View {
  @State private var comments: String = ""
  @State private var showingAlert = false
  @State private var email: String = ""
  @State private var alertHeader = ""
  @State private var alertMessage = ""
  
  
  
  var plannedFeatures: [String] = [
    "Feature 1: Enhanced cut visualization",
    "Feature 2: Export cutting plans to PDF",
    "Feature 3: Save and load projects",
    "Feature 4: Multi-language support",
    "Feature 5: Advanced optimization settings"
  ]
  
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Group {
          Text("We value your feedback!")
            .font(.headline)
            .padding(.top, 20)
          
          Text("Please share your comments and suggestions below:")
            .padding(.top, 5)
          
          TextEditor(text: $comments)
            .padding()
            .frame(height: 150)
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
            )
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
          
          
          Text("Your Email (optional):")
          TextField("Enter your email", text: $email)
            .keyboardType(.emailAddress)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
        }
        .padding(.horizontal)
        
        
        Button(action: submitFeedback) {
          Text("Submit Feedback")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }                          .padding(.horizontal)
        
        
        Group {
          Text("Planned Features")
            .font(.headline)
            .padding(.top, 20)
          
          ForEach(plannedFeatures, id: \.self) { feature in
            HStack {
              Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
              Text(feature)
            }
            .padding(.top, 5)
          }
        }
        .padding(.horizontal)
        
        Spacer()
      }
      
      //        .padding()
    }
    .dismissKeyboardOnDrag()
    
    .navigationTitle("Feedback")
    .alert(isPresented: $showingAlert) {
      Alert(title: Text(alertHeader), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }
  }
  
  
  private func submitFeedback() {
    let db = Firestore.firestore()
    let feedbackData: [String: Any] = [
      "email": email,
      "comments": comments,
      "timestamp": Timestamp()
    ]
    
    db.collection("feedback").addDocument(data: feedbackData) { error in
      if let error = error {
        alertHeader = "Oops!"
        alertMessage = "Error submitting feedback: \(error.localizedDescription)"
      } else {
        alertHeader = "Thank you!"
        
        alertMessage = "Feedback submitted successfully!"
        comments = ""
        email = ""
      }
      showingAlert = true
    }
  }
  
}

struct FeedbackView_Previews: PreviewProvider {
  static var previews: some View {
    FeedbackView()
  }
}
