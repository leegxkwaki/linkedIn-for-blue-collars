-- ==========================================
-- 1. 공통 코드 시스템
-- ==========================================
CREATE TABLE code_group (
    group_code VARCHAR(20) PRIMARY KEY, -- 예: 'USER_ROLE', 'POST_TYPE'
    group_name VARCHAR(50) NOT NULL
);

CREATE TABLE code_detail (
    group_code VARCHAR(20) REFERENCES code_group(group_code),
    code_value VARCHAR(20) NOT NULL, -- 예: 'WORKER', 'JOB_POST'
    code_name VARCHAR(50) NOT NULL,  -- 예: '숙련공', '구인공고'
    sort_order INT DEFAULT 0,
    PRIMARY KEY (group_code, code_value)
);

-- ==========================================
-- 2. 사용자 계층 구조
-- ==========================================

-- [1] 계정 마스터 (보안/인증 중심)
CREATE TABLE account_master (
    account_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    auth_token TEXT,               -- API 인증 토큰 또는 리프레시 토큰
    account_status VARCHAR(10) DEFAULT 'ACTIVE', -- ACTIVE, SLEEP, BANNED
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- [2] 사용자 기본 정보
CREATE TABLE user_info (
    user_id INT PRIMARY KEY REFERENCES account_master(account_id),
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role_code VARCHAR(20), -- code_detail(USER_ROLE) 참조
    birth_date DATE,
    gender VARCHAR(1) -- M, F
);

-- [3] 상세 프로필 (숙련공용)
CREATE TABLE worker_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES user_info(user_id),
    bio TEXT,
    main_skill_code VARCHAR(20), -- code_detail(SKILL_TYPE) 참조
    total_exp_years INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE -- 전문가 인증 여부
);

-- ==========================================
-- 3. 포스트 확장 구조
-- ==========================================

-- [1] 포스트 마스터 (모든 게시물의 부모)
CREATE TABLE post_master (
    post_id SERIAL PRIMARY KEY,
    author_id INT REFERENCES user_info(user_id),
    post_type VARCHAR(20), -- code_detail(POST_TYPE) 참조 (JOB, FEED, QNA 등)
    title VARCHAR(200) NOT NULL,
    content TEXT,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- [2] 구인공고 상세 (Post_type이 'JOB'일 때만 활용)
CREATE TABLE job_details (
    post_id INT PRIMARY KEY REFERENCES post_master(post_id) ON DELETE CASCADE,
    pay_amount INT,
    work_start_date DATE,
    work_end_date DATE,
    location_name VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    required_skill_code VARCHAR(20) -- code_detail(SKILL_TYPE) 참조
);
