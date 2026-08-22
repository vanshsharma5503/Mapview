//
//  MainStateView.swift
//  MapStory
//
//  Created by Vansh Sharma on 10/07/26.
//

import SwiftUI

struct MainStateView: View {
    var body: some View {
        ZStack{
            Color("Bg")
                .ignoresSafeArea()
            VStack{
                Text("Explore India")
                    .font(.system(size: 35))
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                ScrollView{
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 350, height: 200)
                }
            }
        }
    }
}

#Preview {
    MainStateView()
}
