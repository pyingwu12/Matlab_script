function [sprd_s, sprd_d]=bc_cal_sprd(expri,infilename,idifx,iset,variname,acch,pltime,nrmid)

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
    vari0_s=zeros(nx,ny,ntime,ensize); vari0_d=zeros(nx,ny,ntime,ensize);
  end
  vari0_s(:,:,:,imem) = ncread(infile_s,variname);
  vari0_d(:,:,:,imem) = ncread(infile_d,variname);  
end

if strcmp(variname,'rain')==1
    vari0_s(vari0_s<=0)=0; vari0_s(vari0_s<=0)=0;
  vari1_s=vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:)-...
          vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,pltime-acch,:);
  vari1_d=vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:)-...
          vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,pltime-acch,:);
else
  vari1_s=vari0_s(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:);
  vari1_d=vari0_d(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:);
end
      
[nx1, ny1, ~, ~]=size(vari1_s);
if nrmid==0    
  var_s= var(vari1_s,0,4);    sprd_s = (sum( var_s,[1 2]) /nx1/ny1).^0.5 ;
  var_d= var(vari1_d,0,4);    sprd_d = (sum( var_d,[1 2]) /nx1/ny1).^0.5 ; 
else
  var_s= var(vari1_s,0,4);    sprd_s = (sum( var_s,[1 2]) /nx1/ny1).^0.5 ./ mean(vari1_s,[1 2 4]) ;
  var_d= var(vari1_d,0,4);    sprd_d = (sum( var_d,[1 2]) /nx1/ny1).^0.5 ./ mean(vari1_d,[1 2 4]) ;
end

sprd_s=squeeze(sprd_s);
sprd_d=squeeze(sprd_d);

% end