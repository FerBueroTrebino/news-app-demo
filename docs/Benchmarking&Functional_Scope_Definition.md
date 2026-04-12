# News App — Benchmarking & Functional Scope Definition

## Context

The task requires building a feature that allows journalists to publish their own articles within an existing News App. This document outlines the functional analysis performed before implementation, starting from the minimum required specifications and expanding through competitive benchmarking and brainstorming.

---

## Minimum Required Functionality

The following features were defined as the baseline for the journalist-facing article creation flow:

- **News Feed** — Users can view a feed containing:
  - News fetched from the API
  - News created by the user

- **Article Creation** — Users can create and publish articles with the following fields:
  - **Title** — Subject to a maximum character limit
  - **Image** — Opens the device gallery to select a photo (photos only). Once an image is loaded, tapping it allows selecting a new one.
  - **Article Body** — Supports Markdown formatting (subtitles, bold text, etc.)

- **Validation** — No field can be left empty
- **Loading Indicator** — Displayed while the article is being submitted
- **Success Notification** — The user is notified when the article is successfully published
- **Improved UI** — The interface should be polished beyond a basic implementation

---

## Brainstorming — Additional Features

After reviewing the base requirements, the following enhancements were considered. At this stage, feasibility and implementation cost were not evaluated — the goal was to think broadly.

### For Readers / End Users

- **Search** — Search for articles within the feed
- **Filtering** — Filter by topic or date
- **Reading Time** — Display estimated reading time per article
- **Time Since Publication** — Show relative time (e.g., "5 minutes ago") for recent articles
- **Article Sharing** — Allow users to share articles externally
- **Text-to-Speech** — Option to listen to an article
- **AI Summary** — A button inside the article that generates an AI-powered summary
- **Related Articles** — Show related content at the bottom of each article
- **Fake News Reporting** — Community-driven flagging system (similar to X/Twitter's Community Notes)
- **Article Rating** — Options considered: star rating (1–5), likes, or upvote/downvote
- **Paywall** — Require subscription to read full articles
- **Comments** — Allow users to comment on articles

### For Authors / Journalists

- **Authentication** — Authors must log in to publish; anonymous publishing is not allowed
- **Author Profile** — Authors can create a profile including:
  - Display name
  - Profile photo
  - Biography
- **Author Page** — Tapping an author's name shows their profile and published articles
- **AI-Assisted Writing** — Author provides a summary/brief and AI generates a full article draft
- **Article Priority** — Authors can assign an importance level when publishing

### Editorial Workflow

- **Editorial Review** — Articles are not published automatically; an editor must approve them
- **Role Levels** — Two roles defined: *Author* and *Editor*

### Performance & Caching

- **Local Cache** — Store the feed locally to reduce API calls. On refresh, only fetch articles updated after the last local save.

---

## Competitive Benchmarking

To validate and expand the feature list, two globally recognized news platforms were analyzed: **The New York Times** and **The Guardian**.

### The New York Times

**Feed:**
- Displays title, photo, and subtitle; layout varies by article importance (title only / title + subtitle / title + subtitle + photo)
- Always shows estimated reading time
- Shows relative publication time for recent articles (e.g., "3 minutes ago")
- No filter functionality
- Category navigation via a top menu
- Search accessible through the menu

**Article Detail:**
- Requires login and a paid subscription to read full content
- Option to listen to the article (text-to-speech)
- Share button
- Save/bookmark option
- Comments section accessible via a dedicated button
- Comments displayed at the bottom of the article

---

### The Guardian

**Feed:**
- Category navigation via a top menu
- Search accessible through the menu
- Same title/subtitle/photo layout logic as the NYT
- No estimated reading time
- Shows relative publication time for recent articles

**Article Detail:**
- Share button
- Inline links to related topics or people mentioned in the article
- Related articles section at the bottom
- Most-read articles list at the bottom
- No comments allowed on articles

---

## Conclusions from Benchmarking

Both platforms reinforce the following patterns:

- A **category menu** should be accessible from the feed
- A **search bar** should be integrated into the navigation
- Articles should be **shareable**
- **Article importance/weight** should influence how it's displayed in the feed
- **Estimated reading time** should be shown
- **Relative publication time** should be shown for recent articles
- **Text-to-speech** is a valued feature
- A **paywall** model is viable for premium content
- **User comments** add community value

---

## Updated Feature List (Post-Benchmarking)

This updated list consolidates the brainstorming and benchmarking findings. Implementation cost and prioritization are addressed in a separate document.

### Reader-Facing Features

| Feature | Notes |
|---|---|
| Category menu in the feed | Based on both NYT and Guardian |
| Search bar in the feed | Based on both NYT and Guardian |
| Author profile page | Name, photo, bio, published articles |
| Estimated reading time | Displayed in the feed and article detail |
| Relative publication time | Shown when article is less than 24 hours old |
| Article sharing | Standard share functionality |
| Text-to-speech | Listen to the article content |
| AI summary button | AI-generated summary inside the article |
| Related articles | Shown at the bottom of each article |
| Feed layout by importance | Title only / + subtitle / + photo depending on weight |
| Fake news reporting | Community flagging (Community Notes-style) |
| Paywall | Requires subscription for full article access |
| User comments | Comments section at the bottom of articles |

### Author-Facing Features

| Feature | Notes |
|---|---|
| Authentication required to publish | No anonymous authorship |
| Author profile creation | Display name, photo, biography |
| AI-assisted article writing | Author provides a brief; AI drafts the article |
| Article importance level | Set during the publishing flow |

### Editorial Features

| Feature | Notes |
|---|---|
| Editorial approval workflow | Articles require editor sign-off before publishing |
| Role system | Author and Editor roles |

### Technical / Performance

| Feature | Notes |
|---|---|
| Local feed caching | Stores feed locally; fetches only updated articles on refresh |

---

## Scope Note

The original task is centered on the **journalist/author experience** — specifically, the ability to create and publish articles. While many of the reader-facing features above are valuable, they fall outside the primary scope. Prioritization will focus on features that directly support the journalist workflow, while reader enhancements are treated as stretch goals or future iterations.
