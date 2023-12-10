using Pkg
using CondaPkg

# Helper functions
function win_path_to_unix_path(path::AbstractString)
    drive, path = splitdrive(normpath(path))
    return "/" * lowercase(drive[1]) * replace(path, "\\" => "/")
end

# Parse ARGS
args_len = length(ARGS)
if args_len == 0
    force_resolve = false
elseif args_len == 1
    force_resolve = parse(Bool, ARGS[1])
end

# Instantiate
Pkg.instantiate()
CondaPkg.resolve(; force=force_resolve)


# Write .envrc
CondaPkg.backend() in (:Null, :Current) && return
open(".envrc", "w") do io
    println("#!/bin/bash")
    if Sys.iswindows()
        path_sep = ':'
        old_path = join(
            map(
                win_path_to_unix_path,
                split(get(ENV, "PATH", ""), ";")
            ),
            path_sep
        )
        env_dir = win_path_to_unix_path(CondaPkg.envdir())
        new_path = join(
            map(
                win_path_to_unix_path,
                CondaPkg.bindirs()
            ),
            path_sep
        )
        if CondaPkg.backend() == :MicroMamba
            println(io, "export MAMBA_ROOT_PREFIX=\"$(win_path_to_unix_path(CondaPkg.MicroMamba.root_dir()))\"")
            new_path = "$(new_path)$(path_sep)$(dirname(win_path_to_unix_path(CondaPkg.MicroMamba.executable())))"
        end
        if old_path != ""
            new_path = "$(new_path)$(path_sep)$(old_path)"
        end
        println(io, "export PATH=\"$(new_path)\"")
        println(io, "export CONDA_PREFIX=\"$(env_dir)\"")
        println(io, "export CONDA_DEFAULT_ENV=\"$(env_dir)\"")
        println(io, "export CONDA_SHLVL=1")
        println(io, "export CONDA_PROMPT_MODIFIER=\"($(env_dir))\"")
        println(io, "alias conda=\"$(win_path_to_unix_path(join(CondaPkg.conda_cmd().exec, " "))) -p $(env_dir)\"")
    else
        CondaPkg.withenv() do
            if CondaPkg.backend() == :MicroMamba
                println(io, "export MAMBA_ROOT_PREFIX=\"$(ENV["MAMBA_ROOT_PREFIX"])\"")
            end
            println(io, "export PATH=\"$(ENV["PATH"])\"")
            println(io, "export CONDA_PREFIX=\"$(ENV["CONDA_PREFIX"])\"")
            println(io, "export CONDA_DEFAULT_ENV=\"$(ENV["CONDA_DEFAULT_ENV"])\"")
            println(io, "export CONDA_SHLVL=$(ENV["CONDA_SHLVL"])")
            println(io, "export CONDA_PROMPT_MODIFIER=\"$(ENV["CONDA_PROMPT_MODIFIER"])\"")
            println(io, "alias conda=\"$(join(CondaPkg.conda_cmd().exec, " ")) -p $(CondaPkg.STATE.conda_env)\"")
        end
    end
end
