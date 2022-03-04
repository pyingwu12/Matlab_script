  function [T]=wrf_tk(pressure,th,unit)
% input: pressure (Pa) and potential temperature (K) 
% output: temperature (K)
  dim=size(pressure);
  T=zeros(dim);

  const=287.0/1004.0;
  P0=1.0e5;

  if(length(dim)==4)
    for i=1:dim(1)
        for j=1:dim(2)
        pi=(pressure(i,j,:,:)/P0).^const;
        T(i,j,:,:)=pi.*th(i,j,:,:); 
        end
    end
  elseif(length(dim)==3) 
    for j=1:dim(1)
        pi=(pressure(j,:,:)/P0).^const;
        T(j,:,:)=pi.*th(j,:,:); 
    end
  else
     pi=(pressure(:,:)/P0).^const;
     T(:,:)=pi.*th; 
  end

  if ( unit=='C')
      T=T-273.16;
  end
  return 
