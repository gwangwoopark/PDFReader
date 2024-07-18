# PDF Reader 개발

## 문제
  - PDFKit 화면에서 PencilKit 을 이용해서 필기를 하면 화면을 확대했을 때 필기가 흐릿하게 보이는 문제가 발생함

## 기본 구현 
[What's new in PDFKit - WWDC22](https://developer.apple.com/videos/play/wwdc2022/10089/)

- PDFPageOverlayViewProvider 프로토콜을 소개함
- 각 페이지별로 PKCanvasView 를 관리
- 화면에 출력되는 페이지에 매칭되는 PKCanvasView 를 overlay 로 사용하게 함
  
## 문제 발생 원인
- PDFView 의 ScrollView 에서 확대가 발생하면 PKCanvasView 는 하위 레벨에 존재하기 때문에 자동으로 확대가 되어짐. 이 과정에서 필기가 흐릿하게 렌더링됨
- PKCanvasView 또한 ScrollView 이기 때문에, PKCanvasView 에서 자체적으로 확대가 발생하는 경우에는 필기가 선명하게 보임
- 하지만, ScrollView 에서 확대가 이루어져도 PKCanvasView 내에서 확대가 이루어지지는 않기 때문에 선명한 화면을 얻을 수 없음

## 관련 질문 모음
- [stack overflow - How can I prevent my PKCanvas PDFOverlay object from becoming blurry when pinch-zooming in on a PDF in iOS? by Jun 2023](https://stackoverflow.com/questions/76392202/how-can-i-prevent-my-pkcanvas-pdfoverlay-object-from-becoming-blurry-when-pinch)
  - 확대한 화면
    - ![the zoomed in pdf with the pixelated stroke](https://i.sstatic.net/pysYq.png)
  - PKCanvsView 를 확대한 경우
    - ![setting mamxiumZoomScale on the PKCanvas](https://i.sstatic.net/4WVJ0.png)
- [Apple Developer Forums - Blurry and low resolution of PKCanvasView, as overlayview from PDFView. by Mar. 2024](https://forums.developer.apple.com/forums/thread/748940)
  - 흐릿한 필기
    - ![drawing is blurry](https://developer.apple.com/forums/content/attachment/13bf56c2-4cd2-48dc-8f09-eea3774b2415)
  - 정상적인 필기
    - ![normal drawing](https://developer.apple.com/forums/content/attachment/13bf56c2-4cd2-48dc-8f09-eea3774b2415)
- [Apple Developer Forums - PencilKit: zoom PKCanvasView, drawing blurred (swift, iOS 15) by Jan. 2022](https://forums.developer.apple.com/forums/thread/698317?answerId=15461025#15461025)
  - 마지막 댓글 by ChaosCoder Oct. 23
    > I am also struggling with this issue. I created FB13286723. As this exists since iOS 15 up to iOS 17 and is even present when opening and annotating a PDF from e.g. the Apple Files app (open a PDF from there, activate annotation mode, zoom in, draw => blurry) I have not much hope that Apple will address this 😭 If anyone found a workaround, please share.
  - 2023년 10월에 작성한 댓글로, "iOS Files 앱 에서 (기본 파일앱) 에서도 동일한 증상이 나타나는 것으로 봐서는 애플에서 해당 이슈를 해결해주지 않을 것 같다" 고 말하고 있음.
  - `하지만,` 현재 사용되는 iOS Files 앱에서는 pdf 파일을 열고 확대를 해서 필기를 해도 매우 선명하게 나타남
    - 해당 댓글이 사실이라면 그사이에 어떻게 해결했을까?