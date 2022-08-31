# import GitCommand: git
import GitHub

function git(f)
  return f("git")
end

"""
    MassInstallAction.install(workflow, user_or_org::AbstractString, [pkgs]; token, cc::AbstractVector{<:AbstractString})

Submit a pull request to install `workflow` for all packages owned by `user_or_org`.
`token` is your personal access token for authentication, or `nothing` if you do not have privileges and need to fork the package.
`cc` is a list of GitHub usernames that should receive notification about this pull request (beyond the regular watchers).

If `pkgs` is supplied, pull requests will only be made to the listed packages.
"""
function install(
    workflow::Workflow,
    org::AbstractString;
    token::Union{AbstractString,Nothing},
    cc::AbstractVector{<:AbstractString},
    ignore_forks::Bool=true,
)
    if token === nothing
        auth = nothing
    else
        auth = GitHub.authenticate(token)
    end
    if auth === nothing
        orgrepos, page_data = GitHub.repos(org)
    else
        orgrepos, page_data = GitHub.repos(org; auth = auth)
    end

    if ignore_forks
        orgrepos = [repo for repo in orgrepos if repo.fork == false]
    end

    pkgs = Vector{String}(undef, 0)
    for r in orgrepos
        name = r.name
        endswith(name, ".jl") && push!(pkgs, name[1:(end-3)])
    end
    unique!(pkgs)
    sort!(pkgs)
    install(workflow,
            org,
            pkgs;
            cc = cc,
            token = token)
    return nothing
end

function install(workflow::Workflow,
                 org::AbstractString,
                 pkgs::AbstractVector{<:AbstractString};
                 token,
                 cc::AbstractVector{<:AbstractString})
    if token === nothing
        auth = nothing
    else
        auth = GitHub.authenticate(token)
    end
    cc_string = string("cc: ", join(string.("@",
                                            strip.(strip.(strip.(cc),
                                                          '@'))), " "))
    pr_body = "This pull request sets up the $(workflow.name) workflow on this repository. $(cc_string)"
    for pkg in pkgs
        if auth === nothing
            pkgrepo = GitHub.repo("$(org)/$(pkg).jl")
        else
            pkgrepo = GitHub.repo("$(org)/$(pkg).jl";
                                  auth = auth)
        end
        install(workflow, pkgrepo; auth=auth, pr_body=pr_body)

        # Avoid GitHub secondary rate limits
        # https://docs.github.com/en/rest/overview/resources-in-the-rest-api#secondary-rate-limits
        sleep(1)
    end
end

"""
    MassInstallAction.install(workflow, repo::GitHub.Repo;
                              auth, pkg_url_type::Symbol = :html,
                              pr_branch_name=..., pr_title=..., pr_body=..., commit_message=...)

Submit a pull request to install `workflow` for repository `repo`. This version of `install` is
designed to work in concert with [GitHub.jl](https://github.com/JuliaWeb/GitHub.jl), so that you can run queries, filter results,
and then submit changes. See the documentation of that package for more detail about `repo` and `auth`.

`pkg_url_type` can be `:html` or `:ssh`.

The remaining keywords are all strings, and have generic defaults but allow customization.
"""
function install(workflow::Workflow,
                 repo::GitHub.Repo;
                 auth::Union{Nothing,GitHub.Authorization},
                 pr_branch_name::AbstractString = "massinstallaction/set-up-$(workflow.name)",
                 pr_title::AbstractString = "MassInstallAction: Install the $(workflow.name) workflow on this repository",
                 pr_body::AbstractString = "This pull request sets up the $(workflow.name) workflow on this repository.",
                 commit_message::AbstractString = "Automated commit made by MassInstallAction.jl",
                 pkg_url_type::Symbol = :html)
    if pkg_url_type === :html
        pkg_url_with_auth = repo.html_url.uri
    elseif pkg_url_type === :ssh
        pkg_url_with_auth = repo.ssh_url.uri
    else
        throw(ArguemntError("`pkg_url_type = $(pkg_url_type)` not supported"))
    end
    with_temp_dir() do tmp_dir
        git() do git
            cd(tmp_dir)
            run(`$(git) clone $(pkg_url_with_auth) REPO`)
            cd("REPO")
            run(`$(git) checkout -B $(pr_branch_name)`)
            workflows_directory = joinpath(pwd(), ".github", "workflows")
            mkpath(workflows_directory)
            cd(workflows_directory)
            for filename in workflow.files_to_delete
                rm(filename; force = true, recursive = true)
            end
            for filename in keys(workflow.files_to_create)
                file_content = workflow.files_to_create[filename]
                open(filename, "w") do io
                    print(io, file_content)
                end
            end
            try
                run(`$(git) add -A`)
                run(`$(git) commit -m $(commit_message)`)
                try
                    run(`$(git) push --force origin $(pr_branch_name)`)
                catch
                    # try again?
                    run(`$(git) push --force origin $(pr_branch_name)`)
                end
                params = Dict{String, String}()
                params["title"] = pr_title
                params["head"] = pr_branch_name
                params["base"] = repo.default_branch
                params["body"] = pr_body
                if auth === nothing
                    GitHub.create_pull_request(repo;
                                               params = params)
                else
                    GitHub.create_pull_request(repo;
                                               params = params,
                                               auth = auth)
                end
                @info "Pull request submitted for $(repo.name)"
            catch error
                @warn "Assembling the pull request failed, skipping $(repo.name)"
                show(error)
            end
        end
    end
    return nothing
end
