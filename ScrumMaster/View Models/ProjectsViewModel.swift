import Combine

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    let projectService: ProjectService

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    func loadProjects() {
        Task {
            self.isLoading = true
            self.projects  = await self.projectService.fetchProjects()
            self.isLoading = false
        }
    }
}
