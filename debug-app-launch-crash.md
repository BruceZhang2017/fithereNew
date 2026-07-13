# Debug Session: app-launch-crash
- **Status**: [OPEN]
- **Issue**: App launches on the connected iPhone after the previous weather-page fix; need runtime evidence to determine whether any startup crash or startup-phase fatal error still exists.
- **Debug Server**: http://192.168.2.154:7777/event
- **Log File**: .dbg/trae-debug-log-app-launch-crash.ndjson

## Reproduction Steps
1. Build and launch `SmartBracelet` on the connected iPhone.
2. Observe whether the app stays alive after startup and whether any crash or fatal startup error appears.
3. Collect runtime evidence from instrumentation logs and device-side process/log signals.

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | App hits an unhandled exception or assertion during cold start and exits shortly after launch. | Medium | Low | Rejected by process survival evidence |
| B | A startup permission/device-init branch throws an error or enters a fatal path. | Medium | Low | Inconclusive |
| C | An async callback triggered during launch touches invalid state and causes intermittent startup failure. | Low | Medium | Rejected for initial 20s window |
| D | App no longer crashes, but startup still emits critical runtime warnings/errors that need cleanup. | High | Low | Inconclusive; app-side debug transport did not report |

## Log Evidence
- Build and reinstall succeeded on the connected iPhone.
- `xcrun devicectl device process launch --terminate-existing --device 00008101-001828D22E06001E com.zhao.herefit` launched successfully.
- Process polling after relaunch showed `FitDAY` running continuously from `00:11:56` through `00:12:16` (10 polls, every 2 seconds).
- No `.dbg/trae-debug-log-app-launch-crash.ndjson` file was created, so the app-side network instrumentation did not report back during this run.

## Verification Conclusion
- Current evidence does not show a startup crash after app launch on the connected iPhone.
- The strongest runtime evidence is sustained process survival for 20 seconds after launch.
- Remaining gap: startup instrumentation transport did not return logs, so startup warnings/errors inside the app are not yet observable through the debug server.
