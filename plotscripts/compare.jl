using Omega 
algs = [
        (alg = SSMH,),
        # (alg = NUTS,),
        (alg = Replica, nreplicas = 4, inneralg = SSMH),
        # (alg = Replica, nreplicas = 4, inneralg = NUTS, ΩT = defΩ(NUTS)),
        (alg = Replica, inneralg = HMCFAST, algargs = (nsteps=100,), ΩT = defΩ(HMCFAST)),
        (alg = Replica, inneralg = HMCFAST, algargs = (nsteps=500,), ΩT = defΩ(HMCFAST)),
        ]

probs = [(d = d, delta = delta) for d in (1,100), delta in (0.1, 0.0001)] 

function timeoutafter(f, nsecs)

end

function circ(n, offset = 0.5, delta = 0.1)

  function oncirc(om)
    x_ = normal(om, zeros(n), ones(n))
    # x_ = x(om)
    # y = x_.^2
    # s = sum(y)
    s = prod(x_)
    p1 = (s >ₛ offset) & (s <ₛ offset + delta)
    # p2 = (s <ₛ -offset) & (s >ₛ -offset - delta)
    cond(om, p1)
    x_
  end
  ciid(oncirc)
end

function scat(samples)
  xs, ys = ntranspose(samples)
  scatter(val.(xs), val.(ys))
end

function getdata(n, algs, probs)
  data = []
  for alg in algs, prob in probs
    try
      println("Trying $alg on -> $prob")
      f = circ(prob.d, 0.5, prob.delta)
      x = rand(f, n; alg...)
      push!(data, (x = x, prob = prob, alg = alg, fail = false))
    catch e
      println(e)
      push!(data, (alg = alg, prob = prob, fail = true))
    end
  end
  data
end

data = getdata(10000, algs, probs)

for datum in data
  print("Prob $(datum.prob) alg $(datum.alg)")
  vals = ntranspose(datum.x)
  a = map(mean, vals)
  b = qsrt(mean(a./^2))
  println("")
end
