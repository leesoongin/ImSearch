# 목차
- 프로젝트 소개
    - 개발환경 및 라이브러리
    - 실행화면
    - 어려웠던 기능, 기능 구현을 위한 고민
    
---

## 개발환경 및 라이브러리
### 개발환경

Xcode **`12.4`**

CocoaPods **`1.10.0`**

### 라이브러리

- [Alamofire](https://github.com/Alamofire/Alamofire) - **`5.4`**
- [Kingfisher](https://github.com/onevcat/Kingfisher) - **`6.0`**

---

## 실행화면

>**Home**
<p><img src="https://user-images.githubusercontent.com/55231029/128599647-66395c6d-17be-4ff4-a8c6-1d9708c9e681.PNG" width="250" height="500"></p>
<br>
<br>

>**Search**
### **검색어 입력, 검색 결과 노출**
<p><img src="https://user-images.githubusercontent.com/55231029/128600129-0a1ecf02-be98-4b36-8c0d-e8e2583639b6.GIF" width="250" height="500"></p>
<br>

### **검색 옵션에 따른 검색 결과**
<p><img src="https://user-images.githubusercontent.com/55231029/128600230-49b7d7fc-34f7-4e05-9f21-a7b8eae41ed0.GIF" width="250" height="500"></p>
<br>

### **페이징 **
<p><img src="https://user-images.githubusercontent.com/55231029/128600218-c1136c85-2a18-458a-8769-42e3eee0be29.GIF" width="250" height="500"></p>
<br>


>**DetailImageView**
사진 자세히 보기
확대
내 앨범에 이미지 저장



---


## 어려웠던 기능, 기능 구현을 위한 고민

1. 검색어 입력 마다 api호출 

- 입력마다의 api 호출은 비효율적. 

- Combine 의 Debounce, RxSwift 의 Debounce 를 이용해 api 호출 횟수를 최소화 할 수 있다는걸 알아냄

- Combine 의 Debounce 를 이용해 api 호출 최소화, 검색어마다의 검색 결과 도출(1초 간격)

2. 이미지 로딩

	- api 호출을 통해 이미지 URL을 받아와 Kingfisher 를 이용해 이미지 로드
    
	- Kingfisher에서 이미지 리사이징, 캐싱 기능을 지원해주지만 라이브러리를 사용하지 않고 직접 구현해보기로 함
    
	- 이미지 캐싱의 과정에 대해 알아봄
	
    ![](https://images.velog.io/images/tnddls2ek/post/94803536-e77a-4b0d-ba17-7dda430b9634/image.png)
    
	1. api 호출 -> 이미지 URL을 받아와서
    2. 메모리 캐시에 이미지 이름을 키값으로 하는 이미지 파일이 존재하는지 체크, 존재한다면 이미지 로드  or 존재하지 않는다면 (3) 으로 이동
    3. 디스크 캐시에 이미지 이름으로 하는 키값으로 하는 이미지 파일이 존재하는지 체크, 존재한다면 이미지 로드(+ 메모리 캐시에 캐싱) or 존재하지 않는다면 (4) 으로 이동
    4. 이미지, 디스크 캐시에 이미지가 존재하지 않는 경우이니 이미지 URL을 통해 이미지 로드. 로드한 이미지를 메모리, 디스크 캐시에 캐싱
    
    위와 같은 과정을 통해 이미지를 load하는 collectionView의 Cell 부분에서 캐싱되어있는지 여부를 판단하여 캐싱된 데이터를 불러오거나, URL을 통해 이미지를 불러왔다.
