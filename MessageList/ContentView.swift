//
//  ContentView.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $viewModel.favorites) {
                    Text("All Posts").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 70)
                
                Button(action: { viewModel.fetchPosts() }) {
                    VStack {
                        Text("Refresh").foregroundColor(.black)
                        Label("", systemImage: "arrow.clockwise.circle").foregroundColor(.black)
                    }
                }
                
                List {
                    ForEach(viewModel.posts) { item in
                        HStack {
                            NavigationLink {
                                PostDetail(post: item) { post in
                                    viewModel.setAsFavorite(post: post)
                                }
                            } label: {
                                HStack {
                                    Text(item.name ?? "")
                                }
                            }
                        }
                    }
                    .onDelete(perform: { offsets in viewModel.deleteItems(offsets: offsets) })
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 10){
                        Text("Messages List")
                            .font(Font.system(size: 25).bold())
                            .font(.title)
                    }
                }
            }
        }.onAppear {
            viewModel.fetchPosts()
        }
    }

}

struct PostDetail: View {
    var post: PostCD
    var addToFavorites: (_ post: PostCD) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(post.name ?? "")
                .font(.title)
                .foregroundColor(.primary)
            Text(post.body ?? "")
                .foregroundColor(.secondary)
            VStack(alignment: .leading) {
                Text("email: \(post.email ?? "")")
                    .foregroundColor(.accentColor)
                Text("ID: \(post.postId)")
                    .foregroundColor(.primary)
            }
            Spacer()
        }.padding(.horizontal, 40)
            .toolbar {
                ToolbarItem {
                    Button(action: { addToFavorites(post) }) {
                        if post.isFavorite {
                            Label("", systemImage: "star.fill")
                        } else {
                            Label("", systemImage: "star")
                        }
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
