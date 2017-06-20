rand_isi=exprnd(ones(1,64)*2);
while sum(rand_isi) > 136 || sum(rand_isi)< 120 || max(rand_isi)> 5 || min(rand_isi)<0.5
   rand_isi=exprnd(ones(1,64)*2);
end;
save(null_events, rand_isi);
