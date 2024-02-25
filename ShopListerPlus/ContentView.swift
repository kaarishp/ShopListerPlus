//
//  ContentView.swift
//  Final_Project
//  Group 20
//  COMP 3097
//  CRN: 50497
//  Przemyslaw Pawluk
//  George Brown College
//
//  Created by Kaarish Parameswaran on 2024-02-24.
//  Edited by Ali Al Aoraebi on 2024-02-25.
//

import SwiftUI

struct DetailItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var amount: Int
    var cost: Double
}

struct ListItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var count: Int
    var items: [DetailItem] = []
}

class ListViewModel: ObservableObject {
    @Published var listItems: [ListItem] = []

    init() {
        let workoutItems = [
            DetailItem(name: "Banana", amount: 2, cost: 0.50),
            DetailItem(name: "Yogurt", amount: 1, cost: 0.99)
        ]
        let workoutGroup = ListItem(title: "Workout", count: workoutItems.count, items: workoutItems)
        
        listItems = [workoutGroup]
    }
}


struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Text("Kaarish Parameswaran - 101355699")
                Text("Ali Al Aoraebi - 101386021")
                Text("Alvaro Aguirre Meza  - 101349908")
                Text("Amir Yektajoo- 101367389")
            }
            .navigationTitle("Team Members")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddGroupView: View {
    @Binding var listItems: [ListItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Group Name", text: $groupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()

                Button("Create Group") {
                    let newItem = ListItem(title: groupName, count: 0)
                    listItems.append(newItem)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationTitle("Add Group")
        }
    }
}

struct ListItemDetailView: View {
    @Binding var listItem: ListItem

    var body: some View {
        VStack {
            List {
                ForEach(listItem.items, id: \.self) { detailItem in
                    HStack {
                        Text(detailItem.name)
                        Spacer()
                        Text("x\(detailItem.amount)")
                        Spacer()
                        Text("$\(detailItem.cost, specifier: "%.2f")")
                    }
                }
            }
            .listStyle(PlainListStyle())

            Spacer()

            Button("Add Item") {}
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

            Button("View Total") {}
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .navigationTitle(listItem.title)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ListViewModel()
    @State private var showingAddGroupView = false
    @State private var showingAboutView = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.listItems.isEmpty {
                    Spacer()
                    Text("No groups. Please add a new group.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach($viewModel.listItems) { $item in
                            NavigationLink(destination: ListItemDetailView(listItem: $item)) {
                                HStack {
                                    Text(item.title)
                                    Spacer()
                                    Text("\(item.items.count)").foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                Button(action: {
                    showingAddGroupView = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Group")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingAddGroupView) {
                    AddGroupView(listItems: $viewModel.listItems)
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("About") {
                        showingAboutView = true
                    }
                }
            }
            .sheet(isPresented: $showingAboutView) {
                AboutView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
