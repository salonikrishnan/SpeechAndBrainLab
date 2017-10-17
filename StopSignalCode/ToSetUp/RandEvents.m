rand_isi=exprnd(ones(1,64*3));
while sum(rand_isi) > 200 || sum(rand_isi)< 184 || max(rand_isi)> 4 || min(rand_isi)<0.5
   rand_isi=exprnd(ones(1,64*3));
end;
save(null_events, rand_isi);

