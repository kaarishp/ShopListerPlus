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

// Main Screen Section
struct ContentView: View {
    @StateObject private var viewModel = ListViewModel()
    @State private var showingAddGroupView = false
    @State private var showingAboutView = false

    var body: some View {
        NavigationView { 
            VStack {
                // Showing message if there are no created groups
                if viewModel.listItems.isEmpty {
                    Spacer()
                    Text("No groups. Please add a new group.")
                        .foregroundColor(.gray)
                    Spacer()
                } else { // Showing lists when group is created
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

                Button(action: { //Button that navigates to create group screen
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
                    Button("About") {//Button navigating to about screen
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

//Preview struct for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()// This creates and returns an instance of ContentView
    }
}

//About Information Screen
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

//Adding new group screen
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
                //Create group logic here for final implementation
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

//List group items screen
struct ListItemDetailView: View {
    @Binding var listItem: ListItem
    @State private var showingAddItemView = false
    @State private var showingTotalView = false

    var body: some View {
        VStack {
            List { // List details
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

            HStack(spacing: 10) {
                Button("Add Item") { //Add item button that navigated to add item screen
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

                Button("View Total") { //View total button that navigated to add item screen
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


//Item details
struct DetailItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var amount: Int
    var cost: Double
}

// Items inside the list details
struct ListItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var count: Int
    var items: [DetailItem] = []
}

class ListViewModel: ObservableObject {
    @Published var listItems: [ListItem] = []

    init() { //Hard-coded data
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
                    //Create logic to add item in the list
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


//Total View Screen
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
                HStack { //showing item name with the cost
                    Text(item.name)
                    Spacer()
                    Text("$\(item.cost, specifier: "%.2f")")
                }
                Divider()
            }
            
            Spacer()

            VStack(alignment: .trailing) { // Showing total cost before tax
                Text("Total Cost")
                    .fontWeight(.bold)
                Text("$\(calculateTotal(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            Divider()

            Button("Calculate Total with Tax") {
                // Create logic to calculate total with tax
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)

            Divider()

            VStack(alignment: .trailing) { // Showing total cost after tax
                Text("Total Cost with Tax")
                    .fontWeight(.bold)
                Text("$\(calculateTotalWithTax(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            Divider()
            
            Spacer()

            HStack {
                Button("Back") { // Back button to go back to list screen, can swipe screen down as well
                    self.presentationMode.wrappedValue.dismiss()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Checkout") {
                    // Create logic for checkout
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
    
    // Total cost of items
    private func calculateTotal() -> Double {
        return items.reduce(0) { $0 + $1.cost * Double($1.amount) }
    }
    
    // Total cost including tax

    private func calculateTotalWithTax() -> Double {
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

