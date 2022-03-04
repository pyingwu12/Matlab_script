function [AC bias POD FAR POFD TS ETS KSS]=accum_score2(sth,acch,expri,tresh)
% sth: start time
% acch: accumulation time
% expri: experiment name
% target: 'mean' or 'member'
%sth=17; acch=3; expri='MRcycle06';  tresh=160;
%---set
expdir=['/work/pwin/plot_cal/Rain/',expri];
%---
nt=0;
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile);       

      nt=nt+1;
      [wrfaccim{1} wrfaccim{2} wrfaccim{3}]=calPM(wrfacci);
      for mi=1:3
        fin=find(isnan(obsacci) ==0 & isnan(wrfaccim{mi})==0 & wrfaccim{mi}>=0 & obsacci>=0);
        
        [AC(nt,mi) bias(nt,mi) POD(nt,mi) FAR(nt,mi) POFD(nt,mi) TS(nt,mi) ETS(nt,mi) KSS(nt,mi)]= ...
                                             score2(obsacci(fin),wrfaccim{mi}(fin),tresh);
      end

  end
end

