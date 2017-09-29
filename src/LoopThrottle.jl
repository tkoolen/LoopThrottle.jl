module LoopThrottle

export
    @throttle

function loop_throttle_params(; max_rate = 1., min_sleep_time = 1e-2)
    min_sleep_time >= 0.001 || error("min_sleep_time must be at least 0.001")
    Float64(max_rate), Float64(min_sleep_time)
end

"""
Throttle a loop by sleeping periodically (with minimum duration `minsleeptime`),
so that `t` doesn't increase faster than `maxrate`.

Note that the sleep function rounds to 1e-3.

Decreasing minsleeptime makes throttling smoother (more frequent, shorter pauses),
but reduces accuracy due to rounding error.

"""
macro throttle(t::Symbol, loopexpr::Expr, params::Expr...)
    foreach(params) do expr
        @assert expr.head == :(=)
        expr.head = :kw
        expr.args[2] = esc(expr.args[2])
    end

    setup = quote
        max_rate, min_sleep_time = loop_throttle_params($(params...))
        firstloop = true
        local t0
        local walltime0
    end

    @assert loopexpr.head ∈ (:while, :for)
    loopcondition = loopexpr.args[1]
    loopbody = loopexpr.args[2]
    newloopbody = quote
        if firstloop
            t0 = $(esc(t))
            walltime0 = time()
            firstloop = false
        end

        $(esc(loopbody))

        if !isinf(max_rate)
            Δwalltime = time() - walltime0
            Δt = $(esc(t)) - t0
            sleeptime = Δt / max_rate - Δwalltime
            if sleeptime > min_sleep_time
                sleep(sleeptime)
            end
        end
    end
    loop = Expr(loopexpr.head, :($(esc(loopcondition))), newloopbody)

    quote
        $setup
        $loop
    end
end

end # module
