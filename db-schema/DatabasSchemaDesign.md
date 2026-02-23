# 🗄️ Database Schema Design (PostgreSQL)

'블루칼라 링크드인' 서비스의 관계형 데이터베이스 상세 설계서입니다. 모든 테이블은 확장성과 데이터 정합성을 우선하여 설계되었습니다.

---

## 1. 공통 코드 시스템 (Common Code)
서비스 내에서 반복되는 유형(역할, 기술, 게시글 종류)을 관리합니다.

### 📝 code_grp (코드 그룹)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **code_grp_id** | VARCHAR(20) | PK | 그룹 식별 코드 |
| **grp_nm** | VARCHAR(50) | Not Null | 그룹 이름 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

### 📝 code_dtl (코드 상세)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **code_grp_id** | VARCHAR(20) | FK (code_grp) | 그룹 식별 코드 |
| **code_dtl_id** | VARCHAR(20) | PK | 세부 코드 값 |
| **cd_nm** | VARCHAR(50) | Not Null | 코드 명칭 |
| **sort_ord** | INT | Default 0 | 정렬 순서 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |
---

## 2. 사용자 계층 (User Layer)
계정 보안과 프로필 정보를 분리하여 관리합니다.

### 📝 user (계정 마스터)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **user_id** | VARCHAR(8) | PK | 사용자 고유 ID |
| **email** | VARCHAR(100) | Unique, Not Null | 로그인 이메일 |
| **password_hash** | TEXT | Not Null | 해시된 비밀번호 |
| **status** | VARCHAR(10) | Default 'ACTIVE' | 계정 상태 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

### 📝 user_info (사용자 기본정보)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **user_id** | VARCHAR(8) | PK, FK (user) | 사용자 ID (1:1) |
| **name** | VARCHAR(50) | Not Null | 실명 |
| **phone** | VARCHAR(20) | - | 연락처 |
| **role_code** | VARCHAR(20) | FK (code_dtl) | 역할 (WORKER/HIRER) |
| **profile_img_url** | TEXT | - | 프로필 이미지 URL |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

### 📝 user_profile (숙련공 상세)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **user_id** | VARCHAR(8) | PK, FK (user) | 사용자 ID (1:1) |
| **bio** | TEXT | - | 자기소개 |
| **main_skill_cd** | VARCHAR(20) | FK (code_dtl) | 주요 기술 코드 |
| **exp_years** | INT | Default 0 | 경력 연수 |
| **is_verified** | BOOLEAN | Default False | 숙련공 인증 여부 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

---

## 3. 게시물 계층 (Post Layer)
모든 게시물은 마스터와 컨텐츠 테이블을 거치며, 유형에 따라 상세 테이블이 결합됩니다.

### 📝 post (게시물 마스터)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **post_id** | VARCHAR(8) | PK | 게시물 고유 ID |
| **author_id** | INT | FK (user) | 작성자 ID |
| **post_type** | VARCHAR(20) | FK (code_dtl) | 유형 (JOB/EXP 등) |
| **view_cnt** | INT | Default 0 | 조회수 |
| **status** | VARCHAR(10) | Default 'OPEN' | 게시 상태 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

### 📝 post_cntt (게시물 본문 상세)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **post_id** | VARCHAR(8) | PK, FK (post) | 게시물 ID (1:1) |
| **title** | VARCHAR(200) | Not Null | 제목 |
| **content** | TEXT | - | 본문 내용 |
| **work_img_url** | TEXT | - | 이미지 URL |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

### 📝 post_dtl (게시물 부가 정보)
| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **post_id** | VARCHAR(8) | PK, FK (post) | 게시물 ID (1:1) |
| **pay_amount** | INT | - | 단가/급여 |
| **loc_nm** | VARCHAR(100) | - | 위치 주소명 |
| **lat** | DECIMAL(10, 8) | - | 위도 |
| **lng** | DECIMAL(11, 8) | - | 경도 |
| **skill_code** | VARCHAR(20) | FK (code_dtl) | 기술 코드 |
| **created_at** | TIMESTAMP | Default NOW() | 생성일시 |
| **created_by** | INT | - | 생성자 ID |
| **updated_at** | TIMESTAMP | Default NOW() | 수정일시 |
| **updated_by** | INT | - | 수정자 ID |

---

## 4. 기타 확장 테이블 (Extras)

### 📝 certifications (자격증)
* `user_id`, `cert_name`, `issue_date`, `cert_image_url`

### 📝 reviews (평판 시스템)
* `target_user_id`, `writer_id`, `rating`, `comment`, `created_at`
