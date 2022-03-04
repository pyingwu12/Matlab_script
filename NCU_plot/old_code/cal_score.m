


sth=16; acch=1; min='00';
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=['obs_acci_',s_sth,min,'_',s_edh,min,'.mat'];
    load (infile);       
      for mi=1:40
        fin=find(isnan(obsacci) ==0 & isnan(wrfacci{mi})==0 & wrfacci{mi}>=0 & obsacci>=0);
        [scc(mi,1) rmse(mi,1)]=score(obsacci(fin),wrfacci{mi}(fin)); 
      end %member 
    %save([expdir,'/score/score_',s_sth,s_edh,'.mat'],'scc','rmse')
  end
end
[scc(:,2) scc(:,3)]=sort(scc(:,1));
[a b]=max(scc(:,1))