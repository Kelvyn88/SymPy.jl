

## for symbolic functions (dsolve.jl)
(u::SymFunction)(x::Base.Dict) = throw(ArgumentError("IVPsolutions can only be called with symbolic objects"))
(u::SymFunction)(x::Base.Pair) = throw(ArgumentError("IVPsolutions can only be called with symbolic objects"))
function (u::SymFunction)(x)
    if u.n == 0
        PyObject(u)(x) #u.x(PyObject(x))
    else
        __x = Sym("__x")
        diff(u.x(PyObject(__x)), __x, u.n)(__x => x)
    end
end

(u::SymFunction)(x, y...) = u.n== 0 ? u.x(map(PyObject, vcat(x, y...))...) : error("Need to implement derivatives of symbolic functions of two or more variables")


## Call symbolic object with natural syntax
## ex(x=>val)
## how to do from any symbolic object?
(ex::Sym)() = ex
function (ex::Sym)(args...)
    xs = free_symbols(ex)
    if length(xs) >= 1
        subs(ex, collect(zip(xs, args))...)
    else
        if classname(ex) == "Symbol"
            ex
        else
            pycall(PyObject(ex), PyAny, args...)
        end
    end
end
(ex::Sym)(x::Dict) = subs(ex, x)
(ex::Sym)(x::Pair...) = subs(ex, x...)
