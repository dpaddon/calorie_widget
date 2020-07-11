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
    var cornerRadius = 1
    
    var body: some View {
        VStack {

            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                    .frame(width: 10, height: 35).foregroundColor(.black)
                RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                    .frame(width: 10, height: value).foregroundColor(.white)
                
            }.padding(.bottom, 8)
        }
        
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
