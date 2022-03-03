    lresol=10
    rlresol=10.0
    clf
    for i=1:3
        fc=pi/single(i+2);
        for l=-lresol:1:-1
          rl = single(l);
          weight(l+lresol+1) = sin(fc*rl) * sin(pi*rl/rlresol) * rlresol / pi / rl / pi / rl
        end
        for l=1:1:lresol
          rl = single(l)
          weight(l+lresol+1) = sin(fc*rl) * sin(pi*rl/rlresol) * rlresol / pi / rl / pi / rl
        end
    
        weight(lresol+1) = fc / pi
        switch(i)
        case(1)
           plot(weight,'b');hold on
        case(2)
           plot(weight,'r');
        case(3)
           plot(weight,'g');
        end
    end
