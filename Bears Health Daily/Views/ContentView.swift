//
//  ContentView.swift
//
//  Created by xuanxuan on 3/14/25.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isLoading = true
    @State private var randomQuote: String = ""
    @State private var randomStatistic: String = ""

    let famousQuotes = [
        "“健康才是真正的财富，而不是金银财宝”。\n—— 圣雄甘地",
        "“照顾好你的身体。这是你唯一的生存之地”。\n—— 吉姆-罗恩",
        "“健康的外表始于内心”。\n—— 罗伯特-乌里希",
        "“拥有健康的人就拥有希望，拥有希望的人就拥有一切”。\n—— 阿拉伯谚语"
    ]

    let medicalStatistics = [
        "在高血压患者中，坚持正确服药可使中风风险降低 35-40%，心脏病风险降低 20-25%。\n——世界卫生组织",
        "约有 63% 的患者表示，他们漏服药物仅仅是因为忘记了。\n——美国药剂师协会",
        "数字药物提醒功能已被证明可将服药率提高 75%，帮助人们坚持治疗。\n——医学互联网研究杂志，2020 年",
        "按医嘱服药的慢性病患者的住院率比不按医嘱服药的患者低 45%。\n——美国管理保健杂志》，2019年"
    ]

    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Image("wallpaper")
                        .resizable()
                        .opacity(0.5)
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)

                    VStack(alignment: .center) {
                        Text(randomQuote)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 30)
                        
                        Text(randomStatistic)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 20)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                    .padding()
                }
            } else if viewModel.userSession != nil {
                AppView()                    
                .transition(.slide)
            } else {
                LoginView()
                .padding()
            }
        }
        .onAppear {
            Task {
                self.randomQuote = famousQuotes.randomElement() ?? ""
                self.randomStatistic = medicalStatistics.randomElement() ?? ""
                await viewModel.fetchUser()
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
