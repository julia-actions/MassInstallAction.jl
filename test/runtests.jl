using MassInstallAction
using Test

@testset "MassInstallAction.jl" begin
    @testset "public.jl" begin
        for workflow in [MassInstallAction.compat_helper(),
                         MassInstallAction.version_vigilante()]
            @test MassInstallAction.install(workflow, "bcbi"; token = nothing, cc = ["@bcbi"]) == nothing
        end
    end

    @testset "repo_url.jl" begin
        @test MassInstallAction._get_repo_url_with_auth("MYORG", "MYPKG"; token = "MYTOKEN") == "https://x-access-token:MYTOKEN@github.com/MYORG/MYPKG.jl"
        @test MassInstallAction._get_repo_url_with_auth("MYORG", "MYPKG"; token = nothing) == "https://github.com/MYORG/MYPKG.jl"
    end
end
