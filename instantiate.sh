#!/usr/bin/env bash

# TODO
# - pass `resolve_force`
# - Windows PATH to posix path conversion when user use Git Bash
resolve_force=false

# shellcheck disable=SC2016
julia --project=. --startup-file=no --banner=no -e '
    using Pkg, CondaPkg
    Pkg.instantiate()
    # CondaPkg.resolve(; force=true)
    CondaPkg.resolve(; force=${resolve_force})
    CondaPkg.withenv() do
        open(".env", "w") do io
            println(io, "PATH=$(ENV["PATH"])")
            println(io, "CONDA_PREFIX=$(ENV["CONDA_PREFIX"])")
            println(io, "CONDA_DEFAULT_ENV=$(ENV["CONDA_DEFAULT_ENV"])")
            println(io, "CONDA_SHLVL=$(ENV["CONDA_SHLVL"])")
            println(io, "CONDA_PROMPT_MODIFIER=$(ENV["CONDA_PROMPT_MODIFIER"])")
        end
    end
'

# TODO: get conda command
# conda_cmd=$(julia --project=. --startup-file=no --banner=no -e 'using CondaPkg; println(CondaPkg.conda_cmd(""))')
# echo "${conda_cmd}"
