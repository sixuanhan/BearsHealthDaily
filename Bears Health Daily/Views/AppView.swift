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
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(Tab.home)
                
                FriendsView()
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                    .tag(Tab.friends)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
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
