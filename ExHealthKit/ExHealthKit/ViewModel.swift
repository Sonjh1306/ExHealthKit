//
//  ViewModel.swift
//  ExHealthKit
//
//  Created by sonjuhyeong on 2023/01/20.
//

import Foundation
import HealthKit
import RxSwift
import RxCocoa

protocol DefaultViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    var disposeBag: DisposeBag { get set }
}

enum HealthKitError: String, Error {
    case notRequestAuthorization = "Not Pop Up Authorization View"
    case canNotGetSteps = "Can't Get Steps"
    case canNotUseHealthKit = "Can't Use HealthKit"
}

final class ViewModel: DefaultViewModelProtocol {
    
    struct Input {
        let onLoad: PublishSubject<Void> = PublishSubject<Void>()
    }
    
    struct Output {
        let stepCount: PublishRelay<String> = PublishRelay<String>()
        let errorMessage: PublishRelay<String> = PublishRelay<String>()
    }
    
    var input: Input = Input()
    var output: Output = Output()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let healthStore = HKHealthStore()
    
    init() {
        input.onLoad
            .flatMap{ _ in self.accessStepCount()}
            .bind { [weak self] (result) in
                switch result {
                case .success(let result):
                    self?.output.stepCount.accept(result)
                case .failure(let error):
                    self?.output.errorMessage.accept(error.rawValue)
                }
            }.disposed(by: disposeBag)
    }
    
    private func accessStepCount() -> Observable<Result<String, HealthKitError>> {

        return Observable.create { (observer) in
            let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]

            // 디바이스에서 HealthKit 사용 가능 여부 확인
            if HKHealthStore.isHealthDataAvailable() {
                // 권한 요청 화면 팝업 여부(처음 1회만)
                self.healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in
                    if error != nil {
                        observer.onNext(.failure(.notRequestAuthorization))
                    } else {
                        if success {
                            self.getSteps { (result) in
                                observer.onNext(.success(String(result)))
                            }
                        } else {
                            observer.onNext(.failure(.canNotGetSteps))
                        }
                    }
                }
            } else {
                observer.onNext(.failure(.canNotUseHealthKit))
            }
            return Disposables.create()
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
