clear

addpath('/work/pwin/data/taylordiagram')


sth=15;
acch=3;
expri='orig';

%---set
expdir=['/work/pwin/plot_cal/Rain/',expri];
%---
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile);     
    [xl yl]=size(obsacci);
    obsacci(isnan(obsacci) ==1 | obsacci<=0)=0; 
    obsacci=reshape(obsacci,xl*yl,1);
      for mi=1:40
        wrfacci{mi}(isnan(wrfacci{mi}) ==1 | wrfacci{mi}<=0)=0; 
        wrfacci{mi}=reshape(wrfacci{mi},xl*yl,1);
        
        [scc(mi+1,1) rmse(mi+1,1)]=score(obsacci,wrfacci{mi});
        
        rmse(mi+1,1)=RMSD(obsacci,wrfacci{mi});
        std(mi+1,1)=STNDE(wrfacci{mi});
      end %member 
  [scc(1,1) rmse(1,1)]=score(obsacci,obsacci); 
  std(1,1)=STNDE(obsacci);     
  figure('position',[500 100 600 500])
  [hp ht axl] = taylordiag(std,rmse,scc);
  end
end




