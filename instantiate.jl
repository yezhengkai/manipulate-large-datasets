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
CondaPkg.withenv() do
    open(".env", "w") do io
        println(io, "PATH=$(ENV["PATH"])")
        println(io, "CONDA_PREFIX=$(ENV["CONDA_PREFIX"])")
        println(io, "CONDA_DEFAULT_ENV=$(ENV["CONDA_DEFAULT_ENV"])")
        println(io, "CONDA_SHLVL=$(ENV["CONDA_SHLVL"])")
        println(io, "CONDA_PROMPT_MODIFIER=$(ENV["CONDA_PROMPT_MODIFIER"])")
        println(io, "alias conda='$(join(CondaPkg.conda_cmd().exec, " ")) -p $(CondaPkg.STATE.conda_env)'")
    end
end
