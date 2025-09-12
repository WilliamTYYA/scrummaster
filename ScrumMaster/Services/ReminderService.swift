/**
 # Task #2

 ## Task
 Fix the concurrency implementation in `DefaultReminderService` to correctly handle parallel reminder fetching using three different paradigms:

 1. Callback-Based (`fetchReminders`)
 2. Combine (`remindersPublisher`)
 3. Swift Concurrency (`fetchRemindersAsync`)

 Each implementation must:
 - Fetch three pages of reminders in parallel
 - Return a total of 12 reminders
 - Pass all associated tests in `DefaultReminderServiceTests`

 ## Success Criteria
 - All tests in `DefaultReminderServiceTests` pass successfully
 - Each method fetches exactly three pages concurrently
 - All methods return 12 unique reminders
 - Each implementation uses its designated concurrency paradigm
 - Each method has a unique implementation

 ## Important Notes
 - Some files are marked as "DO NOT MODIFY" - these must remain unchanged
 - In certain files, only specific sections are marked as protected with clear comments
 - Modifying any protected code (either entire files or marked sections) will result in automatic task failure
 - Work with the existing code structure; do not rewrite from scratch
 - Stay within each method's designated paradigm (Callbacks/Combine/Swift Concurrency)
 - Do not call other methods of the class within implementations
 */

import Combine
import Foundation

final class DefaultReminderService: ReminderService {
    private let dataSource: ReminderDataSource

    init(dataSource: ReminderDataSource) {
        self.dataSource = dataSource
    }

        // inside DefaultReminderService
    func fetchReminders(completion: @escaping ([Reminder]) -> Void) {
        let parallelQ  = DispatchQueue(label: "reminders.parallel", attributes: .concurrent)
        let aggregateQ = DispatchQueue(label: "reminders.aggregate") // serial aggregator
        
        let group = DispatchGroup()
        var all: [Reminder] = []
        
        for _ in 0..<3 {
            group.enter()
            parallelQ.async { [dataSource] in
                dataSource.fetchReminders { page in
                        // Append on a serial queue to avoid races
                    aggregateQ.async {
                        all.append(contentsOf: page)
                        group.leave()
                    }
                }
            }
        }
        
            // Fire when all three have appended and called leave()
        group.notify(queue: aggregateQ) {
            let result = all                 // read on same serial queue
            DispatchQueue.main.async {       // deliver on main (UI-safe)
                completion(result)
            }
        }
    }

    func remindersPublisher() -> AnyPublisher<[Reminder], Never> {
            // One page as a publisher (wrapped from the callback API)
        func page() -> AnyPublisher<[Reminder], Never> {
            Deferred {
                Future<[Reminder], Never> { [weak self] promise in
                    guard let self = self else { return promise(.success([])) }
                    self.dataSource.fetchReminders { reminders in
                        promise(.success(reminders))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        
            // Run 3 pages in parallel, wait for all, then flatten
        return Publishers.MergeMany([page(), page(), page()])
            .collect(3)                  // wait until all 3 pages emit
            .map { $0.flatMap { $0 } }   // [[Reminder]] -> [Reminder]
            .eraseToAnyPublisher()
        
            //        let p1 = page()
            //        let p2 = page()
            //        let p3 = page()
            //
            //        return Publishers.Zip3(p1, p2, p3)
            //            .map { $0 + $1 + $2 }        // combine results
            //            .eraseToAnyPublisher()
    }

    func fetchRemindersAsync() async -> [Reminder] {
        var reminders: [Reminder] = []

        await withTaskGroup(of: [Reminder].self) { group in
            for _ in 1...3 {
                group.addTask {
                    return await self.dataSource.fetchReminders()
                }
            }
            for await next in group {
                reminders.append(contentsOf: next)
            }
        }
        return reminders
    }
}
/*
 *****************************************************************************
 *                                                                           *
 *     >>>>>>>>>>>  DO NOT MODIFY ANYTHING FROM THIS POINT  <<<<<<<<<<<      *
 *                                                                           *
 *                YOU WILL AUTOMATICALLY FAIL IF YOU DO!                     *
 *                                                                           *
 *****************************************************************************
 */

protocol ReminderService: AnyObject {
    func fetchReminders(completion: @escaping ([Reminder]) -> Void)
    func remindersPublisher() -> AnyPublisher<[Reminder], Never>
    func fetchRemindersAsync() async -> [Reminder]
}

protocol ReminderDataSource: AnyObject {
    func fetchReminders(completion: @escaping ([Reminder]) -> Void)
    func fetchReminders() async -> [Reminder]
}

