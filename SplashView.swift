//
//  SplashView.swift
//  RegistroDeHoras
//
//  Created by Eduardo Alencar on 31/08/2025.
//

import Foundation
import SwiftUI

struct SplashView: View {
    let progress: Double   // 0.0 ... 1.0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("REGISTRO DE HORAS")
                    .font(.system(size: 28, weight: .black, design: .rounded))

                Image("AppLogo") // sua logo nos Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                // Barra de progresso com porcentagem (opcional)
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .frame(width: 220)
                    Text("\(Int(progress * 100))%")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer().frame(height: 12)

                Text("Criado por EduDev👨🏽‍💻")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
