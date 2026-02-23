-- 1. 공통 코드 그룹
CREATE TABLE code_grp (
    code_grp_id VARCHAR(20) PRIMARY KEY,
    grp_nm VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 2. 공통 코드 상세
CREATE TABLE code_dtl (
    code_dtl_id VARCHAR(20) PRIMARY KEY,
    code_grp_id VARCHAR(20) REFERENCES code_grp(code_grp_id),
    cd_nm VARCHAR(50) NOT NULL,
    sort_ord INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 3. 사용자 계정 (PK: VARCHAR(8))
CREATE TABLE "user" (
    user_id VARCHAR(8) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    status VARCHAR(10) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 4. 사용자 기본정보
CREATE TABLE user_info (
    user_id VARCHAR(8) PRIMARY KEY REFERENCES "user"(user_id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role_code VARCHAR(20) REFERENCES code_dtl(code_dtl_id),
    profile_img_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 5. 숙련공 상세 프로필
CREATE TABLE user_profile (
    user_id VARCHAR(8) PRIMARY KEY REFERENCES "user"(user_id) ON DELETE CASCADE,
    bio TEXT,
    main_skill_cd VARCHAR(20) REFERENCES code_dtl(code_dtl_id),
    exp_years INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 6. 게시물 마스터 (PK: VARCHAR(8))
CREATE TABLE post (
    post_id VARCHAR(8) PRIMARY KEY,
    author_id VARCHAR(8) REFERENCES "user"(user_id),
    post_type VARCHAR(20) REFERENCES code_dtl(code_dtl_id),
    view_cnt INT DEFAULT 0,
    status VARCHAR(10) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 7. 게시물 본문 콘텐츠
CREATE TABLE post_cntt (
    post_id VARCHAR(8) PRIMARY KEY REFERENCES post(post_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    work_img_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);

-- 8. 게시물 부가 상세정보
CREATE TABLE post_dtl (
    post_id VARCHAR(8) PRIMARY KEY REFERENCES post(post_id) ON DELETE CASCADE,
    pay_amount INT,
    loc_nm VARCHAR(100),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    skill_code VARCHAR(20) REFERENCES code_dtl(code_dtl_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(8)
);
