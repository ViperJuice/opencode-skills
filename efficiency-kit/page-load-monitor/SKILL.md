---
name: page-load-monitor
description: "Intelligent browser page load failure handling. Use when browser screenshot or navigation operations fail, especially with 'Frame showing error page' or timeout errors. Provides escalating diagnostic steps (console, network, alternatives) instead of blind retry loops."
---

# Page Load Monitor

## Escalating Diagnosis (not escalating retries)

When a page navigation or screenshot fails:

**Attempt 1 fails**: Wait 3 seconds, retry once. This handles normal page load delays.

**Attempt 2 fails**: STOP retrying. Switch to diagnosis:
- Run browser_console_messages(level="error") — look for JS errors, module load failures
- Run browser_network_requests() — look for HTTP 4xx/5xx, connection refused, timeouts

**After diagnosis, take action based on findings**:
- Connection refused → dev server isn't running. Tell user: "Dev server appears to be down. Please start it."
- HTTP 503/502 → backend crashed. Tell user: "Backend returning 503. Please restart the backend."
- JS module errors → build issue. Tell user: "Frontend build error: [error]. Please run [build command]."
- Timeout with no errors → slow server. Wait 10s and try ONE more time.
- No errors found → wrong URL or port. Verify URL against project config files.

**NEVER**: Take more than 4 screenshots/navigations in a row to check if a page loaded.

## Quick Decision

After 2 failures, ask yourself: "Is retrying going to help, or is this a server-side problem I can't fix?"
- If server-side → tell the user immediately
- If client-side (JS error) → try to fix it
- If uncertain → diagnose with console + network before retrying
