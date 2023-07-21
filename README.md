# 🏦 은행창구 매니저

## 📖 목차
1. [소개](#-소개)
2. [팀원](#-팀원)
3. [타임라인](#-타임라인)
4. [시각화된 프로젝트 구조](#-시각화된-프로젝트-구조)
5. [실행 화면](#-실행-화면)
6. [고민한 점](#-고민한-점)
7. [트러블 슈팅](#-트러블-슈팅)
8. [참고 링크](#-참고-링크)

</br>

## 🍀 소개

minsup, hoon 팀이 만든 은행창구 매니저 콘솔 및 UI앱입니다. 업무를 수행하는 은행원의 수를 정하여 각 은행원이 고객의 업무를 수행합니다. 고객 추가 버튼을 누르면 10명의 고객이 생성되어 대기중 스택에 추가되고 해당 고객의 업무를 스레드가 처리하기 시작하면 업무중 스택으로 옮겨지게 됩니다. 스레드가 업무를 마치면 업무중 스택에서 제거됩니다. 총 업무시간을 기록하여 상단에 위치한 레이블에 표시합니다. 초기화 버튼을 누르면 업무 중이던 작업, 고객, 총 업무시간이 초기화 됩니다.

* 주요 개념: `Concurrent Programming`, `GCD`, `Operation`, `Queue`, `LinkedList`, `Unit Test`, `Timer`, `CustomView`

</br>

## 👨‍💻 팀원
|  minsup | hoon |
| :--------: | :--------: |
| <Img src = "https://avatars.githubusercontent.com/u/79740398?v=4" width="200"> |<Img src="https://i.imgur.com/zXoi5OC.jpg" width="200" height="200"> |
|[Github Profile](https://github.com/agilestarskim) |[Github Profile](https://github.com/Hoon94) |

</br>

## ⏰ 타임라인
|날짜|내용|
|:--:|--|
|2023.07.10.| Node, LinkedList, Queue 타입 생성 | 
|2023.07.11.| Node, LinkedList, Queue 테스트 작성 |
|2023.07.14.| Customer, BankManger, Bank 타입 생성 |
|2023.07.17.| Task 타입 생성, GCD를 통한 동시 업무 수행 |
|2023.07.18.| DispatchQueue에서 Operation으로 변경 |
|2023.07.19.| 스택뷰에 customer정보 삽입 삭제 구현 |
|2023.07.21.| Timer 구현 및 리팩토링, Delegate패턴을 통한 VC와 Model 통신|

</br>

## 👀 시각화된 프로젝트 구조

### ℹ️ File Tree
    BankManagerUIApp
    ├── Application
    │   ├── AppDelegate.swift
    │   └── SceneDelegate.swift
    ├── Controller
    │   └── BankManagerViewController.swift
    ├── Model
    │   ├── Bank
    │   │   ├── Bank.swift
    │   │   ├── Customer.swift
    │   │   └── TimerManager.swift
    │   └── Queue
    └── View
        ├── BankManagerView.swift
        └── CustomerCellView.swift
        
    BankMangerConsoleApp    
    ├── Bank
    │   ├── Bank.swift
    │   ├── BankManager.swift
    │   └── Customer.swift
    ├── Queue
    │   ├── LinkedList.swift
    │   ├── Node.swift
    │   └── Queue.swift
    └── main.swift



### 📐 Diagram
<p align="center">
<img width="500" src="https://hackmd.io/_uploads/rkeCWUCY3.jpg">
</p>


## 💻 실행 화면 

### 🖥️ ConsoleApp

| 은행 개점 |
|:--------:|
|<img src="https://hackmd.io/_uploads/HyEHINCYn.gif" width="480">|

### 📱 UIApp

| 은행 개점 | 고객 추가 |
|:--------:|:--------:|
|<img src="https://hackmd.io/_uploads/rkk8A4dc2.gif" width="250">|<img src="https://hackmd.io/_uploads/SJRLANuc3.gif" width="250">|

| 작업 종료 후 초기화 | 작업 진행 중 초기화 |
|:--------:|:--------:|
|<img src="https://hackmd.io/_uploads/rJTDC4O92.gif" width="250">|<img src="https://hackmd.io/_uploads/BkddR4O9n.gif" width="250">|

</br>

## 🤯 고민한 점

### 구현 방법 선택

### 1️⃣ `Dispatch`의 `semaphore value`로 은행원을 2명으로 제한하는 방법

<details>
<summary>내용</summary>
<div markdown="1">
    
- 코드

    ```swift
    private let depositSemaphore = DispatchSemaphore(value: 2)
    private let depositQueue = DispatchQueue(label: "deposit", attributes: .concurrent)

    //...

    while let client = clientWaitingLineQueue.dequeue() {
        switch client.banking {
        case .deposit:
            depositQueue.async(group: group) { [self] in
                depositSemaphore.wait()
                banker.work(client: client)
                depositSemaphore.signal()
            }
            
        //...생략
    }
    ```

- 코드 설명

    * 세마포어 `value`를 2로 설정해 줌으로서 아무리 많은 스레드가 생기더라도 2개의 스레드만 `work()`를 호출할 수 있습니다.
    * `depositQueue`는 비동기이므로 `task`의 순서를 보장하지 않았습니다. 
    * 순서를 보장하지 않는다는 뜻은 고객 간 새치기를 할 수 있다고 비유할 수 있었습니다. (번호표 의미 없음)
    * 또한 테스크를 비동기적으로 수행하기 위해 여러 스레드가 생성되므로 은행원의 수가 여러 명이라고 생각할 수 있습니다.
    * 스레드를 은행원이라고 비유한다면 요구사항을 100프로 충족했다고 보기는 힘들 것 같았습니다.
    * 마치 은행원이 여러 명 대기해있는 상황이고 2명의 은행원만 교대로 일한다고 생각했습니다.

    ![](https://hackmd.io/_uploads/HkTDWGm92.png)


- 결과

    ![](https://hackmd.io/_uploads/BkHt-fmc3.png)

    실제 lldb를 통해 확인해 본 결과 수많은 스레드가 생성되어 대기 중인 상태인 것을 확인할 수 있었습니다.
    
</div>
</details>

### 2️⃣ `DispatchQueue`의 `serial` 방식과 `semaphore`로 은행원을 2명으로 제한하는 방법

<details>
<summary>내용</summary>
<div markdown="1">

- 코드

    ```swift
    func start() {

        let semaphore = DispatchSemaphore(value: 1)
        var doneCustomers: Set<Int> = []

        let depositClerk1 = DispatchQueue(label: "depositClerk1")
        let depositClerk2 = DispatchQueue(label: "depositClerk2")


        func depositWork(customer: Customer) -> DispatchWorkItem {
            return DispatchWorkItem {
                semaphore.wait()
                if !doneCustomers.contains(customer.priority) {
                    doneCustomers.insert(customer.priority)
                    semaphore.signal()
                    print("업무 시작")
                    Thread.sleep(forTimeInterval: 생략)
                    print("업무 완료")
                }
                semaphore.signal()
            }
        }
        
        //...생략

        while let customer = self.customers.dequeue() {
            switch customer.task {
            case .deposit:
                depositClerk1.async(group: group, execute: depositWork(customer: customer))
                depositClerk2.async(group: group, execute: depositWork(customer: customer))
                
            //...생략
    ```

- 코드 설명

    * 첫 번째 방법에서 여러 스레드를 만드는 것을 방지하기 위해 은행원의 수에 맞게 시리얼 큐인 `depositClerk1`과 `depositClerk2` 두 개를 만들었습니다. 이후 네이밍을 `depositQueue`로 하는 것이 자연스럽다고 생각하여 수정하였습니다.
    * 그 후 두 개의 큐에 같은 `WorkItem`을 배정하였습니다.
    * 그럼 그 큐는 세마포어를 이용해 각각의 `task`를 부여받습니다.
    * 부여받는 알고리즘은 다음과 같습니다.
    * 임계 영역에 접근한 뒤 고객의 번호가 `doneCustomer` 집합에 포함되어 있는지 확인합니다.
    * 포함되어 있으면 이미 누군가(자신 포함) 작업한 고객이라는 의미이므로 세마포어를 풀고 리턴합니다.
    * 포함되어 있지 않으면 아무도 작업하지 않은 고객이라는 의미이므로 `doneCustomer`에 추가하고 작업을 시작합니다. 작업을 마치면 세마포어를 풀고 `task`를 종료합니다.
    * 이렇게 되면 각 큐마다 하나의 스레드만 생성되므로 스레드의 개수가 은행원이라고 비유해 봤을 때 요구사항을 올바르게 충족한다고 볼 수 있었습니다.
    * 하지만 예금 고객 줄이 두 줄인데 똑같은 고객이 두 개의 줄을 모두 차지하고 있는 그림이기에 100% 현실을 반영한다고 보기는 어려웠습니다.

    ![](https://hackmd.io/_uploads/Sk8VMGQ9n.png)

- 결과

    ![](https://hackmd.io/_uploads/H1brGfX5n.png)

    스레드는 새로 생겨나거나 사라지지 않는 것을 확인할 수 있었습니다. 

</div>
</details>

### 3️⃣ `OperationQueue`의 상태를 통해 고객을 분배하는 방법
    
<details>
<summary>내용</summary>
<div markdown="1">
    
- 코드

    ```swift
    let depositClerk1 = OperationQueue()
    depositClerk1.maxConcurrentOperationCount = 1
    let depositClerk2 = OperationQueue()
    depositClerk2.maxConcurrentOperationCount = 1

    while let customer = self.customers.dequeue() {
        switch customer.task {
        case .deposit:
            if depositClerk1.operationCount < depositClerk2.operationCount {
                depositClerk1.addOperation(work(customer: customer))
            } else {
                 depositClerk2.addOperation(work(customer: customer))
            }
            
        //...생략
    ```

- 코드 설명

    * 이전 살펴본 두 번째 방법에서는 두 개의 큐에 똑같은 고객이 복사되었습니다.
    * 그 문제를 해결하기 위해 고객을 나눈 뒤 큐에 들어가는 방식을 고안했습니다.
    * 큐 안에 몇 개의 오퍼레이션이 있나 확인 후 더 적은 오퍼레이션을 가지고 있는 큐에 고객을 넣는 식으로 구현했습니다.
    * `DispatchQueue`는 상태를 알기 어렵기 때문에 `Operation`을 사용했습니다.
    * 이렇게 구현하면 똑같은 고객이 큐에 들어가는 것을 방지할 수 있었습니다.
    * 하지만 `Operation`을 이용하면 스레드가 고정되지 않고 변경되는 문제가 발생하였습니다.(이유는 찾지 못함😢)

    ![](https://hackmd.io/_uploads/ByuqzG7cn.png)

- 결과

    ![](https://hackmd.io/_uploads/HJ2oGMQq3.png)
    
    5번 스레드가 사라지고 새로운 스레드가 생성된 것을 확인할 수 있었습니다.

</div>
</details>

### 4️⃣ 시스템이 자동으로 `task`를 분배하는 방법
    
<details>
<summary>내용</summary>
<div markdown="1">

- 코드

    ```swift
    let depositQueue = OperationQueue()
    depositQueue.maxConcurrentOperationCount = 2

    while let customer = customers.dequeue() {
        switch customer.task {
        case .deposit:
            depositQueue.addOperation(work(customer: customer))
            
        //...생략
    }
    ```

    * `OperationQueue`의 `maxConcurrentOperationCount`의 값을 2로 주면 `semaphore`의 `value`와 비슷한 효과를 줄 수 있습니다.
    * 따라서 3번째 방법인 상태 비교를 하지 않아도 시스템이 알아서 `task`를 분배하게 됩니다.
    * 또한 예금 고객 대기 줄을 한 개로 유지할 수 있다는 장점이 있습니다.

    ![](https://hackmd.io/_uploads/S1FAMfQ9n.png)

- 결과

    ![](https://hackmd.io/_uploads/rJNkmzm5h.png)
    
    이전 방법과 같이 새로운 스레드가 생기고 사라지는 것을 확인할 수 있었습니다.

</div>
</details>
    
</br>

## 🧨 트러블 슈팅

1️⃣ **`removeAll()` 할 때 `Node deinit` 시점** <br>
-
🔒 **문제점** <br>
- `LinkedList`의 `removeAll()` 메소드를 구현하던 중 의문이 들었습니다.

    > * 모든 노드를 순회하며 `nil`을 할당해서 메모리에서 해제시켜야 하는가?
    > * 첫 노드만 `nil`을 할당하면 연결된 모든 노드들이 메모리에서 자동으로 해제되는가?

🔑 **해결방법** <br>
- 질문의 해답을 찾기 위해 직접 실험을 해보았습니다. head에 nil을 할당하면 연쇄적으로 연결된 모든 노드들이 메모리에서 해제되는 것을 확인했습니다.

    ```swift
    mutating func removeAll() {
        head = nil
        tail = nil
    }
    ```

    ![](https://hackmd.io/_uploads/H15KcIKY3.png)

    `LinkedList`를 사용하여 새로운 `Node`가 추가되면 기존에 있던 `Node`의 `next` 프로퍼티를 통해 다음 `Node`를 참조합니다. 이렇게 각각의 `Node`는 다음에 오는 `Node`를 참조하고 있고 참조하는 `Node`가 없는 경우 `nil`을 가지고 있습니다. 첫 `Node`는 `head`가 참조하고 있습니다. `removeAll()` 메소드를 사용하여 각각 노드를 참조하고 있는 `head`와 `tail`에 `nil`을 할당하면 앞의 `Node`를 참조하고 있던 다음 `Node` 객체의 `reference count`는 0이 되어 메모리에서 해제됩니다. 그러므로 앞에 있던 `Node`부터 순차적으로 `deinit`이 실행됩니다.

<br>

2️⃣ **`commandline tool`에서 테스트하는 법** <br>
-
🔒 **문제점** <br>
- `commandline tool`에서 `Unit Test`를 진행하려고 했을 때 `iOS App` 과는 다른 문제점이 있었습니다. 아래의 설정처럼 `Target to be Tested`를 설정하는 것이 불가능했습니다.
 
    ![](https://hackmd.io/_uploads/SyxjXj9F3.png)

🔑 **해결방법** <br>
- 이를 해결하기 위해 몇 가지 추가적인 설정이 필요했습니다. 테스트하고자 하는 파일의 `Target MemberShip`에 Test 타겟을 설정해야 했습니다. Test 타겟을 설정하면 `compile source`에 포함시켜 실행시킬 때 함께 빌드 할 수 있도록 합니다.

   

<br>

3️⃣ **객체의 `private` 프로퍼티를 테스트 환경에서 접근하기** <br>
-
🔒 **문제점** <br>
- `Unit Test`를 하기 위해 아래와 같은 객체가 있을 때 테스트 코드에서 `head`와 `tail`을 어떻게 사용할지 고민을 했습니다. 프로퍼티에 대한 테스트와 노출된 메소드를 검증하기 위한 비교 대상으로 사용하기에는 `private`으로 은닉화가 되어 있어 외부에서 사용하기가 불가능했습니다. 

    ```swift
    struct LinkedList<Value> {
        private var head: Node<Value>?
        private var tail: Node<Value>?
        ...
    }
    ```

🔑 **해결방법** <br>
- 전처리문을 사용하여 테스트 코드에서만 적용되는 `extension`을 만들 수 있었습니다.

    ![](https://hackmd.io/_uploads/rkdUyoqFn.png)

    ```swift
    //MARK: - Extension for Unit Test
    #if canImport(XCTest)
    extension LinkedList {
        var exposedHead: Node<Value>? {
            return head
        }

        var exposedTail: Node<Value>? {
            return tail
        }
        ...
    }
    #endif
    ```

<br>

4️⃣ **특정 셀을 지우는 방법** <br>
-
🔒 **문제점** <br>
- 대기 중에서 진행 중으로 변경된 특정 `customerCell`을 대기 중 셀에서 어떻게 지울지 고민하였습니다.

🔑 **해결방법** <br>
- 스택뷰에는 `subviews`라는 속성이 있었고 모든 스택뷰의 아이템을 순회할 수 있었습니다. 하지만 어떤 셀을 지워야 할지에 대한 정보가 아이템에 없었기 때문에 지울 방법이 없었습니다. 이전 프로젝트에서 사용한 `tag` 속성을 이용해서 문제를 해결하였습니다. 처음에 스택뷰에 셀을 넣어줄 때 `tag` 속성에 이번 프로젝트에서 유니크하게 사용되는 `numberTicket`값을 넣어주어서 뷰에 아이디를 부여하였습니다. 그 후 스택뷰의 `subviews`를 `forEach`로 돌며 `UIView`의 `tag`를 확인하는 조건문을 사용할 수 있게 되었습니다.
    
    ```swift
    //add
    label.tag = customer.numberTicket

    //move
    waitContentStackView.subviews.forEach { subview in
        if subview.tag == customer.numberTicket {
            waitContentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
            workContentStackView.addArrangedSubview(subview)
        }
    }
    ```

<br>

5️⃣ **`Custom View init`문제** <br> 
-
🔒 **문제점** <br>
- `UIView`를 상속받아 고객 정보를 담는 `CustomView`를 구현했습니다. `CustomView`에는 고객 정보를 담을 `label`과 작업에 따른 글자 색의 정보가 필요했습니다.

    해당 정보를 외부에서 주입받기 위해 `init`을 만드는 과정에서 많은 문제가 생겼습니다. `frame`을 `super`에게 전해줘야 하는데 `custom init`을 만들면 `frame`을 알지 못해 외부에서 `frame`을 주입받아야 한다는 단점이 있었습니다.

🔑 **해결방법** <br>
- `frame`을 전해주고 오토레이아웃을 잡아주면 `frame`이 무시된다는 것을 깨달았고 `frame`을 초기에 `.zero`로 준 뒤 오토레이아웃을 잡아 문제를 해결하였습니다.

<br>

6️⃣ **`UI`는 `main` 스레드에서 그리기** <br>
-
🔒 **문제점** <br>
- 은행원이 작업을 처리하는 과정을 `main` 스레드가 아닌 `global` 스레드에서 동작하도록 하였습니다. 은행원이 작업을 시작하며 화면의 `CustomerCellView`를 대기 중에서 업무 중으로 변경하도록 합니다. 이런 경우 `global` 스레드에서 화면을 그리는 작업을 실행하여 문제가 발생하였습니다.

🔑 **해결방법** <br>
- 이를 해결하기 위해 위와 같이 코드를 수정하였습니다.

    ```swift
    func addWaitingQueue(customer: Customer) {
        DispatchQueue.main.async {
            let message = "\(customer.numberTicket) - \(customer.task.information.title)"
            let color = customer.task == .deposit ? UIColor.black : UIColor.purple
            let customerCell = CustomerCellView(message: message, color: color, tag: customer.numberTicket)
            self.bankManagerView.waitContentStackView.addArrangedSubview(customerCell)
        }
    }
    
    func moveToWorkingQueue(customer: Customer) {
        DispatchQueue.main.async {
            self.bankManagerView.waitContentStackView.subviews.forEach { subview in
                if subview.tag == customer.numberTicket {
                    self.bankManagerView.waitContentStackView.removeArrangedSubview(subview)
                    subview.removeFromSuperview()
                    self.bankManagerView.workContentStackView.addArrangedSubview(subview)
                }
            }
        }
    }
    
    func removeWorkingQueue(customer: Customer) {
        DispatchQueue.main.async {
            self.bankManagerView.workContentStackView.subviews.forEach { subview in
                if subview.tag == customer.numberTicket {
                    self.bankManagerView.workContentStackView.removeArrangedSubview(subview)
                    subview.removeFromSuperview()
                }
            }
        }
    }
    ```

    `global` 스레드에서 각각의 메소드를 호출하면 메소드 내부에서 다시 `main` 스레드에서 실행할 수 있도록 `DispatchQueue.main`을 사용하여 `task`를 이동시킵니다.


<br>

7️⃣ **`Timer`가 계속 멈추는 문제** <br> 
-
🔒 **문제점** <br>
- `Timer`가 동작 중에 멈추는 경우가 발생하였습니다. 특정 동작에 따른 조건에서 멈추기보다는 정확히 어떤 경우에 타이머가 멈추는지 알기가 어려웠고 여러 실험을 하면서 스레드와 관련하여 문제가 있다고 유추했습니다. 이를 기준으로 다음의 코드를 살펴보았습니다.

    ```swift
    func start() {
        assignClerk()
        timer.resume()
        DispatchQueue.global().async {
            self.distributeCustomers()
        }
    }

    //...생략

    private func distributeCustomers() {
        while let customer = customers.dequeue() {
            
            self.timerDelegate?.addWaitingQueue(customer: customer)
            
            switch customer.task {
            case .deposit:
                depositQueue.addOperation(work(customer: customer))
            case .loan:
                loanQueue.addOperation(work(customer: customer))
            }
        }
        
        depositQueue.waitUntilAllOperationsAreFinished()
        loanQueue.waitUntilAllOperationsAreFinished()
        totalTaskTime = timer.suspend()
    }
    ```

    `timer`의 `suspend()` 메소드가 위와 같이 `global` 스레드에서 동작합니다. 즉, 고객 추가 버튼을 누를 경우 여러 번의 `start()` 메소드가 실행되고 그 수만큼의 `global` 스레드가 생성되어 `suspend()` 메소드를 호출하게 됩니다. `suspend` 메소드에서는 다음과 같이 `state`을 기준으로 동작합니다.
    
    ```swift
    func suspend() -> TimeInterval {
        if state == .suspended {
            return totalTaskTime
        }
        
        let currentTime = Date()
        state = .suspended
        timer.suspend()
        totalTaskTime += currentTime.timeIntervalSince(startTime)
        
        return totalTaskTime
    }
    ```
    
    여러 스레드에서 동작하던 중 공유 데이터인 `state`에 접근하여 값을 바꾸는 동작과 `if` 문에서 `state`을 기준으로 분기를 처리하는 과정이 동시에 일어나게 되면 `state`가 `suspended`로 변경되기 전에 다른 스레드에서 `if` 문의 조건이 `false`일 수 있습니다. 이런 경우 `timer`의 `suspend()` 메소드가 여러 번 호출이 될 수 있으며 타이머가 동작을 중지하는 문제를 일으킬 수 있습니다.

🔑 **해결방법** <br>
- 이러한 문제를 해결하기 위해 공유 데이터인 `state`에 접근하는 스레드의 수를 제한하기 위해 `DispatchSemaphore`를 사용하였습니다.
    
    ```swift
    private func distributeCustomers() {
        //...생략
        
        semaphore.wait()
        totalTaskTime = timer.suspend()
        semaphore.signal()
    }
    ```

</br>

## 📚 참고 링크
- [🍎Apple Docs: Access Control](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol)
- [🍎Apple Docs: Timer](https://developer.apple.com/documentation/foundation/timer)
- [🍎Apple Docs: UIStackView](https://developer.apple.com/documentation/uikit/uistackview)
- [🍎Apple Docs: Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [🍎Apple Docs: Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/)
- [🍎Apple Docs: cancelAllOperations()](https://developer.apple.com/documentation/foundation/operationqueue/1417849-cancelalloperations)
- [🍏Apple Archive: Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
- [📼Apple WWDC: Concurrent Programming With GCD in Swift 3](https://developer.apple.com/videos/play/wwdc2016/720/)
- [📙Swift forums: 테스트를 위한 전처리문](https://forums.swift.org/t/how-do-you-know-if-youre-running-unit-tests-when-calling-swift-test/49711/4)
- [📘stackOverflow: Swift extension for selected class instance](https://stackoverflow.com/questions/37682420/swift-extension-for-selected-class-instance)
- [📘blog: DispatchSourceTimer](https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9)
- [📘blog: intrinsicContentSize](https://magi82.github.io/ios-intrinsicContentSize/)
- [📘blog: CommandLineTool](https://jwonylee.tistory.com/entry/XCode-Swift-Command-Line-Tool-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8%EC%97%90%EC%84%9C-%EC%9C%A0%EB%8B%9B-%ED%85%8C%EC%8A%A4%ED%8A%B8-%ED%95%98%EA%B8%B0)

</br>
