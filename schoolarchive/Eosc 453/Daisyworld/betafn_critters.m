function beta = betafn_critters(ndaisies,t_a, T_opt, k)

if abs(t_a(1) - T_opt) < k^(-1/2)
    beta = 1 - k*((t_a - T_opt).^2);
else
    beta = zeros(1,ndaisies);
end
