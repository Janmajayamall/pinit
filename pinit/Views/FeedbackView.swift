//
//  FeedbackView.swift
//  pinit
//
//  Created by Janmajaya Mall on 8/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    @State var topic: String = ""
    @State var description: String = ""
    @State var fakeHeightBinding: CGFloat = 0
    
    @Binding var isOpen: Bool
    
    var body: some View {
        GeometryReader {geometryProxy in
            VStack{
                HStack{
                    Text("Tell us how can we improve?")
                        .font(Font.custom("Avenir", size: 20)
                            .bold())
                        .foregroundColor(Color.black)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                VStack{
                    HStack{
                        Text("What is it about?").bold()
                        Spacer()
                    }
                    HStack{
                        TextField("", text: self.$topic, onCommit: {self.hideKeyboard()})
                    }
                }
                .font(Font.custom("Avenir", size: 15))
                .foregroundColor(Color.black)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(Color.smokeColor)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                
                
                VStack{
                    HStack{
                        Text("Your feedback goes here")
                            .font(Font.custom("Avenir", size: 15).bold())
                            .foregroundColor(Color.black)
                        Spacer()
                    }
                    HStack{
                        UIKitUITextView(text: self.$description, textViewHeight: self.$fakeHeightBinding, textColor: UIColor.black, textSize: 15, isFirstResponder: false)
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .frame(height: geometryProxy.size.height*0.25)
                .background(Color.smokeColor)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                
                Spacer()
                
                Button(action: {
                    self.sendUserFeedback()
                    self.hideKeyboard()
                    self.isOpen = false
                    //                    self.
                }, label: {
                    Text("Submit")
                })
                    .padding(.bottom, 5)
                    .buttonStyle(SecondaryColorButtonStyle())
                    .applyKeyboardAwarePadding()
                
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }.background(Color.white)
            .onDisappear {
                self.isOpen = false
        }
        
    }
    
    func sendUserFeedback() {
        guard self.topic.count > 0 || self.description.count > 0 else {return}
        
        // generate request model
        let model = RequestFeedbackModel(title: self.topic, description: self.description)
        
        // notify
        NotificationCenter.default.post(name: .additionalDataServiceDidRequestFeedbackModel, object: model)
    }
}

//struct FeedbackView_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedbackView(, isOpen: )
//    }
//}
