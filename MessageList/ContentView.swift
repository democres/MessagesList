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
            List {
                ForEach(viewModel.posts) { item in
                    NavigationLink {
                        PostDetail(post: item)
                    } label: {
                        HStack {
                            Button(action: { viewModel.addItem() }) {
                                Label("Add", systemImage: "plus")
                            }
                            Text(item.name)
                        }
                    }
                }
                .onDelete(perform: { offsets in viewModel.deleteItems(offsets: offsets) })
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { viewModel.addItem() }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }.onAppear {
            viewModel.fetchPosts()
        }
    }

}

struct PostDetail: View {
    var post: PostModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(post.name)
                .font(.title)
                .foregroundColor(.primary)
            Text(post.body)
                .foregroundColor(.secondary)
            VStack(alignment: .leading) {
                Text("Email: \(post.email)")
                    .foregroundColor(.accentColor)
                Text("ID: \(post.postId)")
                    .foregroundColor(.primary)
            }
            Spacer()
        }.padding(.horizontal, 40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
