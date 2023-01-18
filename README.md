# ExHealthKit

## HealthKit
>사용자의 개인 정보 및 제어를 유지하면서 건강 및 피트니스 데이터의 엑세스하고 공유할 수 있는 프레임워크

### HKHealthStore
- HealthKit에서 관리하는 모든 데이터의 엑세스 포인트
- HealthKit 데이터를 공유하거나 읽을 수 있는 권한을 요청
- 권한이 부여되면 HealthKitStore를 사용하여 스토어에 새 샘플을 저장하거나 저장한 샘플들을 관리 가능
- HKHealthStore를 사용하여 쿼리를 시작, 중지 및 관리 가능

- **Accessing healthKit**
```
// 앱의 승인 상태를 반환
func authorizationStatus(for: HKObjectType) -> HKAuthorizationStatus

// 현재 디바이스에서 HealthKit을 사용 가능 여부
class func isHealthDataAvailable() -> Bool

// 지정된 데이터 유형을 저장하고 읽을 수 있는 권한 요청
func requestAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?, completion: (Bool, Error?) -> Void)

// 지정된 데이터 유형을 저장하고 읽을 수 있는 권한을 비동기적으로 요청
func requestAuthorization(toShare: Set<HKSampleType>, read: Set<HKObjectType>)
```

- **Querying HealthKit data**
```
// 제공된 쿼리 실행 시작
func execute(_ query: HKQuery)

// 쿼리 실행 중지
func stop(_ query: HKQuery)
```

### HKStatisticsCollectionQuery
- 고정 시간 간격 동안 여러 통계 쿼리를 수행하는 쿼리

- **Creating Statistics Collection Objects**
```
// 일정 시간 간격 동안 지정된 계산을 수행하도록 
init(quantityType: HKQuantityType, // 검색할 샘플 유형(ex. stepCount)
quantitySamplePredicate: NSPredicate?, // 쿼리 반환 결과
options: HKStatisticsOptions, // 수행된 통계 계산 병합 방법
anchorDate: Date, // 시간 간격의 시작 시간
intervalComponents: DateComponents) // 시간 간격
```

- **Getting and Setting Results Handlers**
```
// 쿼리의 초기 결과에 대한 핸들러
var initialResultsHandler: ((HKStatisticsCollectionQuery, HKStatisticsCollection?, Error?) -> Void)? { get set }

// HealthKit Store 업데이트를 모니터링 하기 위한 핸들러
var statisticsUpdateHandler: ((HKStatisticsCollectionQuery, HKStatistics?, HKStatisticsCollection?, Error?) -> Void)? { get set }
```

- **Getting Property Data**
```
// 시간 간격 기준 날짜
var anchorDate: Date { get }

// 시간 간격
var intervalComponents: DateComponents { get }

// 데이터 병합 방식
var options: HKStatisticsOptions { get }
```

### HKStatisticsCollection
- 지정된 시간 간격 동안 계산된 통계 모음 결과를 관리하는 객체
- **Accessing Statistics Collections**
```
// 전체 통계 리스트 반환
func statistics() -> [HKStatistics]

// 지정된 날짜가 포함된 통계 반환
func statistics(for: Date) -> HKStatistics?

// 지정 시간 구간에 대한 통계 리스트 반환
func enumerateStatistics(from: Date, to: Date, with: (HKStatistics, UnsafeMutablePointer<ObjCBool>) -> Void)
```
