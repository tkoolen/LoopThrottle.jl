# LoopThrottle

[![Build Status](https://travis-ci.org/tkoolen/LoopThrottle.jl.svg?branch=master)](https://travis-ci.org/tkoolen/LoopThrottle.jl)
[![codecov.io](http://codecov.io/github/tkoolen/LoopThrottle.jl/coverage.svg?branch=master)](http://codecov.io/github/tkoolen/LoopThrottle.jl?branch=master)

Demo:
```julia
julia> using LoopThrottle

julia> function f()
           x = 0
           for t = 1 : 1e-3 : 2
               x += 1
           end
           x
       end
f (generic function with 1 method)

julia> f()
1001

julia> @elapsed f()
4.236e-6

julia> function f_throttled(rate)
           x = 0
           @throttle t for t = 1 : 1e-3 : 2
               x += 1
           end max_rate = rate
           x
       end
f_throttled (generic function with 1 method)

julia> f_throttled(Inf)
1001

julia> @elapsed f_throttled(1.)
0.995997566

julia> @elapsed f_throttled(2.)
0.49918721

julia> @elapsed f_throttled(Inf)
7.76e-6
```
