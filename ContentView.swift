import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\WorkEntry.date, order: .reverse)])
    private var entries: [WorkEntry]

    @State private var showingForm = false
    @State private var searchText = ""
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false

    // compara apenas o dia
    private func sameDay(_ a: Date, _ b: Date) -> Bool {
        let cal = Calendar.current
        return cal.startOfDay(for: a) == cal.startOfDay(for: b)
    }

    // Filtro
    var filtered: [WorkEntry] {
        entries.filter { e in
            var ok = true
            if !searchText.isEmpty {
                ok = e.location.localizedCaseInsensitiveContains(searchText)
                  || e.jobNumber.localizedCaseInsensitiveContains(searchText)
            }
            if let d = selectedDate {
                ok = ok && sameDay(e.date, d)
            }
            return ok
        }
    }

    // Se você não criou durationHoursNet, troque por durationHoursRaw
    var totalHours: Double { filtered.reduce(0) { $0 + $1.durationHoursNet } }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Busca
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Local ou Nº da Obra", text: $searchText)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding([.horizontal, .top])

                // Filtro por data
                HStack(spacing: 12) {
                    Button { showDatePicker = true } label: {
                        Label(
                            selectedDate.map {
                                DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
                            } ?? "Filtrar por data",
                            systemImage: "calendar"
                        )
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    if selectedDate != nil || !searchText.isEmpty {
                        Button("Limpar") {
                            selectedDate = nil
                            searchText = ""
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .sheet(isPresented: $showDatePicker) {
                    NavigationStack {
                        VStack {
                            DatePicker(
                                "Selecionar data",
                                selection: Binding(
                                    get: { selectedDate ?? Date() },
                                    set: { selectedDate = $0 }
                                ),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            Spacer()
                        }
                        .navigationTitle("Filtro de Data")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                
                                Button("OK") { showDatePicker = false }
                            }
                        }
                    }
                }

                // Lista
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Sem registos",
                        systemImage: "clock.badge.questionmark",
                        description: Text("Toque no + para lançar o primeiro registo.")
                    )
                } else {
                    List {
                        Section(footer: Text("Total: \(totalHours, specifier: "%.2f") h")) {
                            ForEach(filtered, id: \.self) { entry in
                                NavigationLink {
                                    EntryFormView(entryToEdit: entry)
                                } label: {
                                    EntryRow(entry: entry)
                                }
                            }
                            .onDelete(perform: delete)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Horas de Trabalho")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingForm = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))   // aumenta o tamanho
                            .symbolRenderingMode(.hierarchical) // opcional: estilo
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                NavigationStack { EntryFormView() }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(filtered[i]) }
        try? context.save()
    }
}

// Linha da lista
struct EntryRow: View {
    let entry: WorkEntry
    private static let tf: DateFormatter = { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(DateFormatter.localizedString(from: entry.date, dateStyle: .medium, timeStyle: .none))
                    .font(.headline)
                Spacer()
                Text("\(Int(entry.durationHoursNet))h").font(.subheadline)
            }
            HStack(spacing: 12) {
                Label(entry.location, systemImage: "mappin.and.ellipse").lineLimit(1)
                Divider()
                Label("Obra: \(entry.jobNumber)", systemImage: "number").lineLimit(1)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text("\(Self.tf.string(from: entry.startTime)) – \(Self.tf.string(from: entry.endTime))")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
