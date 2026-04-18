# E4. Photo Upload + Film Mode, Security Hardening & Google Login

## ✅ Status: ALL TASKS COMPLETE (2026-04-18)

All items from the original E4 plan have been implemented and deployed.

---

## Completed Items

### Phần 1: Photo Upload + Film Mode
- [x] Storage bucket `photos` — public, `allowed_mime_types: ["image/*"]`, `file_size_limit: 50MB`
- [x] Film fields migration (`is_film`, `film_stock`, `film_camera`)
- [x] PhotoModel + Freezed code generation
- [x] `uploadPhoto()` in PhotoRepository — MIME fix, storage upload, DB insert
- [x] Upload screen UI — 3-step flow (Pick → Details → Uploading)
- [x] Film Mode toggle + Film Camera / Film Stock fields with **autocomplete suggestions**
- [x] File size validation: 50MB client-side + Supabase bucket limit
- [x] Input validation: title (200 chars), caption (2000 chars), tags (30 max)
- [x] EXIF auto-parsing from uploaded images

### Phần 2: Security Hardening
- [x] RLS policies: 35 policies across all public tables
- [x] Security headers in `vercel.json` (CSP, HSTS, X-Frame-Options, etc.)
- [x] Input validation on signup (email format, password strength)
- [x] Error message sanitization (`AppException` pattern)
- [x] Storage bucket RLS policies (upload, update, delete own photos)

### Phần 3: Google Login
- [x] `signInWithGoogle()` with OAuth redirect flow
- [x] `_getRedirectUrl()` for Web platform
- [x] Auth state listener for profile sync
- [x] Facebook button removed from UI
- [x] CSP headers updated for Google OAuth domains
- [x] Vercel domain: `luxlog.vercel.app`

### Additional Improvements
- [x] Display Name (`full_name`) support across all screens
- [x] Profile edit screen with avatar upload
- [x] Vercel build script caching fix (`_flutter` directory)
- [x] Film stock autocomplete (~35 stocks: Kodak, Fuji, Ilford, CineStill, etc.)
- [x] Film camera autocomplete (~40 cameras: Contax, Nikon, Leica, Hasselblad, etc.)

---

## Manual Verification Checklist

### Google OAuth
- [ ] Supabase Dashboard → Authentication → URL Configuration → Site URL = `https://luxlog.vercel.app`
- [ ] Supabase Dashboard → Redirect URLs includes `https://luxlog.vercel.app/**`
- [ ] Google Cloud Console → Authorized JavaScript origins includes `https://luxlog.vercel.app`
- [ ] Google Cloud Console → Authorized redirect URIs includes `https://joxsoxrsjtgaultrmhcw.supabase.co/auth/v1/callback`

### Upload Flow
- [ ] Pick image > 20MB but < 50MB → should succeed
- [ ] Pick image > 50MB → should show error
- [ ] Film Mode → type "Kod" → see Kodak suggestions
- [ ] Film Mode → type custom value → accepted without issue
