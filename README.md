# MassInstallAction

[![Build Status](https://github.com/julia-actions/MassInstallAction.jl/workflows/CI/badge.svg)](https://github.com/julia-actions/MassInstallAction.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/julia-actions/MassInstallAction.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/julia-actions/MassInstallAction.jl)

Install a [GitHub Action](https://docs.github.com/en/free-pro-team@latest/actions) [workflow file](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) in one or more repositories.

There are two key steps: (1) creating the `workflow` and (2) installing it, a.k.a,
submitting it as pull request(s) to one or more packages.

## Creating the workflow

Some workflows have convenient helpers:

```julia
julia> workflow = MassInstallAction.compat_helper()      # workflow for https://github.com/JuliaRegistries/CompatHelper.jl

julia> workflow = MassInstallAction.tag_bot()            # workflow for https://github.com/JuliaRegistries/TagBot
```

or you can create your own:

```julia
workflow = MassInstallAction.Workflow("MyWorkflow", "workflow_filename.yml" => read("/home/me/template_workflow_file.yml", String))
```

where you replace:

- `"/home/me/template_workflow_file.yml"` with the path to the local file you've prepared with the desired contents of the workflow;
- `"workflow_filename.yml"` with the name you want the file to have in the repositories' `.github/workflows` directory;
- `"MyWorkflow"` with the name used to identify this workflow when Actions runs.

You can add multiple workflow files simultaneously or even delete files, see `?MassInstallAction.Workflow`.

## Installing the workflow: examples

### Install a workflow on all repositories in your GitHub organization

First make sure that you have an environment variable
named `MY_GITHUB_TOKEN` that contains a GitHub personal
access token (see below), and then run the following code.

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

### Interaction with GitHub.jl

This package uses and interacts with [GitHub.jl](https://github.com/JuliaWeb/GitHub.jl). In addition to the options above, you can `MassInstallAction.install(workflow, repo::GitHub.Repo)` directly. This may be the easiest approach if you want to filter repositories based on specific criteria. See `?MassInstallAction.install` for more information.

### Generating GitHub personal access token

To generate the GitHub personal access token, follow the instructions from [this official link](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

You should give these access in your GitHub token:

- repo access:
![image](https://user-images.githubusercontent.com/16418197/97649382-329a0980-1a25-11eb-8bc1-70f36c882586.png)

- workflow access:
![image](https://user-images.githubusercontent.com/16418197/97649452-5eb58a80-1a25-11eb-8c19-93628a349d9b.png)
