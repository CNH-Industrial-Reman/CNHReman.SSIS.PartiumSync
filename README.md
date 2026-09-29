# CNHReman.SSIS.PartiumSync

A tool for calling the PartiumSync project commands on a scheduled time.

## What's here

`PartiumSync/` is the actual SSIS project (open `PartiumSync.sln` in Visual Studio 2022 with the
"SQL Server Integration Services Projects" extension installed). It's modeled directly on `CNHReman.SSIS.VLM`'s package: one Sequence
Container, one Execute Process Task per step, chained with success-only precedence
constraints, and a single `User::PartiumSyncBatPath` variable driving both tasks' `Executable`
property via a `PropertyExpression` (same pattern VLM uses for its own exe path).

The full design rationale for *why* it's built this way lives in
`CNHReman.SyteLine.PartiumSync`'s own repo, not duplicated here — see
`docs/SSIS_Package_Instructions.md` and `CLAUDE.md`'s "Configuration" section. This README
only covers what's specific to this SSIS project.

## Control flow

```
Sequence Container
  SYNCPARTIUM  -->  TRIGGERIMPORT
```

Two Execute Process Tasks, chained success-only (the default precedence constraint behavior —
`TRIGGERIMPORT` only runs if `SYNCPARTIUM` actually succeeded). Both tasks call the *same*
wrapper `.bat` (via `@[User::PartiumSyncBatPath]`), passing their own mode as a fixed
`Arguments` value — exactly how VLM's package drives 4 tasks off one `VLMexePath` variable.

## Why a wrapper `.bat` instead of calling the `.exe` directly

Unlike VLM's `CNHReman.SyteLine.VLM.exe` (called directly, no environment switching needed),
PartiumSync reads `DOTNET_ENVIRONMENT` to pick its config, and SSIS's Execute Process Task has
no first-class way to set an environment variable for the child process. `Scripts/*.bat` sets
`DOTNET_ENVIRONMENT` and then calls `CNHReman.SyteLine.PartiumSync.exe` with whatever arguments
it was given (`%*`) — so one `.bat` per environment covers both `SYNCPARTIUM` and
`TRIGGERIMPORT`.

- **`RunPartiumSync-Test.bat`** — what `PartiumSyncBatPath` points at today. Safe to schedule
  now (full-scale, validated against Test → `cnh-reman-dev`).
- **`RunPartiumSync-ProductionToSandbox.bat`** — real Production SyteLine data, still targets
  the sandbox Partium org. For rehearsal, not (yet) for a recurring schedule.
- **`RunPartiumSync-Production.bat`** — **do not wire this into a scheduled package.** Writes
  to the real `cnh-reman` Partium org, which this app has never been approved to write to. Kept
  in source control only so switching to it later (once approved) is a one-line
  `PartiumSyncBatPath` value change, not a new file written under time pressure.

## Deploying

1. Publish `CNHReman.SyteLine.PartiumSync` as a self-contained `win-x64` build (see that repo's
   README/`docs/SSIS_Package_Instructions.md`) and copy the output to the target server.
2. Copy the `.bat` file for the environment you're targeting into that **same** folder — the
   scripts resolve the `.exe` relative to their own location (`%~dp0`), so they must sit next
   to it, not somewhere else.
3. In `PartiumSync.dtproj` → `Package.dtsx`, confirm `User::PartiumSyncBatPath` points at that
   exact deployed path. It currently assumes `C:\exe\CNHReman.Syteline.PartiumSync\PartiumSync\`
   — **double-check this against wherever it's actually deployed on the target server**, this
   was carried over from an earlier manual deployment and hasn't been re-confirmed for this
   package specifically.
4. Deploy the `.ispac` (Project Deployment Model) to the target SSISDB, or run the `.dtsx`
   directly via a SQL Agent job step / Execute Process — whichever matches how VLM's own
   package is scheduled today.

## Known gaps, same as the main app

- No overlap protection — nothing stops a second run starting while a prior one is still going.
  Not a real risk at the intended once-daily cadence.
- `TRIGGERIMPORT` can take up to ~20 minutes if Partium's import is slow; a timeout there is
  logged as a warning and still exits `0` (the data push already succeeded), so it won't fail
  this step even on a slow day.
