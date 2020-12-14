"""
    MassInstallAction

Install or update GitHub Action workflows on repositories

API (all require qualification with `MassInstallAction`):

- Workflow creation: `Workflow`, `compat_helper`, `tag_bot`, `version_vigilante`
- Workflow installation: `install`
"""
module MassInstallAction

include("types.jl")

include("public.jl")

include("default_workflows.jl")
include("repo_url.jl")
include("utils.jl")

end # module
