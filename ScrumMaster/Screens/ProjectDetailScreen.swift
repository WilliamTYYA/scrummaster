import SwiftUI

struct ProjectDetailScreen: View {
    let project: Project

    var body: some View {
        List {
            Section("Items") {
                ForEach(project.items) { item in
                    NavigationLink(value: item) {
                        WorkItemRowView(item: item)
                    }
                }
            }
        }
        .navigationTitle(project.name)
    }
}
