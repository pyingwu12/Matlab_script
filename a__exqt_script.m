
 thrd=[15 20 25 30 35];

%{
  pltime=45;  memsize=50; 
 wind_2D_prob_MultiT(pltime,memsize,thrd)

  memsize=100; 
 wind_2D_prob_MultiT(pltime,memsize,thrd)

  memsize=500; 
 wind_2D_prob_MultiT(pltime,memsize,thrd)


  pltime=42:47;  memsize=50; 
wind_2D_prob_MultiT(pltime,memsize,thrd)

  pltime=42:47;  memsize=100; 
wind_2D_prob_MultiT(pltime,memsize,thrd)

  pltime=42:47;  memsize=500; 
wind_2D_prob_MultiT(pltime,memsize,thrd)
%}

  pltime=45;  memsize=1000;
wind_2D_prob_MultiT(pltime,memsize,thrd)
  pltime=42:47;  
wind_2D_prob_MultiT(pltime,memsize,thrd)
