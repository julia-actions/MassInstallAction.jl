struct Workflow
    name::String
    files_to_create::Dict{String, String}
    files_to_delete::Set{String}
end
