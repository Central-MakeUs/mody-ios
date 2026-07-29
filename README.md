# MODY

> 친구와 함께 만드는 다이어트 습관

MODY는 혼자 지속하기 어려운 다이어트를 친구와 함께 기록하고 공유하는 소셜 다이어트 서비스입니다. 그룹에 참여해 식사와 운동을 사진으로 기록하고, 그룹 피드와 주간 활동을 통해 서로의 습관을 확인할 수 있습니다.

현재는 그룹과 기록 경험에 집중한 **Phase 1.0** 범위를 제공하고 있으며, **Phase 2.0**에서는 챌린지와 소셜 기능을 확장할 예정입니다.

## Tech Stack

| Category | Stack |
| --- | --- |
| Language | Swift |
| UI | UIKit, SwiftUI |
| Architecture | Micro Feature Architecture, Clean Architecture |
| State Management | TCA, ReactorKit |
| Reactive | RxSwift, RxCocoa, RxRelay |
| Networking | Alamofire |
| Dependency Injection | Swinject |
| Layout | SnapKit |
| Image | Nuke |
| Service | Firebase, Kakao SDK |
| Project Generation | Tuist |
| Test | XCTest |
| CI/CD | GitHub Actions, Fastlane |

## Development Phase

### Phase 1.0 — Core Features

현재 제공하는 핵심 기능입니다.

- Kakao·Apple 로그인 및 온보딩
- 그룹 생성·참여·초대·관리
- 식사·운동 사진 기록
- 그룹 피드 및 주간 활동 확인
- 프로필 및 체중 관리
- 식사·운동 리마인더와 기본 알림

### Phase 2.0 — Social & Challenge

다음 단계에서 확장할 예정인 기능입니다.

- 그룹 챌린지
- 건강 데이터 연동
- 댓글 및 콕 찌르기
- 챌린지·댓글 관련 알림
- 기록 상세 및 소셜 상호작용 확장

## Architecture

MODY는 Toss의 **Micro Feature Architecture**를 참고해 기능별 모듈을 구성했습니다. 각 기능의 구현과 외부 계약을 분리하고, 모듈 내부에서도 Presentation, Domain, Data의 책임과 의존성 경계를 명확히 하는 데 중점을 두었습니다.

### Project Structure

```text
Projects
├── App           # 앱 진입점, Composition Root, DI
├── Feature       # 사용자 기능 단위 Micro Feature
├── Core          # Network, Auth, Camera, Notification, Image 등 기반 기능
├── Domain        # 여러 모듈이 공유하는 도메인 모델과 정책
├── DesignSystem  # 공통 UI 컴포넌트, 디자인 토큰, 리소스
└── Shared        # Logger, Utility 등 공통 도구
```

### Micro Feature Targets

기능 모듈은 필요에 따라 아래와 같은 독립 타깃으로 분리됩니다.

| Target | Responsibility |
| --- | --- |
| `Feature` | 기능의 실제 구현 |
| `Interface` | 외부에 공개할 입력·출력, Route |
| `Testing` | 테스트에서 재사용할 지원 코드 |
| `Tests` | 기능 단위 테스트 |
| `Demo` | 기능을 독립적으로 실행하고 확인하는 데모 앱 |

### Feature Layers

```text
Feature
└── Sources
    ├── Presentation  # 화면, 사용자 이벤트, 상태 표현
    ├── Domain        # 비즈니스 규칙, UseCase, Repository 계약
    ├── Data          # API, DTO, Repository 구현
    └── Builder       # 기능 생성과 의존성 조립
```

- SwiftUI 기반 기능은 주로 TCA로 상태와 Effect를 관리합니다.
- UIKit 기반 화면은 Coordinator로 화면 전환 책임을 분리하고, 일부 기능에서 ReactorKit과 RxSwift를 사용합니다.
- 기능 외부에서는 구현 타깃보다 `Interface`에 의존하도록 구성해 모듈 간 결합도를 낮췄습니다.

## Environment

**DEV**와 **PROD** 환경을 분리합니다.  

| Environment | Purpose |
| --- | --- |
| `DEV` | 개발 및 내부 검증 |
| `PROD` | 운영 배포 |

환경별 Bundle Identifier, API Base URL, Firebase 설정, Kakao App Key를 별도로 관리해 빌드 설정이 서로 섞이지 않도록 구성했습니다.

## CI/CD

GitHub Actions와 Fastlane을 이용해 태그 기반 빌드 및 배포 파이프라인을 구성했습니다.

- `dev/**`, `prod/**`: DEV·PROD 앱을 빌드해 TestFlight로 배포
- `demo/**`, `design/**`: Feature·DesignSystem 데모 앱을 빌드해 Firebase App Distribution으로 배포
- 배포 태그 검증, 환경 설정, Firebase 설정, Tuist 및 Ruby 환경 구성 자동화
- 인증서와 Provisioning Profile 설치, 빌드 번호 관리, 앱 빌드 및 업로드 자동화
- 파이프라인 시작·성공·실패 결과를 Slack으로 알림

## Testing

기능별 `Tests` 및 `Testing` 타깃과 XCTest 기반 단위 테스트를 구성하고 있습니다.

> 자동 테스트를 실행하는 Test CI는 아직 연결하지 않았으며, 이후 CI/CD 파이프라인에 추가할 예정입니다.
