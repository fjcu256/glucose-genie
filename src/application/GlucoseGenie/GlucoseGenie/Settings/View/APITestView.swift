//
//  APITestView.swift
//  GlucoseGenie
//
//  Created by Jared Jackson on 3/6/25.
//

import SwiftUI
import Amplify

struct APITestView: View {
    @State private var message: String = "Tap the button to add dummy data"
    @State private var dbData: [TestDB] = []

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await createData()
                    await fetchData() // Refresh list
                }
            } label: {
                Text("Add Dummy Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            List(dbData, id: \.id) { item in
                VStack(alignment: .leading) {
//                    Text(item.description) // Display title of todo
//                        .font(.headline)
                    Text(item.description ?? "No description") // Display description
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .task {
            await fetchData() // Fetch data on view load
        }
    }
        

    func createData() async {
        do{
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            let email = attributes.first(where: { $0.key == .email })?.value ?? "Unknown Email"
            let data = TestDB(owner: email, description: "A Test Create by " + email)
            
            let result = try await Amplify.API.mutate(request: .create(data))
            switch result {
                case .success(let data):
                    print("✅ Successfully created data: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("❌ Failed to create data: ", error)
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    func fetchData() async {
        do {
            let result = try await Amplify.API.query(request: .list(TestDB.self))
            switch result {
            case .success(let fetchedData):
                DispatchQueue.main.async {
                    self.dbData = Array(fetchedData)
                    self.message = "Fetched \(fetchedData.count) entries"
                }
            case .failure(let error):
                print("❌ Failed to fetch data: \(error.errorDescription)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
}

