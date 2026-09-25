# go-tools

The Go tools an editor expects on `PATH`, each pinned to an exact version. The
image this replaces ran `go install …@latest`.

| Tool | Built from | How |
|---|---|---|
| gopls | `golang.org/x/tools/gopls` | `go install` |
| gofumpt | `mvdan.cc/gofumpt` | `go install` |
| goimports | `golang.org/x/tools/cmd/goimports` | `go install` |
| gomodifytags | `github.com/fatih/gomodifytags` | `go install` |
| impl | `github.com/josharian/impl` | `go install` |
| dlv | `github.com/go-delve/delve/cmd/dlv` | `go install` |
| golangci-lint | release tarball | `get_url`, SHA256 pinned per arch |

## How the `go install` builds are verified

Go checks every module it downloads against the public checksum database. The
role sets the build environment in full, so nothing inherited can switch that
off:

- `GOPROXY=https://proxy.golang.org` and `GOSUMDB=sum.golang.org`, with no
  `direct` fallback.
- `GONOSUMDB`, `GONOSUMCHECK`, `GOPRIVATE`, `GONOPROXY` and `GOINSECURE` set
  to empty, and `GOENV=off`.
- `GOTOOLCHAIN=local`. A tool that needs a newer Go than the golang feature
  provides fails with that error, instead of quietly downloading a toolchain.
- `-trimpath`, `CGO_ENABLED=0`.

Each binary is verified with `go version -m`, which reads the module version
compiled into it. That is the same check for every tool, and goimports has no
version flag at all.

The module and build caches go to `/tmp/go-tools-build` and are removed in the
same run. They are several GB that serve no purpose at runtime.

Needs Go at build time. It looks for the toolchain the golang feature
installs, and installs after that feature.
