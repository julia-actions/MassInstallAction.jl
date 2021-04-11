import HTTP

function compat_helper()
    name = "CompatHelper"
    files_to_create = Dict{String, String}()
    files_to_create["CompatHelper.yml"] = String(HTTP.get("https://raw.githubusercontent.com/JuliaRegistries/CompatHelper.jl/master/.github/workflows/CompatHelper.yml").body)
    files_to_delete = Set{String}()
    return Workflow(name, files_to_create, files_to_delete)
end

function tag_bot()
    name = "TagBot"
    files_to_create = Dict{String, String}()
    files_to_create["TagBot.yml"] = String(HTTP.get("https://raw.githubusercontent.com/JuliaRegistries/TagBot/master/example.yml").body)
    files_to_delete = Set{String}()
    return Workflow(name, files_to_create, files_to_delete)
end
