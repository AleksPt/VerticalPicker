import SwiftUI

struct CustomPicker: View {
    var isLeft: Bool
    @Binding var edit: Bool
    @Binding var selectedValue: String
    let values: [String]
    let title: String
    @State private var scrollID: String? = nil
    @State private var isInitialLoad = true
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: edit ? 5 : 0) {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: -5) {
                            ForEach(values, id: \.self) { value in
                                Text(value)
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundStyle(selectedValue == value ? Color.primary : .gray)
                                    .opacity(selectedValue == value ? 1 : (edit ? 1 : 0000.01))
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
                                    .id(value)
                                    .scrollTransition(axis: .vertical) { effect, phase in
                                        effect.scaleEffect((phase.isIdentity ? 1.0 : 0.7))
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.vertical, 30)
                    .scrollPosition(id: $scrollID, anchor: .center)
                    .allowsHitTesting(edit)
                    .onAppear {
                        scrollID = selectedValue
                        impactFeedback.prepare()
                        DispatchQueue.main.async {
                            proxy.scrollTo(selectedValue, anchor: .center)
                        }
                    }
                    .onChange(of: scrollID) { oldValue, newValue in
                        if let newValue, newValue != oldValue {
                            selectedValue = newValue
                            
                            // Пропускаем звук при первой загрузке
                            if !isInitialLoad {
                                // Тактильная обратная связь (работает только на реальном устройстве)
                                impactFeedback.impactOccurred()
                            } else {
                                isInitialLoad = false
                            }
                        }
                    }
                }
            }
            .frame(width: 40, height: 100)
            
            Text(title).font(.system(size: 25)).bold()
                .foregroundStyle(.gray)
        }
        .padding(.trailing, 3)
        .padding(edit ? .horizontal : .leading, 10)
        .frame(height: edit ? 105 : 60).clipped()
        .background(Color.gray.quinary, in: shape(edit: edit, isLeft: isLeft))
    }
    
    private func shape(edit: Bool, isLeft: Bool) -> UnevenRoundedRectangle {
        if edit {
            return UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 12,
                bottomTrailingRadius: 12,
                topTrailingRadius: 12
            )
        } else {
            if isLeft {
                return UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            } else {
                return UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            }
        }
    }
}

struct ContentView: View {
    @State private var edit = false
    @State private var hour = "20"
    @State private var minute = "30"
    
    private let Hr = (0...24).map { String(format: "%01d", $0) }
    private let Min = (0...60).map { String($0) }
    
    var body: some View {
        HStack(spacing: edit ? 20: 0) {
            CustomPicker(
                isLeft: true,
                edit: $edit,
                selectedValue: $hour,
                values: Hr,
                title: "Hr"
            )
            
            CustomPicker(
                isLeft: false,
                edit: $edit,
                selectedValue: $minute,
                values: Min,
                title: "Min"
            )
            
            ZStack {
                if edit {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 25)).bold()
                        .padding(10)
                        .background(Circle().fill(Color.green.gradient))
                        .transition(.blurReplace.combined(with: .offset(x: -35)))
                } else {
                    Image(systemName: "slider.vertical.3")
                        .foregroundStyle(.primary)
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Circle().fill(Color.yellow.gradient))
                        .transition(.blurReplace.combined(with: .offset(x: 35)))
                }
            }
            .padding(.horizontal, 20)
            .frame(height: edit ? 105 : 60)
            .background(
                Color.gray.quinary,
                in: UnevenRoundedRectangle(
                    topLeadingRadius: edit ? 12 : 0,
                    bottomLeadingRadius: edit ? 12 : 0,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 12
                )
            )
            .onTapGesture {
                withAnimation(!edit ? .smooth(duration: 0.5, extraBounce: 0.5) : .smooth) {
                    edit.toggle()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
