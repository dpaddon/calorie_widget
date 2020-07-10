//
//  BarView.swift
//  Calorie Widget
//
//  Created by Daniel Paddon on 11/07/2020.
//

import Foundation
import SwiftUI

struct BarView: View{

    var value: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        VStack {

            ZStack (alignment: .bottom) {
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .frame(width: 30, height: 200).foregroundColor(.black)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: value).foregroundColor(.white)
                
            }.padding(.bottom, 8)
        }
        
    }
}
