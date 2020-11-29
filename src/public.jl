# import GitCommand: git
import GitHub

function git(f)
  return f("git")
end

function install(workflow::Workflow,
                 org::AbstractString;
                 token::Union{AbstractString, Nothing},
                 cc::AbstractVector{<:AbstractString})
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
    my_pr_branch_name = "massinstallaction/set-up-$(workflow.name)"
    my_pr_title = "MassInstallAction: Install the $(workflow.name) workflow on this repository"
    my_pr_body = "This pull request sets up the $(workflow.name) workflow on this repository. $(cc_string)"
    for pkg in pkgs
        if auth === nothing
            pkgrepo = GitHub.repo("$(org)/$(pkg).jl")
        else
            pkgrepo = GitHub.repo("$(org)/$(pkg).jl";
                                  auth = auth)
        end
        pkg_url_with_auth = _get_repo_url_with_auth(org, pkg; token = token)
        with_temp_dir() do tmp_dir
            git() do git
                cd(tmp_dir)
                run(`$(git) clone $(pkg_url_with_auth) REPO`)
                cd("REPO")
                run(`$(git) checkout -B $(my_pr_branch_name)`)
                workflows_directory = joinpath(pwd(), ".github", "workflows")
                mkpath(workflows_directory)
                cd(workflows_directory)
                for filename in workflow.files_to_delete
                    rm(filename; force = true, recursive = true)
                end
                for filename in keys(workflow.files_to_create)
                    file_content = workflow.files_to_create[filename]
                    rm(filename; force = true, recursive = true)
                    open(filename, "w") do io
                        print(io, file_content)
                    end
                end
                run(`$(git) add -A`)
                try
                    run(`$(git) commit -m "Automated commit made by MassInstallAction.jl"`)
                catch
                end
                try
                    run(`$(git) push origin $(my_pr_branch_name)`)
                catch
                end
                try
                    run(`$(git) push --force origin $(my_pr_branch_name)`)
                catch
                end
                params = Dict{String, String}()
                params["title"] = my_pr_title
                params["head"] = my_pr_branch_name
                params["base"] = pkgrepo.default_branch
                params["body"] = my_pr_body
                if auth === nothing
                    try
                        GitHub.create_pull_request(pkgrepo;
                                                   params = params)
                    catch
                    end
                else
                    try
                        GitHub.create_pull_request(pkgrepo;
                                                   params = params,
                                                   auth = auth)
                    catch
                    end
                end
            end
        end
    end
    return nothing
end
