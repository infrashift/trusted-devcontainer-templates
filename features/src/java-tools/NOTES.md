# java-tools

The Java language server LazyVim's java extra (`lazyvim` feature,
`extras=lang.java`) starts: the Eclipse JDT Language Server, with lombok.

| Piece | From | Verified by |
|---|---|---|
| jdtls | `download.eclipse.org/jdtls/milestones/<version>/jdt-language-server-<version>-<build>.tar.gz` | SHA256 (the one Eclipse publishes beside it) |
| lombok | Maven Central | SHA256 of the jar, cross-checked against Maven Central's SHA-1 |
| `~/.local/bin/jdtls` | rendered | a shell launcher |

Installed userland: jdtls under `~/.local/share/jdtls/<version>`, the lombok jar
beside it with `lombok.jar` pointing at it, and the launcher in `~/.local/bin`.

## The launcher

The upstream `bin/jdtls` is a Python script and the base image has no Python,
so the feature renders a shell launcher that takes the same arguments
nvim-jdtls passes -- `-configuration <dir>`, `-data <dir>`, `--jvm-arg=<arg>`
(repeatable) -- and always adds `-javaagent` for lombok. The per-project
configuration and workspace default to `~/.cache/jdtls/`.

LazyVim's java extra would otherwise append a lombok agent under Mason's
directory, which does not exist in these images; the lazyvim feature's
`infrashift.extras.java` makes the command just `jdtls`.

## Requirements

A JDK 21 at run time (jdtls needs 21): the trusted `openjdk` feature. The
launcher uses `$JAVA_HOME/bin/java`, then `~/.local/share/java/bin/java`, then
`java` on `PATH`. Nothing at install time runs Java.

A build behind an egress allow-list needs `download.eclipse.org` and
`repo1.maven.org`.

## Options

| Option | Default | |
|---|---|---|
| `jdtls_version` | `1.61.0` | milestone version |
| `jdtls_build` | `202609031315` | build timestamp in the tarball name |
| `jdtls_checksum` | `""` | SHA256; empty uses the pinned map |
| `lombok_version` | `1.18.48` | |
| `lombok_checksum` | `""` | SHA256; empty uses the pinned map |
