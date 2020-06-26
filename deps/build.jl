import Libdl

const DEFAULT_PATH_URL = "http://pages.cs.wisc.edu/~ferris/path/julia/"

function download_path()
    libpath = if Sys.islinux() &&  Sys.ARCH == :x86_64
        "libpath50.so"
    elseif Sys.isapple()
        "libpath50.dylib"
    elseif Sys.iswindows()
        "path50.dll"
    else
        error(
            "Unsupported operating system. Only 64-bit linux, OSX, and Windows are supported."
        )
    end
    ENV["PATH_JL_LOCATION"] = joinpath(@__DIR__, libpath)
    download(joinpath(DEFAULT_PATH_URL, libpath), ENV["PATH_JL_LOCATION"])
    return
end

function install_path()
    if !haskey(ENV, "PATH_JL_LOCATION")
        download_path()
    end
    local_filename = get(ENV, "PATH_JL_LOCATION", nothing)
    if local_filename === nothing
        error("Environment variable `PATH_JL_LOCATION` not found.")
    elseif Libdl.dlopen(local_filename) == C_NULL
        error("Unable to open the path library $(local_filename).")
    end
    open("deps.jl", "w") do io
        write(io, "const PATH_SOLVER = \"$(escape_string(local_filename))\"")
    end
end

install_path()
