# News App data schema

This document describes persisted and exchanged data in the project: **Firebase Firestore**, **Firebase Storage**, **on-device SQLite** (Flutter / Froom), and the **external News API** JSON used by the daily feed. It aligns with `backend/firestore.rules`, `backend/storage.rules`, and the Flutter models under `frontend/lib`.

---

## 1. Firebase Firestore

### 1.1 Collection `articles`

User-authored articles for the in-app feed (create-article flow). Document ID and `articleUid` must match.

**Path:** `/articles/{articleId}`

**Fields** (create payload matches `ArticleNewsModel.toFirestoreCreateMap` and `validArticleCreate` in `firestore.rules`):

| Field | Type | Required | Notes |
|--------|------|----------|--------|
| `articleUid` | string | Yes | Must equal `{articleId}`. |
| `title` | string | Yes | Length 3–120 (enforced on create by rules). |
| `description` | string | Yes | Length 90–250. |
| `content` | string | Yes | Length 100–20,000. |
| `category` | string | Yes | One of: `general`, `business`, `entertainment`, `health`, `science`, `sport`, `technology` (see `ArticleNewsEntity.allowedCategories`). |
| `status` | string | Yes | One of: `draft`, `published`, `archived` (`ArticleNewsEntity.allowedStatuses`). |
| `thumbnailUrl` | string | Yes | Public download URL or empty; max length 2048 on create. Client may read legacy docs that used `thumbnailPath` (`ArticleNewsModel.fromMap` falls back to `thumbnailPath`). |
| `authorUid` | string | Yes | Firebase Auth UID of the author; must match `request.auth.uid` on create. |
| `authorName` | string | Yes | Non-empty, max 200 chars on create. |
| `createdAt` | timestamp | Yes | Server time on create. |
| `publishedAt` | timestamp \| null | No | Omitted or null when not published; otherwise a timestamp. |
| `updatedAt` | timestamp | Yes | Server time on create. |
| `viewsCount` | int | Yes | Must be `0` on create. |

**Read access:** `published` for everyone; `draft` / `archived` only for the owning author (`authorUid`). Updates and deletes are disallowed by current rules.

**Example:**

```json
{
  "articleUid": "h7Gk92fLp0",
  "title": "Flutter vs. Native: The 2026 Verdict",
  "description": "An in-depth look at the performance benchmarks and developer experience when choosing Flutter or native stacks in 2026.",
  "content": "Full body text here…",
  "category": "technology",
  "status": "published",
  "thumbnailUrl": "https://firebasestorage.googleapis.com/.../thumbnail.jpg",
  "authorUid": "firebaseAuthUid28charsX",
  "authorName": "Jane Doe",
  "createdAt": "2026-04-09T10:00:00Z",
  "publishedAt": "2026-04-09T12:00:00Z",
  "updatedAt": "2026-04-09T12:00:00Z",
  "viewsCount": 42
}
```

**Flutter types:** domain `ArticleNewsEntity`, data `ArticleNewsModel` (`frontend/lib/features/create_article/...`).

---

### 1.2 Collection `authors`

Author profile documents keyed by Firebase Auth UID.

**Path:** `/authors/{userId}`

**Fields** (initial `set` matches `AuthorModel.toFirestoreCreateMap` and `validAuthorCreate`):

| Field | Type | Required | Notes |
|--------|------|----------|--------|
| `uid` | string | Yes | Must equal `{userId}` and `request.auth.uid` on create. |
| `username` | string | Yes | Non-empty, max 200 on create. |
| `nameToDisplay` | string | Yes | Non-empty, max 200. |
| `email` | string \| null | No | If present, max 320 chars. |
| `biografy` | string | Yes | Max 10,000 chars (spelling matches app field name). |
| `image` | string | Yes | Max 2048 (e.g. profile photo URL). |
| `articles` | array of string | Yes | Must be empty on create (article UIDs appended later if implemented). |
| `createdAt` | timestamp | Yes | Server time on create. |
| `totalViews` | int | Yes | Must be `0` on create. |
| `lastActiveAt` | timestamp | Yes | Server time on create; login touch updates only this field (`AuthorModel.loginUpdateFirestoreMap`). |

**Read access:** authenticated users. **Update:** only the owner, and only `lastActiveAt` per `validAuthorLoginTouch`. **Delete:** disallowed.

**Flutter types:** domain `AuthorEntity`, data `AuthorModel` (`frontend/lib/features/create_article/...`).

---

## 2. Firebase Storage

Thumbnails for user articles. Paths mirror `ArticleThumbnailStorageImpl` and `storage.rules`.

**Object path:** `media/articles/{articleUid}/thumbnail.jpg`

- `{articleUid}` must match `^[-_A-Za-z0-9]{10,128}$`.
- Uploads: JPEG only, max 5 MiB, authenticated.
- **Read:** public (for feed URLs).
- **Delete:** disallowed by rules.

The Firestore `thumbnailUrl` field typically stores the download URL for this object (or another HTTPS URL), not the Storage path string.

---

## 3. On-device SQLite (Froom)

Cached headlines from the **News API** (daily news feature). Defined in `AppDatabase` / `ArticleModel`.

**Table:** `article`  
**Primary key:** `id` (integer; may be null/absent when ingesting API JSON until a local id is assigned)

| Column | SQL type | Nullable | Maps to Flutter |
|--------|-----------|----------|------------------|
| `id` | INTEGER | Yes | `ArticleEntity.id` / `ArticleModel` |
| `author` | TEXT | Yes | `author` |
| `title` | TEXT | Yes | `title` |
| `description` | TEXT | Yes | `description` |
| `url` | TEXT | Yes | `url` |
| `urlToImage` | TEXT | Yes | `urlToImage` |
| `publishedAt` | TEXT | Yes | `publishedAt` |
| `content` | TEXT | Yes | `content` |

**Flutter types:** domain `ArticleEntity`, persisted `@Entity` `ArticleModel` (`frontend/lib/features/daily_news/...`).

---

## 4. External News API (JSON contract)

The daily feed parses a top-level wrapper and an `articles` array (`NewsResponseModel`, `ArticleModel.fromJson`).

**Top-level object:**

| Field | Type | Notes |
|--------|------|--------|
| `status` | string | e.g. `ok` |
| `totalResults` | int | Total count from provider |
| `articles` | array | List of article objects |

**Each element of `articles`:**

| Field | Type | Notes |
|--------|------|--------|
| `author` | string | Optional in API; defaults to `""` in app |
| `title` | string | |
| `description` | string | |
| `url` | string | |
| `urlToImage` | string | Empty or missing → app uses default image constant |
| `publishedAt` | string | ISO-like string from API |
| `content` | string | |

The API may expose a `source` object or numeric id; the current `ArticleModel.fromJson` does not map those into `id`—local `id` is primarily for the Room/Froom row.

**Flutter types:** `NewsResponseModel`, `ArticleModel` (`frontend/lib/features/daily_news/data/models/`).

---

## 5. Firebase Authentication (session user, not Firestore)

The signed-in user is represented in the app as `AuthUser` (not a Firestore document).

| Field | Type | Notes |
|--------|------|--------|
| `uid` | string | Firebase Auth UID |
| `email` | string? | |
| `displayName` | string? | |
| `imageUrl` | string? | Photo URL from provider |

**Flutter type:** `AuthUser` (`frontend/lib/features/auth/domain/entities/auth_user.dart`).  
`AuthorModel.fromAuthUser` seeds a new `AuthorModel` from these fields for first-time author document creation.

---

## 6. Quick reference: entity ↔ storage

| Entity / model | Storage |
|----------------|---------|
| `ArticleNewsEntity` / `ArticleNewsModel` | Firestore `articles` |
| `AuthorEntity` / `AuthorModel` | Firestore `authors` |
| `AuthUser` | Firebase Auth only |
| `ArticleEntity` / `ArticleModel` | SQLite `article` + News API JSON |
| `NewsResponseModel` | News API JSON only |
