import Combine

@MainActor
class AnalyticsDetailsViewModel: ObservableObject {
    @Published var recentProjects: [Project] = []
    @Published var isLoading: Bool = false
    let projectService: ProjectService

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    func loadRecentProjects() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            let projects = await self.projectService.fetchProjects()
            self.recentProjects = projects
            self.isLoading = false
        }
    }
}
