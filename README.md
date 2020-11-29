# MassInstallAction

[![Build Status](https://github.com/bcbi/MassInstallAction.jl/workflows/CI/badge.svg)](https://github.com/bcbi/MassInstallAction.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/bcbi/MassInstallAction.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/MassInstallAction.jl)

```julia
julia> workflow = MassInstallAction.compat_helper()

julia> workflow = MassInstallAction.tag_bot()

julia> workflow = MassInstallAction.version_vigilante()
```

## Examples

### Install a workflow on all repositories in your GitHub organization

First make sure that you have an environment variable
named `MY_GITHUB_TOKEN` that contains a GitHub personal
access token, and then run the following code.

Replace
`MY_ORGANIZATION` with the name of your GitHub
organization.

Replace `MY_USERNAME`, `ANOTHER_ORG_ADMIN`, etc. with your username and the
usernames of other administrators in your GitHub
organization.

```julia
julia> using MassInstallAction

julia> workflow = MassInstallAction.compat_helper()

julia> MassInstallAction.install(workflow,
                                 "MY_ORGANIZATION";
                                 token = ENV["MY_GITHUB_TOKEN"],
                                 cc = ["MY_USERNAME", "ANOTHER_ORG_ADMIN"])
```

### Install a workflow on all repositories in your personal GitHub account

First make sure that you have an environment variable
named `MY_GITHUB_TOKEN` that contains a GitHub personal
access token, and then run the following code.

Replace `MY_USERNAME` with your GitHub username.

```julia
julia> using MassInstallAction

julia> workflow = MassInstallAction.compat_helper()

julia> MassInstallAction.install(workflow,
                                 "MY_USERNAME";
                                 token = ENV["MY_GITHUB_TOKEN"],
                                 cc = ["MY_USERNAME"])
```


### Generating GitHub personal access token

To generate the GitHub personal access token, follow the instructions from [this official link](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

You should give these access in your GitHub token:

- repo access:
![image](https://user-images.githubusercontent.com/16418197/97649382-329a0980-1a25-11eb-8bc1-70f36c882586.png)

- workflow access:
![image](https://user-images.githubusercontent.com/16418197/97649452-5eb58a80-1a25-11eb-8c19-93628a349d9b.png)
