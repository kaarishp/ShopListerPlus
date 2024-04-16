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
    @Published var listItems: [ListItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }

    init() {
        loadFromUserDefaults()
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "listItems"),
           let decoded = try? JSONDecoder().decode([ListItem].self, from: data) {
            listItems = decoded
        }
    }

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(listItems) {
            UserDefaults.standard.set(encoded, forKey: "listItems")
        }
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
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                .frame(maxWidth: .infinity)

                Spacer()

                Button(action: {
                    if groupName.isEmpty {
                        showAlert = true
                    } else {
                        addNewGroup()
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Text("Create Group")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text("Please fill in the fields to add a new group."),
                        dismissButton: .default(Text("OK"))
                    )
                }
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
    @State private var showingTotalView = false
    
    var body: some View {
        VStack {
            List {
                ForEach(listItem.items.indices, id: \.self) { index in
                    HStack {
                        Text(listItem.items[index].name)
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        HStack {
                            Button(action: { self.changeAmount(for: index, delta: -1) }) {
                                Image(systemName: "minus.circle.fill")
                            }
                            Text("\(listItem.items[index].amount)")
                                .frame(width: 20, alignment: .center)
                            Button(action: { self.changeAmount(for: index, delta: 1) }) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .foregroundColor(.green)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        TextField("Price", value: $listItem.items[index].cost, formatter: NumberFormatter.currency)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 80, alignment: .trailing)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Button(action: {
                    showingAddItemView = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Item")
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {
                    showingTotalView = true
                }) {
                    Text("View Total")
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(listItem.title)
        .sheet(isPresented: $showingAddItemView) {
            AddItemView(detailItems: $listItem.items)
        }
        .sheet(isPresented: $showingTotalView) {
            TotalView(items: listItem.items, onCheckoutCompleted: {
                listItem.items.removeAll()
            })
        }
    }
    
    private func changeAmount(for index: Int, delta: Int) {
        let newAmount = listItem.items[index].amount + delta
        listItem.items[index].amount = max(newAmount, 0)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        listItem.items.remove(atOffsets: offsets)
    }
}

// Utility formatter for the currency
extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.isLenient = true
        return formatter
    }
}

struct TotalView: View {
    var items: [DetailItem]
        var onCheckoutCompleted: (() -> Void)?
        @Environment(\.presentationMode) var presentationMode
        let taxRate: Double = 0.13
        @State private var showingCheckoutAlert = false

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
            Spacer()
            Spacer()

            VStack(alignment: .trailing) {
                Text("Total Cost")
                    .fontWeight(.bold)
                Text("$\(calculateTotal(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            Divider()

            VStack(alignment: .trailing) {
                Text("Total Cost with Tax")
                    .fontWeight(.bold)
                Text("$\(calculateTotalWithTax(), specifier: "%.2f")")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)

            
            Spacer()

            HStack {
                Button("View Item List") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Checkout") {
                            showingCheckoutAlert = true
                        }
                        .alert(isPresented: $showingCheckoutAlert) {
                            Alert(
                                title: Text("Checkout"),
                                message: Text("Checkout successfully."),
                                dismissButton: .default(Text("OK")) {
                                    onCheckoutCompleted?()
                                }
                            )
                        }
                        .frame(minWidth: 0, maxWidth:
                        .infinity)
                        .padding()
                        .background(Color.green)
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


struct LaunchScreenView: View {
    @Binding var showingLaunchScreen: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("ShopListPlus")
                .font(.largeTitle)
                .fontWeight(.bold)
            Button("Start") {
                withAnimation {
                    showingLaunchScreen = false
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
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
                    // This list will show when there are items
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
                        .onDelete(perform: deleteItem)
                        .onMove(perform: moveItem)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAboutView) {
                AboutView()
            }
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        viewModel.listItems.remove(atOffsets: offsets)
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.listItems.move(fromOffsets: source, toOffset: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

