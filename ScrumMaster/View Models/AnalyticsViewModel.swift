import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var analyticsDetails: [AnalyticsDetails] = []
    @Published var recentProjects: [Project] = []
    @Published var isLoading: Bool = false
    let analyticsService: AnalyticsService
    let projectService: ProjectService

    init(analyticsService: AnalyticsService, projectService: ProjectService) {
        self.analyticsService = analyticsService
        self.projectService = projectService
    }

    func loadAnalytics() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            let details = await self.analyticsService.fetchAnalyticsDetails()
            let projects = await self.projectService.fetchProjects()
            self.analyticsDetails = details
            self.recentProjects = projects
            self.isLoading = false
        }
    }
}
