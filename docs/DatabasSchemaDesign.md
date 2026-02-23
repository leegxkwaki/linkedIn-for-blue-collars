# 🗄️ Database Schema Design (PostgreSQL)

'블루칼라 링크드인' 서비스의 관계형 데이터베이스 상세 설계서입니다. 모든 테이블은 확장성과 데이터 정합성을 우선하여 설계되었습니다.

---

## 1. 공통 코드 시스템 (Common Code)
서비스 내에서 반복되는 유형(역할, 기술, 게시글 종류)을 관리합니다.

### 📝 code_group (코드 그룹)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **group_code** | VARCHAR(20) | PK | 그룹 식별자 (예: USER_ROLE) |
| **group_name** | VARCHAR(50) | Not Null | 그룹 이름 (예: 사용자 역할) |

### 📝 code_detail (코드 상세)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **group_code** | VARCHAR(20) | FK (code_group) | 해당 그룹 코드 |
| **code_value** | VARCHAR(20) | PK | 실제 코드 값 (예: WORKER, JOB) |
| **code_name** | VARCHAR(50) | Not Null | 표시 이름 (예: 숙련공, 구인공고) |
| **sort_order** | INT | Default 0 | 정렬 순서 |

---

## 2. 사용자 관리 (User Management)
계정 보안과 프로필 정보를 분리하여 관리합니다.

### 📝 account_master (계정 마스터)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **account_id** | SERIAL | PK | 계정 고유 ID |
| **email** | VARCHAR(100) | Unique, Not Null | 로그인 이메일 |
| **password_hash** | TEXT | Not Null | 해시된 비밀번호 |
| **account_status** | VARCHAR(10) | Default 'ACTIVE' | ACTIVE, SLEEP, BANNED |
| **created_at** | TIMESTAMP | Default NOW() | 가입 일시 |

### 📝 user_info (사용자 기본정보)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **user_id** | INT | PK, FK (account) | 계정 ID와 1:1 연결 |
| **name** | VARCHAR(50) | Not Null | 실명 |
| **phone** | VARCHAR(20) | - | 연락처 |
| **role_code** | VARCHAR(20) | FK (code_detail) | WORKER(숙련공) / HIRER(고용주) |
| **profile_image_url** | TEXT | - | **[Storage 연결]** 사용자의 프로필 사진 URL |

### 📝 worker_profiles (숙련공 상세 프로필)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **profile_id** | SERIAL | PK | 프로필 고유 ID |
| **user_id** | INT | Unique, FK (user) | 사용자 ID와 1:1 연결 |
| **bio** | TEXT | - | 자기소개 / 한줄소개 |
| **main_skill_code**| VARCHAR(20) | FK (code_detail) | 주요 기술 (예: WELDING, ELEC) |
| **total_exp_years**| INT | Default 0 | 총 경력 연수 |
| **is_verified** | BOOLEAN | Default False | 전문가 인증 여부 |

---

## 3. 콘텐츠 및 매칭 (Posts & Matching)
모든 게시물은 마스터 테이블을 거치며, 유형에 따라 상세 테이블이 결합됩니다.

### 📝 post_master (게시물 마스터)
모든 게시물의 공통 데이터입니다. 
*포스트 타입에 따라 하위 상세 테이블이 결정됩니다.*

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **post_id** | SERIAL | PK | 게시물 고유 ID |
| **author_id** | INT | FK (user_info) | 작성자 ID |
| **post_type** | VARCHAR(20) | FK (code_detail) | JOB(구인), EXP(경력인증), FEED(일반) |
| **title** | VARCHAR(200) | Not Null | 게시물 제목 (또는 현장명) |
| **content** | TEXT | - | 상세 설명 |
| **created_at** | TIMESTAMP | Default NOW() | 작성 시간 |

### 📝 job_details (구인공고 상세)
`post_type`이 'JOB'인 경우 생성됩니다.

| 컬럼명 | 타입 | 설명 |
| :--- | :--- | :--- |
| **post_id** | INT (PK, FK) | post_master 참조 |
| **pay_amount** | INT | 일급/단가 |
| **location_name**| VARCHAR(100) | 근무지 주소 |
| **latitude** | DECIMAL | 위치 좌표 (위도) |
| **longitude** | DECIMAL | 위치 좌표 (경도) |

### 📝 experience_details (현장 경력 상세)
`post_type`이 'EXP'인 경우 생성됩니다. 본인의 포트폴리오가 됩니다.

| 컬럼명 | 타입 | 설명 |
| :--- | :--- | :--- |
| **post_id** | INT (PK, FK) | post_master 참조 |
| **work_image_url**| TEXT | **[Storage 연결]** 현장 작업 사진 URL |
| **skill_code** | VARCHAR(20) | 해당 작업에서 발휘한 기술 코드 |
| **is_public** | BOOLEAN | 내 프로필(포트폴리오) 공개 여부 |

---

## 4. 기타 확장 테이블 (Extras)

### 📝 certifications (자격증)
* `user_id`, `cert_name`, `issue_date`, `cert_image_url`

### 📝 reviews (평판 시스템)
* `target_user_id`, `writer_id`, `rating`, `comment`, `created_at`
