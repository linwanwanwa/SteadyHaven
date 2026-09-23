import SwiftUI
import Vision
import PhotosUI

struct NutritionScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedItem: PhotosPickerItem?
    @State private var scannedImage: UIImage?
    @State private var isScanning = false
    @State private var scanResult: ScannedNutrition?
    @State private var errorMessage: String?
    @State private var templateName = ""
    @State private var showSaveSuccess = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false

    var onFill: (ScannedNutrition) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = scannedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.3))

                        Text("拍摄或选择营养标签照片")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                }

                HStack(spacing: 20) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("拍照", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("相册", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                if isScanning {
                    ProgressView("识别中...")
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                if let result = scanResult {
                    VStack(spacing: 8) {
                        Text("识别结果")
                            .font(.headline)

                        HStack(spacing: 16) {
                            ResultBadge(label: "热量", value: result.calories, unit: "kcal")
                            ResultBadge(label: "蛋白质", value: result.protein, unit: "g")
                            ResultBadge(label: "碳水", value: result.carbs, unit: "g")
                            ResultBadge(label: "脂肪", value: result.fat, unit: "g")
                            ResultBadge(label: "钠", value: result.sodium, unit: "mg")
                        }

                        HStack(spacing: 16) {
                            TextField("模板名称", text: $templateName)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 150)

                            Button {
                                saveAsTemplate(result)
                            } label: {
                                Label("存为模板", systemImage: "doc.badge.plus")
                                    .font(.subheadline)
                            }
                            .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                if scanResult != nil {
                    Button {
                        onFill(scanResult!)
                        dismiss()
                    } label: {
                        Label("填入营养数据", systemImage: "arrow.down.doc")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("识别营养标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $scannedImage)
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { _, newItem in
                guard let item = newItem else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        scannedImage = image
                        scanImage(image)
                    }
                }
            }
            .onChange(of: scannedImage) { _, newImage in
                guard let image = newImage, selectedItem == nil else { return }
                scanImage(image)
            }
            .overlay(
                Group {
                    if showSaveSuccess {
                        Text("已保存模板")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                , alignment: .top
            )
            .animation(.easeInOut, value: showSaveSuccess)
        }
    }

    private func scanImage(_ image: UIImage) {
        isScanning = true
        errorMessage = nil
        scanResult = nil

        guard let cgImage = image.cgImage else {
            errorMessage = "无法处理图片"
            isScanning = false
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "识别失败: \(error.localizedDescription)"
                    isScanning = false
                }
                return
            }

            var allText = ""
            if let observations = request.results as? [VNRecognizedTextObservation] {
                for observation in observations {
                    if let candidate = observation.topCandidates(1).first {
                        allText += candidate.string + "\n"
                    }
                }
            }

            let result = NutritionParser.parse(text: allText)

            DispatchQueue.main.async {
                if let result = result {
                    scanResult = result
                } else {
                    errorMessage = "未能识别到营养数据，请确保照片清晰且包含营养标签"
                }
                isScanning = false
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func saveAsTemplate(_ result: ScannedNutrition) {
        let template = FoodTemplate(
            name: templateName.trimmingCharacters(in: .whitespaces),
            caloriesPer100g: result.calories,
            proteinPer100g: result.protein,
            carbsPer100g: result.carbs,
            fatPer100g: result.fat,
            sodiumPer100g: result.sodium
        )
        modelContext.insert(template)
        templateName = ""
        withAnimation {
            showSaveSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
}

// MARK: - Result Badge
private struct ResultBadge: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: value >= 10 ? "%.0f" : "%.1f", value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text("\(label)(\(unit))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Scanned Nutrition Model
struct ScannedNutrition {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sodium: Double
}

// MARK: - Nutrition Parser
enum NutritionParser {
    static func parse(text: String) -> ScannedNutrition? {
        var calories: Double?
        var protein: Double?
        var carbs: Double?
        var fat: Double?
        var sodium: Double?

        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let cleaned = line.lowercased()
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "∼", with: "")
                .replacingOccurrences(of: "≈", with: "")
                .replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: "：", with: ":")
                .replacingOccurrences(of: " ", with: "")

            // Energy / calories
            if calories == nil {
                calories = extractEnergy(from: cleaned)
            }

            // Protein
            if protein == nil {
                protein = extractValue(from: cleaned, keywords: ["蛋白质", "蛋白", "protein", "protein"])
            }

            // Carbs
            if carbs == nil {
                carbs = extractValue(from: cleaned, keywords: ["碳水", "碳水化合物", "carbohydrate", "carb", "carbs"])
            }

            // Fat
            if fat == nil {
                fat = extractValue(from: cleaned, keywords: ["脂肪", "fat", "totalfat"])
            }

            // Sodium
            if sodium == nil {
                sodium = extractValue(from: cleaned, keywords: ["钠", "sodium", "natrium"])
            }
        }

        // Need at least calories to be useful
        guard calories != nil || protein != nil || carbs != nil || fat != nil else {
            return nil
        }

        return ScannedNutrition(
            calories: calories ?? 0,
            protein: protein ?? 0,
            carbs: carbs ?? 0,
            fat: fat ?? 0,
            sodium: sodium ?? 0
        )
    }

    private static func extractEnergy(from text: String) -> Double? {
        // Try kJ first, then kcal
        let kjPattern = /(\d+\.?\d*)\s*k[jj]/
        let kcalPattern = /(\d+\.?\d*)\s*(?:k?cal|千卡|大卡|kcal)/
        let kjOnlyPattern = /(\d+\.?\d*)\s*千焦/

        // Check kJ
        if let match = text.firstMatch(of: kjPattern) {
            let kj = Double(match.1) ?? 0
            return kj / 4.184
        }
        if let match = text.firstMatch(of: kjOnlyPattern) {
            let kj = Double(match.1) ?? 0
            return kj / 4.184
        }

        // Check kcal
        if let match = text.firstMatch(of: kcalPattern) {
            return Double(match.1)
        }

        return nil
    }

    private static func extractValue(from text: String, keywords: [String]) -> Double? {
        for keyword in keywords {
            // Pattern: keyword followed by digits.digits
            let pattern = try? Regex("\(keyword)[:：]?\\s*(\\d+\\.?\\d*)\\s*(?:g|mg|克|毫)?")
            if let pattern = pattern, let match = text.firstMatch(of: pattern) {
                return Double(match[1].value as! Substring)
            }

            // Alternative: digits followed by keyword
            let altPattern = try? Regex("(\\d+\\.?\\d*)\\s*(?:g|mg)?\\s*\(keyword)")
            if let altPattern = altPattern, let match = text.firstMatch(of: altPattern) {
                return Double(match[1].value as! Substring)
            }
        }
        return nil
    }
}

// MARK: - Camera View (UIKit wrapper)
private struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
