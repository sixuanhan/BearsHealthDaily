//
//  AppView.swift
//
//  Created by xuanxuan on 3/15/25.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    enum Tab {
        case home
        case friends
        case profile
    }

    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Label("主页", systemImage: "house.fill")
                    }
                    .tag(Tab.home)
                
                FriendsView()
                    .tabItem {
                        Label("好友", systemImage: "person.2.fill")
                    }
                    .tag(Tab.friends)
                
                ProfileView()
                    .tabItem {
                        Label("账号", systemImage: "person.fill")
                    }
                    .tag(Tab.profile)
            }
        }
    }
}

#Preview {
    AppView()
    .environmentObject(AuthViewModel())
}
