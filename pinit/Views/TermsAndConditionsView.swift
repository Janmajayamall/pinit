//
//  TermsAndConditionsView.swift
//  pinit
//
//  Created by Janmajaya Mall on 20/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct TermsAndConditionsView: View {
    
    @Binding var isOpen: Bool
    
    let termsAndConditionsText: String = """
    This End User License Agreement (“Agreement”) is between you and FinchIt and governs use of this app made available through the Apple App Store. By installing the FinchIt App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the FinchIt App \n

    In order to ensure FinchIt provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content.If you see inappropriate content, please use the “Report” feature found under each post. \n

    1. Parties \n
    This Agreement is between you and FinchIt only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. FinchIt, not Apple, is solely responsible for the FinchIt App and its content. \n

    2. Privacy \n
    FinchIt may collect and use information about your usage of the FinchIt App, including certain types of information from and about your device. FinchIt may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the FinchIt App. \n

    3. Limited License \n
    FinchIt grants you a limited, non-exclusive, non-transferable, revocable license to use the FinchIt App for your personal, non-commercial purposes. You may only use the FinchIt App on Apple devices that you own or control and as permitted by the App Store Terms of Service. \n

    4. Age Restrictions \n
    By using the FinchIt App, you represent and warrant that \n
    (a) you are 17 years of age or older and you agree to be bound by this Agreement; (b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the FinchIt App does not violate any applicable law or regulation. Your access to the FinchIt App may be terminated without warning if FinchIt believes, in its sole discretion, that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child’s use of the FinchIt App, you agree to be bound by this Agreement in respect to your child’s use of the FinchIt App. \n

    5. Objectionable Content Policy \n
    Content may not be submitted to FinchIt, who will moderate all content and ultimately decide whether or not to post a submission to the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: (i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (v) gambling, including without limitation, any online casino, sports books, bingo or poker. \n

    6. Warranty \n
    FinchIt disclaims all warranties about the FinchIt App to the fullest extent permitted by law. To the extent any warranty exists under law that cannot be disclaimed, FinchIt, not Apple, shall be solely responsible for such warranty. \n

    7. Maintenance and Support \n
    FinchIt does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, FinchIt, not Apple, shall be obligated to furnish any such maintenance or support. \n

    8. Product Claims \n
    FinchIt, not Apple, is responsible for addressing any claims by you relating to the FinchIt App or use of it, including, but not limited to: (i) any product liability claim; (ii) any claim that the FinchIt App fails to conform to any applicable legal or regulatory requirement; and (iii) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims. \n

    9. Third Party Intellectual Property Claims \n
    FinchIt shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the FinchIt App. To the extent FinchIt is required to provide indemnification by applicable law, FinchIt, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the FinchIt App or your use of it infringes any third party intellectual property right. \n
    """
    
    var body: some View {
            ScrollView{
                Text("FinchIt App End User License Agreement")
                    .font(Font.custom("Avenir", size: 20).bold())
                    .foregroundColor(.primaryColor)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.center)
                Text(self.termsAndConditionsText)
                    .font(Font.custom("Avenir", size: 15))
                    .lineLimit(nil)
                    .padding(.bottom, 10)
                
                Button(action: {
                    self.isOpen = false
                }, label: {
                    Text("Done")
                })
                    .buttonStyle(SecondaryColorButtonStyle())
                    .padding(.bottom, 10)
            }
            .foregroundColor(Color.black)
            .multilineTextAlignment(.leading)
            .padding(15)
            .background(Color.white)
    }
}
//
//struct TermsAndConditionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TermsAndConditionsView(isOpen: )
//    }
//}
