function c = initC(L)
    c = zeros(4,L);
    for tp = 1:4
        c(tp,1) = 1000^(tp-1);
    end
end
