import SwiftUI
import Combine

@MainActor
class MainCoordinator: ObservableObject {
    @Published var projectPath = NavigationPath()
    @Published var analyticsPath = NavigationPath()

    func navigateToProject(_ project: Project) {
        projectPath.append(project)
    }

//    func navigateToWorkItem(_ item: WorkItem) {
//        path.append(item)
//    }

    func navigateToAnalytics(_ details: AnalyticsDetails) {
        analyticsPath.append(details)
    }

    func popToProjectRoot() {
        projectPath.removeLast(projectPath.count)
    }
    
    func popToAnalyticsRoot() {
        analyticsPath.removeLast(analyticsPath.count)
    }
}
