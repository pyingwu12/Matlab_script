function [mem]=best_member(sth,acch,expri)
% sth: start time
% acch: accumulation time
% expri: experiment name
%---
%clear
%sth=15; acch=1; expri='MRcycle06'; 

%---setting---
expdir=['/work/pwin/plot_cal/Rain/',expri];
min='00';
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---set end time---    
      edh=ti+ai;               % end time
      if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
      infile=[expdir,'/obs_acci_',s_sth,min,'_',s_edh,min,'.mat'];
      load (infile);     
      for mi=1:40
        fin=find(isnan(obsacci) ==0 & isnan(wrfacci{mi})==0 & wrfacci{mi}>=0 & obsacci>=0);
        [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1) ]=score(obsacci(fin),wrfacci{mi}(fin),15); 
      end %member 
      [a mem]=max(scc);
      %nen=num2str(mem);
   end
end 

