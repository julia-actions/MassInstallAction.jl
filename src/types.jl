"""
    Workflow(actionname, files_to_create, [files_to_delete])

Create or modify a GitHub Action workflow. `actionname` is the name given to the action when it runs.
`files_to_create` should consist of one or more `filename => filecontents` pairs specifying the workflow file(s)
you want to create or update. The optional `files_to_delete` lists one or more workflow files you want to delete.
"""
struct Workflow
    name::String
    files_to_create::Dict{String, String}
    files_to_delete::Set{String}

    # Block the generic fallback
    Workflow(name::String, files_to_create::Dict{String, String}, files_to_delete::Set{String}) = new(name, files_to_create, files_to_delete)
end

Workflow(name::AbstractString, files_to_create, files_to_delete) = Workflow(String(name), normdict(files_to_create), normss(files_to_delete))
Workflow(name::AbstractString, files_to_create) = Workflow(String(name), normdict(files_to_create), Set{String}())

normdict(files_to_create::AbstractDict) = convert(Dict{String,String}, files_to_create)
normdict(files_to_create::Pair) = Dict{String,String}(files_to_create)
normdict(files_to_create::AbstractVector{<:Pair}) = Dict{String,String}(files_to_create)

normss(files_to_delete::AbstractSet) = convert(Set{String}, files_to_delete)
normss(files_to_delete) = Set{String}(files_to_delete)
normss(files_to_delete::AbstractString) = normss([files_to_delete])
