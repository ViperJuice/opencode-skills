---
name: smart-screenshot
description: "Guidelines for efficient browser screenshot usage. Use when performing browser automation tasks involving screenshots, especially in UI testing sessions. Provides strategies to avoid redundant screenshot captures, intelligent wait strategies for page loads, and alternatives when screenshots fail repeatedly."
---

# Smart Screenshot

## Snapshot vs Screenshot: Choose the Right Tool

- **browser_snapshot()** → for finding elements, reading page structure, taking actions. Fast, reliable, text-based.
- **browser_take_screenshot()** → ONLY for visual verification (layout, styling, images). Expensive, slow.

Rule: If you need to click, type, or read text → use snapshot. If you need to SEE the page → use screenshot.

## Rules

1. Never take 2 screenshots within 3 seconds unless a user-initiated action occurred between them
2. After click/navigation, use browser_wait_for() or browser_snapshot() before screenshotting
3. Never use screenshot to find an element's ref — that's what snapshot is for
4. If you need to verify visual changes, one screenshot is enough. Don't take 3 to "make sure"

## When Screenshots Fail

Escalating response (do NOT just retry):
1. First failure: wait 3s, retry once
2. Second failure: check browser_console_messages(level="error")
3. Third failure: check browser_network_requests() for HTTP 4xx/5xx
4. Fourth failure: STOP. Report to user: "Page not loading. Console shows: [X]. Network shows: [Y]. Suggested action: [Z]."

Common causes: dev server not started, backend crashed (503), hot reload in progress, wrong port.

## Anti-Patterns

- "screenshot → zoom → screenshot → zoom → screenshot" — take ONE screenshot, zoom the region you need
- "screenshot to check if page loaded" — use browser_wait_for(text="expected text") instead
- "screenshot after every click" — only screenshot when visual verification is specifically needed
