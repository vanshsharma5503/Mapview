//
//  NatureBackground.swift
//  MapStory
//
//  Created by Vansh Sharma on 04/09/26.
//


import SwiftUI

struct NatureBackground: View {

    var body: some View {

        ZStack {

            // Base
            Color("Bg")
                .ignoresSafeArea()

            // Warm glow
            Circle()
                .fill(.orange.opacity(0.10))
                .frame(width: 320)
                .blur(radius: 45)
                .offset(
                    x: -150,
                    y: -300
                )

            // Nature green glow
            Circle()
                .fill(.green.opacity(0.09))
                .frame(width: 300)
                .blur(radius: 45)
                .offset(
                    x: 170,
                    y: -120
                )

            // Sky glow
            Circle()
                .fill(.blue.opacity(0.07))
                .frame(width: 340)
                .blur(radius: 50)
                .offset(
                    x: 130,
                    y: 420
                )

            // Small decorative dots
            Circle()
                .fill(.orange.opacity(0.16))
                .frame(width: 9, height: 9)
                .offset(x: -155, y: -80)

            Circle()
                .fill(.green.opacity(0.14))
                .frame(width: 7, height: 7)
                .offset(x: 150, y: 70)

            Circle()
                .fill(.yellow.opacity(0.18))
                .frame(width: 12, height: 12)
                .offset(x: -120, y: 330)
        }
    }
}
