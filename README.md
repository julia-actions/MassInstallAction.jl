# MassInstallAction

[![Build Status](https://travis-ci.com/bcbi/MassInstallAction.jl.svg?branch=master)](https://travis-ci.com/bcbi/MassInstallAction.jl/branches)
[![Codecov](https://codecov.io/gh/bcbi/MassInstallAction.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/MassInstallAction.jl)

## Example

First make sure that you have an environment variable
named `MY_GITHUB_TOKEN` that contains a GitHub personal
access token, and then run the following code.

Replace
`MY_GITHUB_ORGANIZATION` with the name of your GitHub
organization.

Replace `MY_USERNAME`, `ANOTHER_ORG_ADMIN`,
and `YET_ANOTHER_ORG_ADMIN` with your username and the
usernames of other administrators in your GitHub
organization.

```julia
julia> using MassInstallAction

julia> workflow = MassInstallAction.compat_helper()

julia> MassInstallAction.install(workflow,
                                 "MY_GITHUB_ORGANIZATION";
                                 token = ENV["MY_GITHUB_TOKEN"],
                                 cc = ["MY_USERNAME", "ANOTHER_ORG_ADMIN", "YET_ANOTHER_ORG_ADMIN"])
```
