function [sprd_s, sprd_d]=bc_cal_FilterSprd(expri,infilename,idifx,iset,variname,acch,pltime,nrmid,fLb,fLu,dx,dy)

% iset=11;
% expri='Nagasaki02km'; infilename='202108131300'; idifx=44;  nrmid=1;
% % variname='rain';  acch=1; pltime=1+acch:25+acch; 
% variname='tpw';  acch=0; pltime=1:24; 


indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];

expsize=1000; BCnum=50; ensize=expsize/BCnum;

member_s=iset:BCnum:expsize; 
member_d=(iset-1)*ensize+1:iset*ensize;
for imem=1:ensize 
  infile_s=[indir,'/',num2str(member_s(imem),'%.4d'),'/s',infilename,'.nc'];   
  infile_d=[indir,'/',num2str(member_d(imem),'%.4d'),'/s',infilename,'.nc']; 
  
  if imem==1
    lon = double(ncread(infile_s,'lon'));    %lat = double(ncread(infile_s,'lat'));
    data_time = (ncread(infile_s,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0_s=zeros(nx,ny,ensize,ntime); vari0_d=zeros(nx,ny,ensize,ntime);
  end
  tmp=ncread(infile_s,variname);  
  vari0_s(:,:,imem,:) = low_pass_filter(tmp,fLb,fLu,dx,dy);
  tmp=ncread(infile_d,variname);    
  vari0_d(:,:,imem,:) = low_pass_filter(tmp,fLb,fLu,dx,dy);
end

if strcmp(variname,'rain')==1
    vari0_s(vari0_s<=0)=0; vari0_s(vari0_s<=0)=0;
  vari1_s=vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime)-...
          vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime-acch);
  vari1_d=vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime)-...
          vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime-acch);
else
  vari1_s=vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime);
  vari1_d=vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,:,pltime);
end
      
[nx1, ny1, ~, ~]=size(vari1_s);
if nrmid==0    
  var_s= var(vari1_s,0,3);    sprd_s = (sum( var_s,[1 2]) /nx1/ny1).^0.5 ;
  var_d= var(vari1_d,0,3);    sprd_d = (sum( var_d,[1 2]) /nx1/ny1).^0.5 ; 
else
  var_s= var(vari1_s,0,3);    sprd_s = (sum( var_s,[1 2]) /nx1/ny1).^0.5 ./ mean(vari1_s(:)) ;
  var_d= var(vari1_d,0,3);    sprd_d = (sum( var_d,[1 2]) /nx1/ny1).^0.5 ./ mean(vari1_d(:)) ;
end

sprd_s=squeeze(sprd_s);
sprd_d=squeeze(sprd_d);

% end