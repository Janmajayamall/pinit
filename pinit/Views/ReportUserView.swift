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
    
    @Binding var isOpen: Bool
    
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
                        Text("Note: Our team @ FinchIt will respond to your report within 24 hours. We might also contact you for further information, if needed.").multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                        Text("To contact our team regarding any concern")
                        HStack{
                            Text("feel free to")
                            Text("email us.")
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    UIApplication.shared.open(URL(string:"mailto:finchit.help@gmail.com")!)
                            }
                        }
                        Spacer()
                    }.font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
                    
                    VStack{
                        Spacer()
                        Button(action: {
                            self.sendUserReport()
                            self.hideKeyboard()
                            self.isOpen = false
                        }, label: {
                            Text("Report")
                        })
                            .padding(.bottom, 5)
                            .buttonStyle(SecondaryColorButtonStyle())
                            .applyKeyboardAwarePadding()
                    }
                }
                
            }
        }.background(Color.white)
            .onTapGesture {
                self.hideKeyboard()
        }
    }
    
    func sendUserReport() {
        guard self.reportedUsername.count > 0 else {return}
        let requestModel = RequestReportUserModel(reportedUsername: self.reportedUsername, reason: self.reason)
        NotificationCenter.default.post(name: .additionalDataServiceDidRequestReportUserModel, object: requestModel)
    }
}

//struct ReportUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportUserView(, isOpen: )
//    }
//}
