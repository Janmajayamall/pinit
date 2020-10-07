//
//  ReportUserView.swift
//  pinit
//
//  Created by Janmajaya Mall on 8/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ReportUserView: View {
    
    @State var reportedUsername: String = ""
    @State var reason: String = ""
    @State var fakeHeightBinding: CGFloat = 0
    
    var body: some View {
        GeometryReader {geometryProxy in
            VStack{
                HStack{
                    Text("Report a offensive user/activity")
                        .font(Font.custom("Avenir", size: 20)
                        .bold())
                        .foregroundColor(Color.black)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                VStack{
                    HStack{
                        Text("Username of offensive user").bold()
                        Spacer()
                    }
                    HStack{
                        TextField("", text: self.$reportedUsername, onCommit: {self.hideKeyboard()})
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
                        Text("Your reason for reporting")
                            .font(Font.custom("Avenir", size: 15).bold())
                            .foregroundColor(Color.black)
                        Spacer()
                    }
                    HStack{
                        UIKitUITextView(text: self.$reason, textViewHeight: self.$fakeHeightBinding, textColor: UIColor.black, textSize: 15, isFirstResponder: false)
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .frame(height: geometryProxy.size.height*0.25)
                .background(Color.smokeColor)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
                
                ZStack{
                    VStack{
                        Text("To contact our team regarding any concern.")
                        HStack{
                            Text("Feel free to")
                            Text("email us.")
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    UIApplication.shared.open(URL(string:"mailto:finchit.help@gmail.com")!)
                            }
                        }
                        Spacer()
                    }.font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                                        
                    VStack{
                        Spacer()
                        Button(action: {
                            self.hideKeyboard()
                        }, label: {
                            Text("Report")
                        })
                            .padding(.bottom, 5)
                            .buttonStyle(SecondaryColorButtonStyle())
                            .applyKeyboardAwarePadding()
                    }
                }
                
            }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                .background(Color.white)
                .onTapGesture {
                    self.hideKeyboard()
            }
        }
    }
}

struct ReportUserView_Previews: PreviewProvider {
    static var previews: some View {
        ReportUserView()
    }
}
