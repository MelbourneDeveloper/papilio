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