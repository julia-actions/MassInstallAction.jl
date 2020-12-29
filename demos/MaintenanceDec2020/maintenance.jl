using GitHub, MassInstallAction
import HTTP

# This demo adds or updates workflow files (TagBot, Documenter, and CI) for a set of repositories
# in an organization. In general you should copy/paste these lines after editing them
# to suit your needs. Note that you'll need to specify your GitHub personal access token,
# specify the organization/user, and select repositories interactively.

# authenticate
auth = authenticate(#= your-github-personal-access-token =#)   # don't ever post this publicly!

# Get all the repositories in the JuliaDebug organization
rs = repos(#= organization/user goes here =#, true; auth=auth)[1]   # change true -> false for users (true = "org")

# Optional: filter on various properties, e.g.,
# filter!(r -> !r.fork, rs)    # eliminate all repos that are forks of other repos

# Manually pick a subset of the repositories, using an interactive menu
using REPL.TerminalMenus
menu = MultiSelectMenu([rp.name for rp in rs])
sel = request(menu)   # hit arrows to move through list, Enter to select, and 'd' when done
rs = rs[collect(sel)]

## Key/secret creation

# Create a `DOCUMENTER_KEY` secret and corresponding `Documenter` deploy key, unless the repository
# already has a secret of that name.
# This key is used by TagBot as well as Documenter, so do this even if you don't have any `docs/` in your repository.
for r in rs
    has_secret = false
    for s in secrets(r; auth=auth)[1]
        if s.name == "DOCUMENTER_KEY"
            has_secret = true
            break
        end
    end
    has_secret && continue
    pubkey, privkey = GitHub.genkeys()
    create_deploykey(r; auth=auth, params=Dict("key"=>pubkey, "title"=>"Documenter", "read_only"=>false))
    create_secret(r, "DOCUMENTER_KEY"; auth=auth, value=privkey)
end

## TagBot

# Add or modify the TagBot workflow to use `DOCUMENTER_KEY`. Here we use the templates in MassInstallAction directly,
# but alternatively we could create a workflow script here and use `Workflow("TagBot", "TagBot.yml" => script)`.
#
# Related: https://discourse.julialang.org/t/ann-required-updates-to-tagbot-yml/49249
workflow = MassInstallAction.tag_bot()
for r in rs
    MassInstallAction.install(workflow, r; auth=auth, commit_message="Set up TagBot workflow")
end

## Documenter

script = """
name: Documenter
on:
  push:
    branches: [master]
    tags: [v*]
  pull_request:

jobs:
  Documenter:
    name: Documentation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/julia-buildpkg@latest
      - uses: julia-actions/julia-docdeploy@latest
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
          DOCUMENTER_KEY: \${{ secrets.DOCUMENTER_KEY }}
"""
workflow = MassInstallAction.Workflow("Documenter", "Documenter.yml" => script)
for r in rs
    # Check whether the repo has docs, if not skip it
    filesdirs = directory(r, "."; auth=auth)[1]
    idx = findfirst(fd -> fd.typ == "dir" && fd.name == "docs", filesdirs)
    if idx !== nothing
        MassInstallAction.install(workflow, r; auth=auth, commit_message="Build docs on GitHub Actions")
    end
end

## CI

# Default CI workflow that tests on the same versions as the current .travis.yml

ci_pre = """
name: CI
on:
  pull_request:
  push:
    branches:
      - master
    tags: '*'
jobs:
  test:
    name: Julia \${{ matrix.version }} - \${{ matrix.os }} - \${{ matrix.arch }} - \${{ github.event_name }}
    runs-on: \${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        version:
"""
ci_post = """
        os:
          - ubuntu-latest
          - macOS-latest
          - windows-latest
        arch:
          - x64
    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@v1
        with:
          version: \${{ matrix.version }}
          arch: \${{ matrix.arch }}
      - uses: actions/cache@v1
        env:
          cache-name: cache-artifacts
        with:
          path: ~/.julia/artifacts
          key: \${{ runner.os }}-test-\${{ env.cache-name }}-\${{ hashFiles('**/Project.toml') }}
          restore-keys: |
            \${{ runner.os }}-test-\${{ env.cache-name }}-
            \${{ runner.os }}-test-
            \${{ runner.os }}-
      - uses: julia-actions/julia-buildpkg@v1
      - uses: julia-actions/julia-runtest@v1
      - uses: julia-actions/julia-processcoverage@v1
      - uses: codecov/codecov-action@v1
        with:
          file: lcov.info
"""
for r in rs
    # Check whether the repo has a workflow called "CI.yml", and if so skip it
    try
        filesdirs = directory(r, ".github/workflows"; auth=auth)[1]
        idx = findfirst(fd -> lowercase(fd.name) ∈ ("ci.yml", "ci.yaml"), filesdirs)
        if idx !== nothing
            println("\n\n$(r.name) skipped due to presence of $(filesdirs[idx].name)")
            continue
        end
    catch
    end
    try
        # Parse the .travis.yml file and extract the versions
        url = file(r, ".travis.yml"; auth=auth).download_url
        tscript = String(HTTP.get(url).body)
        lines = split(chomp(tscript), '\n')
        idx = findfirst(isequal("julia:"), lines)
        vs = String[]
        while idx < length(lines)
            idx += 1
            m = match(r"^\s*-\s*(nightly|[\d\.]*)", lines[idx])
            m === nothing && break
            push!(vs, m.captures[1])
        end
        # optional: delete "nightly"
        if !isempty(vs)
            # Build the replacement CI.yml
            script = ci_pre
            for v in vs
                line = " "^10 * "- '" * v * "'\n"
                # optional: comment out nightly
                if v == "nightly"
                    line = "#" * line
                end
                script *= line
            end
            script *= ci_post
            todelete = ["../../.travis.yml"]
            # Find out if there's an appveyor and set it up for deletion
            filesdirs = directory(r, "."; auth=auth)[1]
            idx = findfirst(fd -> fd.typ == "file" && fd.name ∈ ("appveyor.yml", ".appveyor.yml"), filesdirs)
            if idx !== nothing
                push!(todelete, "../../" * filesdirs[idx].name)
            end
            workflow = MassInstallAction.Workflow("CI", "CI.yml" => script, todelete)
            println("\n\n$(r.name) had .travis.yml script:\n", tscript, "\nInstalling the following CI.yml script:\n", script)
            println("OK to submit pull request? (y/n)")
            resp = readline(; keep=false)
            if resp ∈ ("y", "Y", "yes", "Yes", "YES")
                MassInstallAction.install(workflow, r; auth=auth, commit_message="Switch to GitHub Actions for CI")
            end
        end
    catch
        println("\n\nNo .travis.yml found for $(r.name)")
    end
end
