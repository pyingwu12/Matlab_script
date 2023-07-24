  


 dat=squeeze(vari_ens(xpi,ypi,:));

 sig2d=std(vari_ens,1,3); 
 mea2d=mean(vari_ens,3);

 sig2dens=repmat(sig2d,1,1,pltensize); 
 mea2dens=repmat(mea2d,1,1,pltensize);
 
 
   dat_G2dens=1./(sig2dens.*(2*pi)^0.5).*exp(-(1/2)*((vari_ens-mea2dens)./sig2dens).^2);

     maxlG2d=sum(log(dat_G2dens),3);
     bicG2d=-2*maxlG2d+2*log(pltensize);
     
     
     
     maxlG2d_t=-(pltensize/2)*log(2*pi/pltensize*sum((vari_ens-mea2dens).^2,3))-(pltensize/2);
     bicG2d_t=-2*maxlG2d_t+2*log(pltensize);