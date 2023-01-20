//
//  ViewController.swift
//  ExHealthKit
//
//  Created by sonjuhyeong on 2023/01/19.
//

import UIKit
import SnapKit
import HealthKit
import RxSwift

class ViewController: UIViewController {
    
    
    let healthStore = HKHealthStore()
    var disposeBag = DisposeBag()
    
    let heathKitView = HeathKitView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = heathKitView
        accessStepCount()
    }
    
    func accessStepCount() {
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]

        // 디바이스에서 HealthKit 사용 가능 여부 확인
        if HKHealthStore.isHealthDataAvailable() {
            // 권한 요청 화면 팝업 여부(처음 1회만)
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if success {
                        self.getSteps { (result) in
                            DispatchQueue.main.async { [self] in
                                let steps = String(result)
                                heathKitView.todayStepsLabel.text = steps
                            }
                        }
                    } else {
                        print("not popup authorization view")
                    }
                }
            }
        } else {
            print("")
        }
        
    }
    
    private func getSteps(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: nil,
                                                options: [.cumulativeSum],
                                                anchorDate: startOfDay,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
            var resultCount = 0.0
            result!.enumerateStatistics(from: startOfDay, to: now, with: { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    resultCount = sum.doubleValue(for: HKUnit.count())
                }
                
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            })
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        healthStore.execute(query)
    }
}
