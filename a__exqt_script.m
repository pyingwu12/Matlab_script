

% pltensize=1000; 
% expri='Hagibis05kme02';
% gaussian_level(expri,pltensize,'v10m')
% gaussian_level(expri,pltensize,'u10m')
% disp('e02 1000 done')
% expri='Hagibis05kme01';
% gaussian_level(expri,pltensize,'v10m')
% gaussian_level(expri,pltensize,'u10m')
% disp('e01 1000 done')

% pltensize=50; 
% expri='Hagibis05kme01';
% gaussian_level(expri,pltensize,'v10m')
% gaussian_level(expri,pltensize,'u10m')
% expri='Hagibis05kme02';
% gaussian_level(expri,pltensize,'v10m')
% gaussian_level(expri,pltensize,'u10m')

expri='Hagibis05kme01';
bc_rank_Ts(expri,[1 5 10],[1 5 10],850)
clear all
expri='Hagibis05kme02';
bc_rank_Ts(expri,[1 5 10],[1 5 10],850)
clear all

% clear all
% expri='Nagasaki05km';
% bc_rank_Ts(expri,[1 3 5 10],[1 5 10],1000)
% bc_rank_Ts(expri,[1 3 5 10],[1 5 10],500)