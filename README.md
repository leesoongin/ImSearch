



# 목차

- 프로젝트 소개
- 개발환경 및 라이브러리
- 실행화면
- 구현 기능
- 모델, 아키텍쳐 구조 ( 작성 예정)
- 어려웠던 기능, 기능 구현을 위한 고민
    
---

# ImSearch

[Kakao API](https://developers.kakao.com/docs/latest/ko/daum-search/dev-guide#search-image)  검색을 통한 이미지 검색 앱

원하는 키워드로 검색하여 원하는 이미지를 다운받을 수 있습니다.

<br>

---

<br>

## 개발환경 및 라이브러리
### 개발환경

Xcode **`12.4`**

CocoaPods **`1.10.0`**

### 라이브러리

- [Alamofire](https://github.com/Alamofire/Alamofire) - **`5.4`**
- [Kingfisher](https://github.com/onevcat/Kingfisher) - **`6.0`**

---

<br>

## 실행화면

> 
### **Home**

<p><img src="https://user-images.githubusercontent.com/55231029/128599647-66395c6d-17be-4ff4-a8c6-1d9708c9e681.PNG" width="250" height="500"></p>
<br>
<br>

>
### Search

### 검색어 입력, 검색 결과 노출
<p><img src="https://user-images.githubusercontent.com/55231029/128600129-0a1ecf02-be98-4b36-8c0d-e8e2583639b6.GIF" width="250" height="500"></p>
<br>

### 검색 옵션에 따른 검색 결과
<p><img src="https://user-images.githubusercontent.com/55231029/128600230-49b7d7fc-34f7-4e05-9f21-a7b8eae41ed0.GIF" width="250" height="500"></p>
<br>

### 페이징
<p><img src="https://user-images.githubusercontent.com/55231029/128600218-c1136c85-2a18-458a-8769-42e3eee0be29.GIF" width="250" height="500"></p>
<br>


>
### DetailImageView

### **사진 자세히 보기**
<p><img src="https://user-images.githubusercontent.com/55231029/128600755-7b70bd3a-67bc-4a8f-84d6-1c0752107524.GIF" width="250" height="500"></p>
<br>

### **확대**
<p><img src="https://user-images.githubusercontent.com/55231029/128600788-0ad22cc2-f18e-4959-84aa-5a399d1391a7.GIF" width="250" height="500"></p>
<br>

### **내 앨범에 이미지 저장**
<p><img src="https://user-images.githubusercontent.com/55231029/128600808-fed76abf-8684-40ae-a8ef-7330c5c4cc85.GIF" width="250" height="500"></p>
<br>


---
<br>

## 구현 기능

- Kakao 이미지 검색 api를 이용한 이미지 검색
- `검색 옵션` **(정확도 순, 최신 순)**, `페이징 구현` **(페이지당 이미지 80개)**
- 디테일 이미지 뷰, 이미지 확대
- 검색한 이미지 사진 앱에 저장

<br>

---

<br>

# 모델, 아키텍쳐 구조 ( 작성 예정)




<br>

---


## 기능 구현을 위한 고민

### 1. 검색어 입력 마다 api호출 

검색 완료 버튼 없이 사용자가 입력한 검색어를 검색어가 변경 될 때마다 그 결과를 화면에 뿌려주고자 했습니다. 하지만 검색어가 변경될 때 마다 api 를 호출하게 되면 호출 횟수가 매우 많아져 비효율적이라는 문제가 있었습니다. 

빈번한 api호출을 막기 위해 Combine 의 Debounce(1초 간격) 를 이용해 api 호출 횟수를 최소화해서 검색을 수행했습니다.

- Combine 의 Debounce 이용, 1초 동안의 이벤트 중 `가장 마지막 이벤트` 를 수행 

```swift
 func addSearchControllerObserver(){
        self.searchController.searchBar.searchTextField
            .myDebounceSearchPublisher
            .sink { receivedValue in
                self.requestSearchTermToAPI(searchTerm: receivedValue)
            }
            .store(in: &mySubscription)
    }

extension UISearchTextField {
    var myDebounceSearchPublisher : AnyPublisher<String,Never>{
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
            // 노티피케이션 센터에서 UISearchTextField 가져옴
            .compactMap { $0.object as? UISearchTextField }
            //UISearchTextField 에서 text가져오기
            .map{ $0.text ?? "" }
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .filter{ $0.count > 0 }
            .print()
            .eraseToAnyPublisher()
    }
}

```

### 2. 이미지 로딩

`Kingfisher` 등 이미지 라이브러리를 이용하면 이미지 캐싱, 이미지 리사이징 등의 기능을 제공해주지만, 
이번 프로젝트를 통해 이미지를 캐싱하는 흐름을 익히고자 직접 이미지 캐싱을 구현했습니다.

1. api 호출 -> 이미지 URL을 받아옴

2. 메모리 캐시에 이미지 이름을 키값으로 하는 이미지 파일이 존재하는지 체크, 
**존재한다면** `이미지 로드`  or **존재하지 않는다면** `3` 으로 이동

3. 디스크 캐시에 이미지 이름으로 하는 키값으로 하는 이미지 파일이 존재하는지 체크, 
**존재한다면** `이미지 로드` + `메모리 캐시에 캐싱` or **존재하지 않는다면** `4` 으로 이동

4. 이미지, 디스크 `캐시` 에 **이미지가 존재하지 않는 경우**이니 `이미지 URL` 을 통해 **이미지 로드** 
로드한 이미지를 `메모리` , `디스크` 캐시에 **캐싱**

<br>

- ** 이미지 캐싱 과정 **
```swift
func configure(imageURL: String,newWidth: CGFloat){
//        TODO: 1. 메모리 캐시에 이미지가 존재하는지 확인, 존재한다면 이미지 로드
//        TODO: 2. 메모리 캐시에 이미지가 존재하지 않으므로 디스크 캐시에 존재하는지 확인, 존재한다면 이미지 로드
//        TODO: 3. 메모리, 디스크 캐시에 이미지가 존재하지 않는다면 메모리 and 디스크 캐시에 이미지를 저장하고 이미지 load
        if self.imageViewForCell.setCacheImageFromMemory(imageURL) == false {
            if self.imageViewForCell.setCacheImageFromDisk(imageURL) == false {
                self.imageViewForCell.setImageFromURL(imageURL)
            }
        }
    }
```
```swift
extension UIImageView {
```
-  메모리 캐시에서 이미지 로드
```swift
    func setCacheImageFromMemory(_ url: String) -> Bool{
        guard let url = URL(string: url) else { return false}
        
        if let cacheImage = ImageCacheManager.shared.object(forKey: url.lastPathComponent as NSString){
            print("메모리 캐시에서 이미지 로드 ===== ")
            self.image = cacheImage
            // 메모리 캐시에 존재하면 true return 으로 함수 종료
            return true
        }
        return false  // 캐시에 이미지가 존재하지 않았다면 false return
    }
```

- 디스크 캐시에서 이미지 로드

```swift
    //TODO: 1. 기본적으로 제공되는 cache 폴더 경로 불러오기
    //TODO: 2. 파일 이름으로 filePath의 path 설정
    //TODO: 3. 해당 path에 파일이 존재하지 않는다면 retrun false   /  존재한다면 캐시에서 이미지 불러오고 메모리에 캐싱, return true
    
    func setCacheImageFromDisk(_ url: String) -> Bool {
        if let url = URL(string: url){
            if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                var filePath = URL(fileURLWithPath: path)
                let fileManager = ImageCacheManager.fileManager
                
                filePath.appendPathComponent(url.lastPathComponent)
                
                if !fileManager.fileExists(atPath: filePath.path) {
                    return false
                } //if
                else{
                    // 존재한다면 캐시에서 이미지 불러오기
                    guard let imageData = try? Data(contentsOf: filePath) else {
                        print("disk cache image data nil")
                        return false
                    }
                    guard let image = UIImage(data: imageData) else { return false }
                    ImageCacheManager.shared.setObject(image, forKey: url.lastPathComponent as NSString) //메모리에 캐싱
                    
                    print("디스크 캐시에서 이미지 로드 ===== ")
                    self.image = image
                    return true
                }
            } //path
        } //url
        return false
    }
    
```
- URL 을 통한 이미지  load, + **`메모리 캐싱`, `디스크 캐싱`**


```swift
    func setImageFromURL(_ url: String){
        if let url = URL(string: url) {
            if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                var filePath = URL(fileURLWithPath: path)
                let fileManager = ImageCacheManager.fileManager
                filePath.appendPathComponent(url.lastPathComponent)
                
                DispatchQueue.global(qos: .background).async {
                    URLSession.shared.dataTask(with: url){ (data, res, err) in
                        if let _ = err{
                            print("error 처리")
                            return
                        }
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data){
                                // 메모리 캐싱
                                ImageCacheManager.shared.setObject(image, forKey: url.lastPathComponent as NSString)
                                // 디스크 캐싱
                                fileManager.createFile(atPath: filePath.path,
                                                       contents: image.jpegData(compressionQuality: 0.4),
                                                       attributes: nil)
                                print("URL 에서 이미지 로드 ===== ")
                                self.image = image
                            }
                        }
                    }.resume() //session
                } //dispatch
            } //path
        } //url
    }
```

	
![](https://images.velog.io/images/tnddls2ek/post/94803536-e77a-4b0d-ba17-7dda430b9634/image.png)

<br>
<br>

위와 같은 과정을 통해 **이미지를 load** 하는 **`collectionView 의 Cell`** 부분에서 **캐싱되어있는지 여부를 판단** 하여 `캐싱된 데이터` 를 **불러오거나**, `URL` 을 통해 **이미지를 불러왔습니다**
