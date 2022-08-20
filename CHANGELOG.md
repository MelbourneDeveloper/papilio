## 0.1.0-beta
Inititial release
## 0.2.0-beta
Add RebuildEvent so it's possible to trigger rebuild without changing the state
dart pub publish
## 0.3.0-beta
- Add ability to call `pop` from navigator
- Unify `onPopPage` so `pop` always fires the callback
- General cleanup 
## 0.4.0-beta
- Dispose the BloC on pop
- Make a function private
## 0.5.0-beta
- Remove a `late` variable
- `addRouting` will now put `PapilioRoutingConfiguration<T>` in the container
## 0.6.0-beta
- Validate the type argument on navigate
## 0.7.0-beta
- Fix a spelling mistake
## 0.8.0-beta
- Implement Dart Code Metrics and fix a bunch of analysis issues. Most importantly, this removes some implicit casts.
## 0.9.0-beta
- Notes appear to be missing
## 0.10.0-beta
- Rerelease due to some apparent code analysis issues at pub.dev