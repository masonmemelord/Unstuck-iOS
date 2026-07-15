# Documentation
This is my documentation for my iOS app (First without a tutorial). Since
this repo is public I'll keep a list of important information; ie. App
Stack, DBs/Auth, etc. As of right now I'm using
OpenAi's Codex as my agent and will log all major changes here before
every commit. I'll also make
sure to comment out everything.

## Jul 6, 2026
First writes. 
To Do: Integrate Firebase, Set up Cover Page, Link docs/tuts for students

How to make Git pull request: https://www.youtube.com/watch?v=jRLGobWwA3Y
Apple Developer Requirements: https://developer.apple.com/app-store/review/guidelines/

## Jul 7, 2026
I forgot to link the useful sites and videos but I'll link a few. 
W3 schools is always helpful when stuck. If you guys do want to buy/use 
Codex/Claude Code I'll link them below as well.

What I got done: Cover page, Link and docs
To Do: Integrate Firebase, add more logic and pages

## Videos/Sites:
- https://www.w3schools.com/swift/default.asp (Generic wiki info)
- https://www.youtube.com/watch?v=Ibtlam1vFGI (What to do and how)
- https://www.youtube.com/watch?v=2IQYbwQpFdM (What NOT to do and how to avoid it)
- https://developers.openai.com/codex/cli (Codex download)
- https://code.claude.com/docs/en/overview (ClaudeCode download)

## Jul 8, 2026
Added a couple pages. Still skimming over the logic to see how everything works. No major changes outside of logic...

## Jul 9, 2026
Changes Made: Added WeeklyCheckIn, it stores id, feeling, weekFocus, studyHours, scheduleSummary, goals, blockers, createdAt; Updated OverviewView, added checkin calling WeeklyCheckIn; updated TestingView @State var and ran Tests.
To Do: Implement Login/Sign Up, New user onboarding, Weekly check-in and overview plan

## Jul 13, 2026
Changes Made: Added WeeklyCheckIn, it stores id, feeling, weekFocus, studyHours, scheduleSummary, goals, blockers, createdAt; Updated OverviewView, added checkin calling WeeklyCheckIn; updated TestingView @State var and ran Tests.
To Do: Upgraded screen routing, added auth listener, and Auth state tracking. Also updated login and signup logic

## Jul 14, 2026
Changes Made: Updated sign in/up logic and flow, added HomeView for a homepage song, added Firebase in ContentView to track currentUser. 
SignUp -> MainView; SignIn -> TestingView. Linked Testing View to OverviewView via @state savedCheckIn. Stored information in WeeklyCheckIn.
To Do: Persist weekly check-ins (database-linked), sign-out button, Add user-specific data, Dashboard. General 
error-handling.

