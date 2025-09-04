import SwiftUI
import SwiftData

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var date: Date = Date().onlyDate
    @State private var location: String = ""
    @State private var jobNumber: String = ""
    @State private var notes: String = ""
    
    @State private var startTime: Date = Calendar.current.date(
            bySettingHour: 8, minute: 0, second: 0, of: Date()
        ) ?? Date()
    @State private var endTime: Date = Calendar.current.date(
            bySettingHour: 17, minute: 0, second: 0, of: Date()
        ) ?? Date()

    var entryToEdit: WorkEntry?

    init(entryToEdit: WorkEntry? = nil) { self.entryToEdit = entryToEdit }

    var isEditing: Bool { entryToEdit != nil }

    // horas brutas (fim - início)
    var durationHoursRaw: Double {
        max(0, endTime.timeIntervalSince(startTime) / 3600.0)
    }

    // horas líquidas descontando 1h de almoço
    var durationHoursNet: Double {
        max(0, durationHoursRaw - 1.0) // 1h de almoço
    }


    var body: some View {
        Form {
            // MARK: - Informações
            Section("INFORMAÇÕES") {
                DatePicker("Data", selection: $date, displayedComponents: .date)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Local de trabalho")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Ex: HDES – GTC", text: $location)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Nº da obra")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Ex: 321487", text: $jobNumber)
                        .keyboardType(.numbersAndPunctuation)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Descrição / Observações")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Opcional", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }

            // MARK: - Horário
            Section("HORÁRIO") {
                DatePicker("Início", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("Fim", selection: $endTime, displayedComponents: .hourAndMinute)

                let start = date.combiningTime(from: startTime)
                let end   = date.combiningTime(from: endTime)
                let bruto = max(0, end.timeIntervalSince(start) / 3600)
                let liquido = max(0, bruto - 1.0)

                HStack {
                    Text("Total")
                    Spacer()
                    Text("\(Int(liquido))h")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }


            if let warn = validationWarning {
                Section { Text(warn).foregroundStyle(.red) }
            }
        }
        .navigationTitle(isEditing ? "Editar registo" : "Novo registo")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Guardar" : "Adicionar") { save() }.disabled(!isValid)
            }
        }
        .onAppear { loadIfEditing() }
    }

    private var isValid: Bool {
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !jobNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        date.combiningTime(from: startTime) <= date.combiningTime(from: endTime)
    }
    private var validationWarning: String? {
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Informe o local de trabalho." }
        if jobNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Informe o Nº da obra." }
        let s = date.combiningTime(from: startTime); let e = date.combiningTime(from: endTime)
        if e < s { return "A hora de fim não pode ser anterior ao início." }
        return nil
    }

    private func loadIfEditing() {
        guard let e = entryToEdit else { return }
        date = e.date; location = e.location; jobNumber = e.jobNumber
        startTime = e.startTime; endTime = e.endTime; notes = e.notes ?? ""
    }

    private func save() {
        let start = date.combiningTime(from: startTime)
        let end = date.combiningTime(from: endTime)
        if let e = entryToEdit {
            e.date = date.onlyDate; e.location = location; e.jobNumber = jobNumber
            e.startTime = start; e.endTime = end; e.notes = notes
        } else {
            context.insert(WorkEntry(date: date.onlyDate, location: location, jobNumber: jobNumber, startTime: start, endTime: end, notes: notes))
        }
        try? context.save()
        dismiss()
    }
}
