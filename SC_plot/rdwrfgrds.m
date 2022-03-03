function [w]=rdwrfgrds(infile,nx,ny)
%nx=159;ny=150;
%var=zeros(nx,ny);
%fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00.dat','r','b');
fid=fopen(infile,'r','b');
%dummy=fread(fid,1,'int');
var=fread(fid,[nx,ny],'float');
for i=1:3*25
    var=fread(fid,[nx,ny],'float');
    var(find(var>=1.e10))=nan;
    if(i>=51)
       w(:,:,i-50)=var;
    end
end
fclose(fid)
return
