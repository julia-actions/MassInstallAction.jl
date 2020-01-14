function _get_repo_url_with_auth(org::AbstractString, pkg::AbstractString; token::Union{AbstractString, Nothing})
    if token === nothing
        return "https://@github.com/$(org)/$(pkg).jl"
    else
        return "https://x-access-token:$(token)@github.com/$(org)/$(pkg).jl"
    end
end
