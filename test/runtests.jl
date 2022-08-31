using MassInstallAction
using Test

@testset "MassInstallAction.jl" begin
    @testset "types.jl" begin
        @test MassInstallAction.Workflow("a", Dict("file"=>"stuff"), Set(["bad"])) isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", Dict("file"=>"stuff"), "bad") isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", Dict("file"=>"stuff")) isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", "file"=>"stuff", Set(["bad"])) isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", "file"=>"stuff", "bad") isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", "file"=>"stuff") isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", ["file1"=>"stuff1", "file2"=>"stuff2"], Set(["bad"])) isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", ["file1"=>"stuff1", "file2"=>"stuff2"], "bad") isa MassInstallAction.Workflow
        @test MassInstallAction.Workflow("a", ["file1"=>"stuff1", "file2"=>"stuff2"]) isa MassInstallAction.Workflow
    end

    @testset "public.jl" begin
    end

    @testset "repo_url.jl" begin
        @test MassInstallAction._get_repo_url_with_auth("MYORG", "MYPKG"; token = "MYTOKEN") == "https://x-access-token:MYTOKEN@github.com/MYORG/MYPKG.jl"
        @test MassInstallAction._get_repo_url_with_auth("MYORG", "MYPKG"; token = nothing) == "https://github.com/MYORG/MYPKG.jl"
    end

    @testset "default workflows" begin
        @test MassInstallAction.compat_helper() isa MassInstallAction.Workflow
        @test MassInstallAction.tag_bot() isa MassInstallAction.Workflow
    end
end
