//
//  ContentView.swift
//  Project
//
//  Created by Kaarish Parameswaran on 2024-02-24.
//

import SwiftUI

struct DetailItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amount: Int
    var cost: Double
}

struct ListItem: Identifiable {
    var id = UUID()
    var title: String
    var count: Int
    var items: [DetailItem] = []
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
            Form {
                TextField("Group Name", text: $groupName)
                Button("Add") {
                    addNewGroup()
                }
                .disabled(groupName.isEmpty)
            }
            .navigationTitle("Add Group")
        }
    }

    private func addNewGroup() {
        let newItem = ListItem(title: groupName, count: 0)
        listItems.append(newItem)
        presentationMode.wrappedValue.dismiss()
    }
}


struct ListItemDetailView: View {
    @Binding var listItem: ListItem
    @State private var showingAddItemView = false
    @State private var showingTotalWithTaxAlert = false
    
    let taxRate: Double = 0.13 // Tax rate of 13%
    
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
                .onDelete(perform: deleteItems)
            }
            
            Button("View Total with Tax") {
                showingTotalWithTaxAlert = true
            }
            .padding()
            .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
            .alert(isPresented: $showingTotalWithTaxAlert) {
                Alert(title: Text("Total Cost with Tax"), message: Text(totalWithTaxAsString()), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle(listItem.title)
        .navigationBarItems(trailing: Button(action: {
            showingAddItemView = true
        }) {
            Image(systemName: "plus")
            Text("Add Item")
        })
        .sheet(isPresented: $showingAddItemView) {
            AddItemView(detailItems: $listItem.items)
        }
    }
    
    private func totalWithTaxAsString() -> String {
        let subtotal = listItem.items.reduce(0) { $0 + $1.cost * Double($1.amount) }
        let totalWithTax = subtotal * (1 + taxRate)
        return String(format: "$%.2f", totalWithTax)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        listItem.items.remove(atOffsets: offsets)
    }
}



struct AddItemView: View {
    @Binding var detailItems: [DetailItem]
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
                    addNewItem()
                }
                .disabled(itemName.isEmpty || itemAmount.isEmpty || itemCost.isEmpty)
            }
            .navigationTitle("Add Item")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addNewItem() {
        if let amount = Int(itemAmount), let cost = Double(itemCost) {
            let newItem = DetailItem(name: itemName, amount: amount, cost: cost)
            detailItems.append(newItem)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView: View {
    @State private var listItems: [ListItem] = []
    @State private var showingAddGroupView = false
    @State private var showingAboutView = false // For showing the AboutView
    
    var body: some View {
        NavigationView {
            List {
                ForEach($listItems) { $item in
                    NavigationLink(destination: ListItemDetailView(listItem: $item)) {
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text("\(item.items.count)").foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItem)
                .onMove(perform: moveItem)
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("About") {
                        showingAboutView = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGroupView = true }) {
                        Label("Add New Group", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddGroupView) {
                AddGroupView(listItems: $listItems)
            }
            .sheet(isPresented: $showingAboutView) {
                AboutView()
            }
        }
    }
    
    // Remaining ContentView code...

    
    func deleteItem(at offsets: IndexSet) {
        listItems.remove(atOffsets: offsets)
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        listItems.move(fromOffsets: source, toOffset: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
