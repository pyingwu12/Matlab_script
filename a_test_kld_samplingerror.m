clear


ensz=50:50:2000;
nsz=length(ensz);  
nsmp=1;

nboots=1000;

kld=zeros(nboots,nsz);
for szi=1:nsz
  for bi=1:nboots
    %--ens data
%     tmp=(rand(ensz(szi),nsmp)-0.5)*5; %flat
    tmp=normrnd(0,1,ensz(szi),nsmp);
    dat=mean(sort(tmp,1),2);
    %--hist of data
    [bin_num, intv, x, bic]=opt_binum(dat);
    [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);  
    q(q==0)=1e-16;
    q=q/ensz(szi)/intv;
    %--normal distribution
    sig=std(dat);  ens_me=mean(dat);
    gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
    %---kld
    kld(bi,szi)=sum(gaus.*log(gaus./q));
  end
end
%%
hf=figure('Position',[100 100 1000 550]);

plot(ensz,mean(kld,1),'linewidth',2)
hold on

plot(ensz,median(kld,1),'.','color',[0.85,0.325,0.098],'Markersize',15)


for i=1:nsz
line([ensz(i) ensz(i)],[median(kld(:,i))-iqr(kld(:,i))/2 median(kld(:,i))+iqr(kld(:,i))/2   ],...
    'color',[0.5 0.5 0.5],'linewidth',2,'linestyle',':')
end

legend('Mean','Median','IQR','fontsize',20,'box','off')

title(['Bootstrapping ',num2str(nboots),' times'])

xlabel('size')
ylabel('KLD')

set(gca,'fontsize',16,'linewidth',1,'ylim',[-0.01 0.25],'xlim',[1 ensz(end)])

% outdir='/home/wu_py/labwind/Result_fig';
% outfile=[outdir,'/kld_samplingerror_test'];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);