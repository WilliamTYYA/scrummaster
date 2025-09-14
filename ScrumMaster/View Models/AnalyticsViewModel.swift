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
        Task {
            self.isLoading = true
            self.analyticsDetails = await self.analyticsService.fetchAnalyticsDetails()
            self.recentProjects   = await self.projectService.fetchProjects()
            self.isLoading = false
        }
    }
}
