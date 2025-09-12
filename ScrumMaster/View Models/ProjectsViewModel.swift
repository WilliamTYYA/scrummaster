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
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            let fetchedProjects = await self.projectService.fetchProjects()
            self.projects = fetchedProjects
            self.isLoading = false
        }
    }
}
