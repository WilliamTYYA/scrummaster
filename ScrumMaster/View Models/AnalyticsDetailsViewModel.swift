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
        Task {
            self.isLoading      = true
            self.recentProjects = await self.projectService.fetchProjects()
            self.isLoading      = false
        }
    }
}
