function [mem]=mean_member(sth,acch,expri)
% sth: start time
% acch: accumulation time
% expri: experiment name
%---


%---setting---
expdir=['/work/pwin/plot_cal/Rain/',expri];
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---set end time---    
      edh=ti+ai;               % end time
      if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
      infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
      load (infile);
      acci=wrfacci;
      [meacci PM PMmod]=calPM(acci);        
      for mi=1:40
        fin=find(isnan(acci{mi})==0 & acci{mi}>=0);
        [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1)]=score(PM(fin),acci{mi}(fin),15); 
      end %member 
      [a mem]=max(scc);
      %nen=num2str(mem);
   end
end 