# 👷‍♂️ Project: Blue-Collar LinkedIn (숙련공 네트워킹 서비스)

개발 환경에서 프로젝트의 방향성을 설정하고, 인프라 및 DB 설계를 한눈에 파악하기 위한 가이드입니다.

---

## 1. 서비스 기획 (Functional Planning)

### 📱 주요 화면 및 기능 리스트
* **마이 프로필 (디지털 경력 수첩)**
    * 기술 태그(용접, 전기, 배관 등) 관리
    * 현장 작업 피드 (사진 기반 포트폴리오)
    * 자격증 및 보유 장비 검증 리스트
* **현장 매칭 (구인/구직)**
    * 위치 기반 실시간 현장 공고 필터링
    * 일당/단가 및 지급 조건 투명화
    * 프로필 기반 원클릭 지원
* **커뮤니티 (현장 노하우)**
    * 현장 Q&A 및 공정별 기술 팁 공유
    * 안전 주의보 및 실시간 현장 상황 알림
* **평판 시스템 (Trust Index)**
    * 동료 및 고용주 기반의 기술/성실도 평가

---

## 2. 기술 스택 및 배포 인프라 (Tech Stack)

| 계층 | 선택 기술 | 배포 및 관리 서비스 |
| :--- | :--- | :--- |
| **Frontend** | Next.js 14+ (App Router) | **Vercel** (무료 플랜) |
| **Backend** | Python FastAPI | **Render** 또는 **Railway** (월 $0~5) |
| **Database** | PostgreSQL | **Supabase** (무료 티어 500MB) |
| **Storage** | Object Storage | **Supabase Storage** (현장 사진 저장) |
| **IDE** | **Cursor** | AI 기반 페어 프로그래밍 |

---

## 3. 데이터베이스 설계 (DB Schema - RDB)

### 🛠 설계 원칙
1.  **계정 분리:** 보안을 위해 인증(Master)과 정보(Info), 프로필(Detail)을 분리.
2.  **포스트 확장:** `post_master`를 공통으로 두고 유형별(구인, 피드) 상세 테이블 연결.
3.  **공통 코드화:** 유형(Role, Skill, Post) 관리를 DB 테이블로 일원화.

### 📊 주요 테이블 구조
* **`code_grp` / `code_dtl`**: 시스템 전체 유형 코드 관리.
* **`user`**: 계정 핵심 정보 (이메일, 패스워드, 인증 토큰).
* **`user_info`**: 성함, 연락처, 사용자 역할 코드.
* **`user_profiles`**: 숙련도, 주요 기술 코드, 경력 연수.
* **`post`**: 게시물 상태 관리 (작성자, 유형, 조회수).
* **`post_cntt`**: 게시물 본문 상세 (제목, 내용, 작업 이미지).
* **`post_dtl`**: 게시물 부가 정보 (급여, 위치 좌표, 기술 매칭 데이터).

---

## 4. 초기 비용 예상 (Monthly)

* **인프라:** $0 (Vercel, Supabase, Render 무료 티어 활용 시)
* **도메인:** 약 ₩1,500 ~ 2,000 (1년치 결제 시 월평균)
* **개발 도구:** Cursor 무료 (Pro 플랜 $20 권장)
* **결론:** **월 2,000원 이하**로 MVP(최소 기능 제품) 런칭 가능.

---

## 5. 프로젝트 디렉토리 구조 (Cursor 초기 세팅용)

```text
/blue-collar-project
  ├── /backend                 # Python FastAPI 서버
  │    ├── main.py             # 서버 실행 및 라우팅
  │    ├── database.py         # DB 연결 설정 (PostgreSQL)
  │    ├── models.py           # SQLAlchemy 테이블 모델
  │    ├── schemas.py          # Pydantic 데이터 검증
  │    └── requirements.txt    # 필요 패키지 리스트
  ├── /frontend                # Next.js 웹뷰 (Tailwind)
  │    ├── app/                # App Router 기반 페이지
  │    ├── components/         # 공통 UI 컴포넌트
  │    ├── lib/                # API 통신 유틸리티
  │    └── package.json
  └── README.md                # 현재 문서
