# DrawingApp
 아이패드에 사각형, 사진, 글자, 그림 등을 그리는 앱

- 기간
    - 2022.07.06
    - 2022.08.29

## 구현 화면 

<img src="https://i.imgur.com/9L1SvsA.png"  width="400" height="300"/>

## 사용한 프레임워크 및 기술

- UIKit, Photos, PhotosUI
- NotificationCenter
- AutoLayout
- BezierPath
- UIGestureRecognizer
    - Tap
    - Pan
- UserDefaults
- NSKeyed(Un)Archiver
- Multi-Scene

## 사용한 아키텍처와 패턴

- MVC 
- 옵저버 패턴
- 팩토리 메서드 패턴

## UseCase
- 도형 생성 
- 도형 속성 수정
- 사진 인출 
- UserDefaults 저장 및 인출 
- 오브젝트 목록 순서 변경 
- 도형 PanGesture를 이용한 이동 
- app 생명주기에 따른 작업 처리

## 기능별 화면

### 도형 생성

<img src="https://i.imgur.com/aeQMx0n.png"  width="400" height="300"/>

### 도형 속성 변경

https://user-images.githubusercontent.com/50472122/187016151-f7eea633-c585-4c54-bf9f-550db6338268.mov

### 도형 탭

<img src="https://i.imgur.com/e7OdOss.png"  width="400" height="300"/>

### 도형 드래그

https://user-images.githubusercontent.com/50472122/187016268-ff541477-a9d8-456a-84ca-26a1f84dc50d.mov

### 오브젝트 목록 순서 변화(깊은 터치)(뷰 터치 순서도 변화)

https://user-images.githubusercontent.com/50472122/187111505-046f3fce-47f2-4136-a60d-e9c1cf61b43f.mov

### 오브젝트 목록 순서 변화(드래그 앤 드롭)(뷰 터치 순서도 변화)

https://user-images.githubusercontent.com/50472122/187111539-1ec90d61-cdf8-4517-8b85-3917ac6fd5a7.mov

### 다중 화면 지원

![](https://i.imgur.com/3Cr8Daa.jpg)


### 다중 화면간 동기화

https://user-images.githubusercontent.com/50472122/187111556-fcc44897-f0f1-4c97-8d8e-ff88efe21309.mov

### 앱이 백그라운드로 넘어갈 때마다 스크린샷을 캡쳐 후 앨범에 저장

![](https://i.imgur.com/RfPIbQ8.png)


## 고민과 해결

### 1. UIImage 가 많은 메모리를 잡는 문제

- UIImage 의 pixel scale 을 조절하는 DownSampling 을 통해 해결



| DownSampling 전 | DownSampling 후 |
| -------- | -------- |
| ![](https://i.imgur.com/OEMVN9O.jpg) | ![](https://i.imgur.com/1IONxVg.jpg) |


### 2. UITapGestureRecognizer 와 UI 객체 요소(button, table cell) 간 간섭

- 메인 화면에 button 을 눌렀을 때, 배경 뷰에 대한 Touch 로 인식하여 button 액션이 눌리지 않고, tap 으로 인식하는 문제
1. tap을 인식할 범위 공간을 한정
    - `CanvasView` 로 탭이 되는 공간을 제한하였다.
2. `UITapGestureRecognizer` 의 속성 중 `cancelsTouchesInView` 의 값을 `false` 로 주었다.

### 3. 드로잉이 뷰에 담기지 않는 문제
- 포인터의 실제 이동 좌표와 생성할 뷰의 좌표계 차이로 인한 실제와 다른 그림 생성
    - 실제 이동 좌표는 CanvasView 좌표계에서의 점
    - 그려질 좌표는 LineView에서의 좌표계에서의 점
    - 예를 들어 CanvasView 에서 (100, 100) 은 LineView 에선 (origin.x + 100, origin.y + 100) 이다. 이 차이를 어떻게 극복할지가 문제였다.
    - CanvasView 에서 이동한 좌표를 LineView 로 넘기고 그림을 그릴 때, 
        - X: (origin.x + p.x) - origin.x
        - Y: (origin.y + p.y) - origin.y
        - 로 계산하여 point 계산을 하였다. 
### 4. NSKeyedArchiving 을 할 때, 하위 객체들이 (특히, Line) encode, decode 되지 않는 문제

- NSKeyedArchiver와 NSKeyedUnarchiver 를 이용해서 `Plane` 객체를 상위 하위 객체간의 관계도 같이 저장하고 싶었다. 
    - 그래서 `Plane` 에서 도형의 메타 정보를 담고 있는 `Shapes` 라는 배열을 아카이빙 해야했다.
    - 그러기 위해서 Shape 타입이 되는 `Rectangle, Photo, Text, Line` 이 모두 아카이빙이 가능했어야 했다.
    - 그 중에 Line 이 문제를 일으켰다. 
    - 다른 타입의 경우엔 속성을 따로 들고있는게 단일한 타입으로 들고 있었다. 
    - Line 은 점들의 집합이므로 Array 타입을 들고 있었는데, 문제는 이 Array 타입을 인코딩 하는 것이 어렵다는 단점이 있다. 
        - 그래서 Line 의 경우 Array 대신 Data 타입을 속성으로 가지고 이를 통해 인코딩과 디코딩을 하기 수월하도록 바꾸어 주었다.
