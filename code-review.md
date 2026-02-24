# 0224 코드 리뷰

> Blue-Collar LinkedIn (KineticsGuild) 프론트엔드 코드 리뷰  
> 가독성, 유지보수성, 클린 코드 원칙 관점

---

## 잘된 점

| 항목 | 설명 |
|------|------|
| App Router 사용 | Next.js 14+ App Router 구조를 잘 따름 |
| 컴포넌트 재사용 | `AuthCard`로 로그인/회원가입 레이아웃 공통화 |
| 접근성 | `label` + `htmlFor`, `aria-label`, `required` 등 기본 접근성 고려 |
| 일관된 스타일 | zinc + amber 조합으로 통일된 다크 테마 |
| 타입 정의 | `AuthCardFooterLink`, `AuthCardProps` 등 인터페이스 정의 |

---

## 1. DRY 위반 (Don't Repeat Yourself)

### 문제

`SignInForm`과 `SignUpForm`에서 다음이 중복됩니다.

- `INPUT_CLASSES` 상수
- 이메일/비밀번호 필드 UI
- 비밀번호 토글 로직
- 제출 버튼 스타일

### 개선 코드

```tsx
// components/ui/Input.tsx
import { forwardRef } from "react";

const INPUT_BASE_CLASSES =
  "w-full rounded-lg border border-zinc-600 bg-zinc-800/50 px-4 py-3 text-zinc-100 placeholder-zinc-500 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20";

export const Input = forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className = "", ...props }, ref) => (
    <input
      ref={ref}
      className={`${INPUT_BASE_CLASSES} ${className}`.trim()}
      {...props}
    />
  )
);
Input.displayName = "Input";
```

```tsx
// components/auth/PasswordField.tsx
"use client";

import { useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import { Input } from "@/components/ui/Input";

interface PasswordFieldProps {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  autoComplete?: "current-password" | "new-password";
  required?: boolean;
}

export function PasswordField({
  id,
  label,
  value,
  onChange,
  autoComplete = "current-password",
  required = true,
}: PasswordFieldProps) {
  const [showPassword, setShowPassword] = useState(false);

  return (
    <div>
      <label htmlFor={id} className="mb-1 block text-sm font-medium text-zinc-300">
        {label}
      </label>
      <div className="relative">
        <Input
          id={id}
          type={showPassword ? "text" : "password"}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder="••••••••"
          autoComplete={autoComplete}
          required={required}
        />
        <button
          type="button"
          onClick={() => setShowPassword((prev) => !prev)}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-300"
          aria-label={showPassword ? "Hide password" : "Show password"}
        >
          {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
        </button>
      </div>
    </div>
  );
}
```

```tsx
// lib/constants.ts
export const BUTTON_CLASSES = {
  primary:
    "w-full rounded-lg bg-amber-500 py-3 font-semibold text-zinc-950 hover:bg-amber-400 focus-visible:ring-amber-500",
  secondary:
    "flex flex-1 items-center justify-center gap-2 rounded-lg border border-zinc-600 py-3 text-sm font-medium text-zinc-300 hover:bg-zinc-800",
} as const;
```

---

## 2. 단일 책임 원칙 (SRP) 위반

### 문제

`SignInForm`이 다음을 모두 담당합니다.

- 폼 상태 관리
- 이메일/비밀번호 필드 렌더링
- 소셜 로그인 UI
- 구분선 UI

### 개선 코드

```tsx
// components/auth/SocialLoginButtons.tsx
import { Chrome, Apple } from "lucide-react";

const PROVIDERS = [
  { id: "google", label: "Google", icon: Chrome },
  { id: "apple", label: "Apple", icon: Apple },
] as const;

interface SocialLoginButtonsProps {
  onProviderClick?: (provider: string) => void;
}

export function SocialLoginButtons({ onProviderClick }: SocialLoginButtonsProps) {
  return (
    <>
      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-zinc-700" />
        </div>
        <div className="relative flex justify-center text-sm">
          <span className="bg-zinc-900 px-3 text-zinc-500">or continue with</span>
        </div>
      </div>
      <div className="flex gap-3">
        {PROVIDERS.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            type="button"
            onClick={() => onProviderClick?.(id)}
            className="flex flex-1 items-center justify-center gap-2 rounded-lg border border-zinc-600 py-3 text-sm font-medium text-zinc-300 hover:bg-zinc-800"
          >
            <Icon size={18} />
            {label}
          </button>
        ))}
      </div>
    </>
  );
}
```

```tsx
// components/auth/FormDivider.tsx
export function FormDivider({ text }: { text: string }) {
  return (
    <div className="relative my-6">
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-zinc-700" />
      </div>
      <div className="relative flex justify-center text-sm">
        <span className="bg-zinc-900 px-3 text-zinc-500">{text}</span>
      </div>
    </div>
  );
}
```

---

## 3. 매직 스트링 / 매직 넘버

### 문제

- `"signin-email"`, `"signup-email"` 등 ID가 하드코딩
- `size={18}`, `size={20}` 등 숫자 산재
- `"KineticsGuild"` 여러 곳에 반복

### 개선 코드

```tsx
// lib/constants.ts
export const APP_NAME = "KineticsGuild" as const;

export const ICON_SIZES = {
  sm: 18,
  md: 20,
  lg: 24,
} as const;

export const FORM_IDS = {
  signIn: {
    email: "signin-email",
    password: "signin-password",
  },
  signUp: {
    email: "signup-email",
    password: "signup-password",
  },
} as const;
```

```tsx
// layout.tsx
import { APP_NAME } from "@/lib/constants";

export const metadata: Metadata = {
  title: APP_NAME,
  description: "The professional network built for the hands-on economy.",
};
```

---

## 4. 가독성 – 긴 className

### 문제

`className`이 길어서 한 줄에 여러 스타일이 섞여 읽기 어렵습니다.

### 개선 코드

```tsx
// lib/styles.ts 또는 tailwind.config에서 @layer components 활용
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      // ...
    },
  },
  plugins: [
    function ({ addComponents }) {
      addComponents({
        ".btn-primary": {
          "@apply w-full rounded-lg bg-amber-500 py-3 font-semibold text-zinc-950 hover:bg-amber-400 focus-visible:ring-amber-500": {},
        },
        ".input-auth": {
          "@apply w-full rounded-lg border border-zinc-600 bg-zinc-800/50 px-4 py-3 text-zinc-100 placeholder-zinc-500 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20": {},
        },
      });
    },
  ],
};
```

또는 `cn()` 유틸로 조합:

```tsx
// lib/cn.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// 사용
<button className={cn("w-full rounded-lg py-3 font-semibold", "bg-amber-500 text-zinc-950 hover:bg-amber-400")}>
```

---

## 5. 에러 처리 및 피드백 부재

### 문제

- `handleSubmit`이 아무 동작도 하지 않음
- 로딩/에러 상태 없음
- 사용자 피드백 없음

### 개선 코드

```tsx
// app/signin/SignInForm.tsx (개선 버전)
"use client";

import { useState } from "react";
import { Input } from "@/components/ui/Input";
import { PasswordField } from "@/components/auth/PasswordField";
import { SocialLoginButtons } from "@/components/auth/SocialLoginButtons";
import { FORM_IDS } from "@/lib/constants";
import { BUTTON_CLASSES } from "@/lib/constants";

type FormStatus = "idle" | "submitting" | "error" | "success";

export function SignInForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [status, setStatus] = useState<FormStatus>("idle");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("submitting");
    setErrorMessage(null);

    try {
      // TODO: API 호출
      // await signIn({ email, password });
      setStatus("success");
    } catch (err) {
      setStatus("error");
      setErrorMessage(err instanceof Error ? err.message : "로그인에 실패했습니다.");
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      {status === "error" && errorMessage && (
        <div
          role="alert"
          className="rounded-lg border border-red-500/50 bg-red-500/10 px-4 py-3 text-sm text-red-400"
        >
          {errorMessage}
        </div>
      )}
      {/* ... fields ... */}
      <button
        type="submit"
        disabled={status === "submitting"}
        className={BUTTON_CLASSES.primary}
      >
        {status === "submitting" ? "로그인 중..." : "Sign In"}
      </button>
      <SocialLoginButtons />
    </form>
  );
}
```

---

## 6. AuthCard – 컴포지션 개선

### 문제

- `footerLink` 구조가 복잡함
- `children`만으로는 레이아웃 유연성이 부족함

### 개선 코드

```tsx
// components/AuthCard.tsx (개선 버전)
import Link from "next/link";
import { APP_NAME } from "@/lib/constants";

interface AuthCardProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
  footer?: React.ReactNode; // children으로 footer를 주입 → 더 유연
}

const CARD_CLASSES =
  "w-full max-w-md rounded-2xl border border-zinc-700/50 bg-zinc-900 p-6 shadow-xl sm:p-8";

export function AuthCard({ title, subtitle, children, footer }: AuthCardProps) {
  return (
    <div className={CARD_CLASSES}>
      <Link
        href="/"
        className="inline-block text-lg font-bold tracking-tight text-zinc-100 hover:text-zinc-200"
      >
        {APP_NAME}
      </Link>
      <h1 className="mt-6 text-2xl font-semibold text-zinc-100">{title}</h1>
      <p className="mt-1 text-sm text-zinc-400">{subtitle}</p>
      <div className="mt-8">{children}</div>
      {footer && <div className="mt-6">{footer}</div>}
    </div>
  );
}

// 사용 예시 - footer를 호출부에서 조합
<AuthCard
  title="Welcome Back"
  subtitle="Enter your details to access your guild."
  footer={
    <p className="text-center text-sm text-zinc-400">
      Don&apos;t have an account?{" "}
      <Link href="/signup" className="font-medium text-amber-500 hover:text-amber-400">
        Sign Up
      </Link>
    </p>
  }
>
  <SignInForm />
</AuthCard>
```

---

## 7. 시맨틱 HTML 및 접근성

### 문제

- `Forgot password?`가 `<a href="#">`로 되어 있어 의미와 동작이 불명확함

### 개선 코드

```tsx
// Forgot password 링크 - 별도 페이지가 있다면
<Link
  href="/forgot-password"
  className="text-xs text-amber-500 hover:text-amber-400"
>
  Forgot password?
</Link>

// 아직 페이지가 없다면 - button으로 명확히
<button
  type="button"
  onClick={() => {/* TODO: forgot password flow */}}
  className="text-xs text-amber-500 hover:text-amber-400"
>
  Forgot password?
</button>
```

---

## 8. 타입 안전성

### 문제

- `React.FormEvent`만 사용해 폼 데이터 타입이 명시되지 않음

### 개선 코드

```tsx
// types/auth.ts
export interface SignInCredentials {
  email: string;
  password: string;
}

export interface SignUpCredentials extends SignInCredentials {
  // 추후 name, phone 등 확장
}
```

```tsx
// SignInForm에서
function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const formData = new FormData(e.currentTarget);
  const credentials: SignInCredentials = {
    email: formData.get("email") as string,
    password: formData.get("password") as string,
  };
  // ...
}
```

---

## 9. 개선 후 디렉터리 구조 제안

```
frontend/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── signin/page.tsx
│   ├── signup/page.tsx
│   └── globals.css
├── components/
│   ├── AuthCard.tsx
│   ├── ui/
│   │   └── Input.tsx
│   └── auth/
│       ├── PasswordField.tsx
│       ├── SocialLoginButtons.tsx
│       └── FormDivider.tsx
├── lib/
│   ├── constants.ts
│   ├── cn.ts
│   └── api.ts          # 추후
└── types/
    └── auth.ts
```

---

## 10. 요약 체크리스트

| 원칙 | 현재 | 개선 포인트 |
|------|------|-------------|
| DRY | ❌ | Input, PasswordField, 버튼 스타일 공통화 |
| SRP | ❌ | SocialLoginButtons, FormDivider 분리 |
| 매직 스트링 | ❌ | constants.ts로 상수 집중 |
| 에러 처리 | ❌ | status, errorMessage, disabled 처리 |
| 타입 안전성 | △ | SignInCredentials 등 도메인 타입 정의 |
| 접근성 | △ | Forgot password를 Link/button으로 명확히 |
| 컴포지션 | △ | AuthCard footer를 children으로 유연화 |

---

## 11. 다음 단계 제안

1. **백엔드 연동**  
   FastAPI + Supabase Auth로 로그인/회원가입 API 구현 후 `lib/api.ts`에서 호출

2. **폼 검증**  
   `zod` + `react-hook-form`으로 클라이언트 검증 강화

3. **인증 상태 관리**  
   로그인 후 리다이렉트, 보호된 라우트(미들웨어) 추가

4. **마이 프로필 페이지**  
   기획의 첫 번째 핵심 기능으로 프로필 UI부터 구현

5. **lib/ 구조**  
   `lib/api.ts`, `lib/auth.ts`, `lib/constants.ts` 등으로 유틸/API 분리
