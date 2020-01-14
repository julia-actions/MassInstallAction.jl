import GitCommand: git
import GitHub:

function install(workflow::Workflow,
                 org::AbstractString;
                 token,
                 cc::AbstractVector{<:AbstractString})
    auth = GitHub.authenticate(token)
    orgrepos, page_data = GitHub.repos(org; auth = auth)
    pkgs = Vector{String}(undef, 0)
    for r in orgrepos
        name = r.name
        endswith(name, ".jl") && push!(pkgs, name[1:(end-3)])
    end
    unique!(pkgs)
    sort!(pkgs)
    install(org, pkgs; cc = cc, token = token)
    return nothing
end

function install(workflow::Workflow,
                 org::AbstractString,
                 pkgs::AbstractVector{<:AbstractString};
                 token,
                 cc::AbstractVector{<:AbstractString})
    auth = GitHub.authenticate(token)
    cc_string = string("cc: ", join(string.("@",
                                            strip.(strip.(strip.(cc),
                                                          '@'))), " "))
    my_pr_branch_name = "massinstallaction/set-up-$(workflow.name)"
    my_pr_title = "MassInstallAction: Install the $(workflow.name) workflow on the $(pkg).jl repository"
    my_pr_body = "This pull request sets up the $(workflow.name) workflow on the $(pkg).jl repository. $(cc_string)"
    for pkg in pkgs
        pkgrepo = GitHub.repo("$(org)/$(pkg).jl"; auth = auth)
        pkg_url_with_auth = "https://x-access-token:$(token)@github.com/$(org)/$(pkg).jl"
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
                try
                    GitHub.create_pull_request(pkgrepo;
                                               params = params,
                                               auth = auth)
                catch
                end
            end
        end
    end
    return nothing
end
