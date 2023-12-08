using Pkg
using CondaPkg

# Parse ARGS
args_len = length(ARGS)
if args_len == 0
    force_resolve = false
    skip_install = false
elseif args_len == 1
    force_resolve = parse(Bool, ARGS[1])
    skip_install = false
elseif args_len == 2
    force_resolve = parse(Bool, ARGS[1])
    skip_install = parse(Bool, ARGS[2])
end

# Instantiate
if skip_install
    Pkg.instantiate()
    CondaPkg.resolve(; force=force_resolve)
end

# Write .env
CondaPkg.backend() in (:Null, :Current) && return
open(".env", "w") do io
    if Sys.iswindows()  # TODO
        path_sep = ':'
        old_path = join(map(x -> replace(x, "\\" => "/"), split(get(ENV, "PATH", ""), ";")), path_sep)
        env_dir = replace(CondaPkg.envdir(), "\\" => "/")
        new_path = join(map(x -> replace(x, "\\" => "/"), CondaPkg.bindirs()), path_sep)
        if CondaPkg.backend() == :MicroMamba
            println(io, "MAMBA_ROOT_PREFIX=$(replace(CondaPkg.MicroMamba.root_dir(), "\\" => "/"))")
            new_path = "$(new_path)$(path_sep)$(dirname(replace(CondaPkg.MicroMamba.executable(), "\\" => "/")))"
        end
        if old_path != ""
            new_path = "$(new_path)$(path_sep)$(old_path)"
        end
        println(io, "PATH=$(new_path)")
        println(io, "CONDA_PREFIX=$(env_dir)")
        println(io, "CONDA_DEFAULT_ENV=$(env_dir)")
        println(io, "CONDA_SHLVL=1")
        println(io, "CONDA_PROMPT_MODIFIER=($(env_dir))")
        println(io, "alias conda='$(replace(join(CondaPkg.conda_cmd().exec, " "), "\\" => "/")) -p $(env_dir)'")
    else
        CondaPkg.withenv() do
            if CondaPkg.backend() == :MicroMamba
                println(io, "MAMBA_ROOT_PREFIX=$(ENV["MAMBA_ROOT_PREFIX"])")
            end
            println(io, "PATH=$(ENV["PATH"])")
            println(io, "CONDA_PREFIX=$(ENV["CONDA_PREFIX"])")
            println(io, "CONDA_DEFAULT_ENV=$(ENV["CONDA_DEFAULT_ENV"])")
            println(io, "CONDA_SHLVL=$(ENV["CONDA_SHLVL"])")
            println(io, "CONDA_PROMPT_MODIFIER=$(ENV["CONDA_PROMPT_MODIFIER"])")
            println(io, "alias conda='$(join(CondaPkg.conda_cmd().exec, " ")) -p $(CondaPkg.STATE.conda_env)'")
        end
    end
end

# CondaPkg.withenv() do
#     open(".env", "w") do io
#         println(io, "PATH=$(ENV["PATH"])")
#         println(io, "CONDA_PREFIX=$(ENV["CONDA_PREFIX"])")
#         println(io, "CONDA_DEFAULT_ENV=$(ENV["CONDA_DEFAULT_ENV"])")
#         println(io, "CONDA_SHLVL=$(ENV["CONDA_SHLVL"])")
#         println(io, "CONDA_PROMPT_MODIFIER=$(ENV["CONDA_PROMPT_MODIFIER"])")
#         println(io, "alias conda='$(join(CondaPkg.conda_cmd().exec, " ")) -p $(CondaPkg.STATE.conda_env)'")
#     end
# end
