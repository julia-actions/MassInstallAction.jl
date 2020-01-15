import HTTP

function compat_helper()
    name = "CompatHelper"
    files_to_create = Dict{String, String}()
    files_to_create["CompatHelper.yml"] = String(HTTP.get("https://raw.githubusercontent.com/bcbi/CompatHelper.jl/master/.github/workflows/CompatHelper.yml").body)
    files_to_delete = Set{String}()
    return Workflow(name, files_to_create, files_to_delete)
end

function version_vigilante()
    name = "VersionVigilante"
    files_to_create = Dict{String, String}()
    files_to_create["VersionVigilante_bors.yml"] = String(HTTP.get("https://raw.githubusercontent.com/bcbi/VersionVigilante.jl/master/.github/workflows/VersionVigilante_bors.yml").body)
    files_to_create["VersionVigilante_pull_request.yml"] = String(HTTP.get("https://raw.githubusercontent.com/bcbi/VersionVigilante.jl/master/.github/workflows/VersionVigilante_pull_request.yml").body)
    files_to_delete = Set{String}(["VersionVigilante.yml"])
    return Workflow(name, files_to_create, files_to_delete)
end
