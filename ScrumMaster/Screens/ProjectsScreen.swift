import SwiftUI

struct ProjectsScreen: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var searchText = ""
    @State private var loaderProgress: Float = 0.0
    @ObservedObject private var viewModel: ProjectsViewModel
    
        // remove init ObservedObject, this no source of truth
    init(viewModel: ProjectsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.projectPath) {
            if viewModel.isLoading {
                Loader(progress: $loaderProgress, animated: true)
                    .frame(width: 64, height: 64)
            } else {
                List {
                    Section {
                        ForEach(filteredProjects) { project in
                            NavigationLink(value: project) {
                                ProjectRowView(project: project)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search Projects...")
                .navigationTitle("Projects")
                .navigationDestination(for: Project.self) { project in
                    ProjectDetailScreen(project: project)
                }
                .navigationDestination(for: WorkItem.self) { item in
                    WorkItemDetailView(item: item)
                }
            }
        }
        .task { viewModel.loadProjects() }
    }
    
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return viewModel.projects
        } else {
            return viewModel.projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
