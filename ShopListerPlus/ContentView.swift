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
                    .background(Color(hex: "#1AE51A"))
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
                //Create group logic here
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color(hex: "#1AE51A"))
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
    @State private var showingAddItemView = false
    @State private var showingTotalView = false

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

            // Add buttons to HStack to place them next to each other
            HStack(spacing: 10) {
                Button("Add Item") {
                    showingAddItemView = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#1AE51A"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showingAddItemView) {
                    AddItemView()
                }

                Button("View Total") {
                    showingTotalView = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showingTotalView) {
                    TotalView(items: listItem.items)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(listItem.title)
    }
}


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
            DetailItem(name: "Yogurt", amount: 1, cost: 3.99),
            DetailItem(name: "Protien", amount: 1, cost: 9.99),
            DetailItem(name: "Chicken", amount: 1, cost: 6.99)
        ]
        let workoutGroup = ListItem(title: "Workout", count: workoutItems.count, items: workoutItems)
        
        listItems = [workoutGroup]
    }
}

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemAmount: String = ""
    @State private var itemCost: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                TextField("Amount", text: $itemAmount)
                    .keyboardType(.numberPad)
                TextField("Cost", text: $itemCost)
                    .keyboardType(.decimalPad)
                
                Button("Add Item") {
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct TotalView: View {
    let items: [DetailItem]
    let taxRate: Double = 0.13
    @Environment(\.presentationMode)
    var presentationMode : Binding<PresentationMode>

    var body: some View {
        VStack {
            Text("Total (\(items.count))")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)

            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("$\(item.cost, specifier: "%.2f")")
                }
                Divider()
            }
            Spacer()

            VStack(alignment: .trailing) {
                Text("Total Cost")
                    .fontWeight(.bold)
                Text("$\(calculateTotal(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            Divider()

            Button("Calculate Total with Tax") {
                // Action to calculate total with tax
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)

            Divider()

            VStack(alignment: .trailing) {
                Text("Total Cost with Tax")
                    .fontWeight(.bold)
                Text("$\(calculateTotalWithTax(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            Divider()
            
            Spacer()

            HStack {
                Button("Back") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Checkout") {
                    // Action for checkout
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#1AE51A"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func calculateTotal() -> Double {
        // Total cost of items
        return items.reduce(0) { $0 + $1.cost * Double($1.amount) }
    }
    
    private func calculateTotalWithTax() -> Double {
        // Total cost including tax
        return calculateTotal() * (1 + taxRate)
    }
}



extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

