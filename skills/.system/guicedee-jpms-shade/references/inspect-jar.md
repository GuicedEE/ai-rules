# Inspect a JAR for module name and packages

Determine the JPMS module name and the exact set of packages to `exports`.

## Locate the JAR in the local repo
```powershell
Get-ChildItem -Path "$env:USERPROFILE\.m2\repository\<group/path>\<artifact>" -Recurse
```

## Read the Automatic-Module-Name (and full manifest)
```powershell
$j = '<path-to>.jar'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [System.IO.Compression.ZipFile]::OpenRead($j)
$e = $z.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' }
$sr = New-Object System.IO.StreamReader($e.Open()); $sr.ReadToEnd(); $sr.Close(); $z.Dispose()
```
- Use the `Automatic-Module-Name` value as the module name.
- If absent, the JAR is a plain automatic module named after the file; choose a stable name
  (usually the root package) and document it.

## Enumerate packages (for `exports`)
```powershell
$j = '<path-to>.jar'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [System.IO.Compression.ZipFile]::OpenRead($j)
$pkgs = $z.Entries | Where-Object { $_.FullName -match '\.class$' } |
    ForEach-Object { ($_.FullName -replace '/[^/]+$','') -replace '/','.' } | Sort-Object -Unique
$z.Dispose(); $pkgs
```
- Export public packages.
- DO NOT export internally relocated/shaded packages (e.g. `*.com.google.*`, `*.org.antlr.*`,
  `*.shaded.*`) — they are implementation detail bundled inside the JAR.

## Read the dependency's declared deps (for `requires`)
Read the upstream POM in the local repo:
```powershell
Get-Content '<path-to>.pom'
```
- `compile`-scope deps NOT relocated inside the JAR → `requires` (or `requires transitive` when
  their types show up in the exported API, e.g. a `Publisher` from reactive-streams).
- Annotation-only deps (jspecify, jsr305, checker-qual, error_prone) → `requires static`.

## Confirm the built module
```powershell
& "$env:JAVA_HOME\bin\jar.exe" --describe-module --file 'target/<artifact>-<ver>.jar'
```

