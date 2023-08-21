
bc_sig=5;
ic_sig=0.1;

tmp=normrnd(0,bc_sig,50,10);

ICP=mean(sort(tmp,1),2);

for i=1:50
   
    tmp=normrnd(ICP(i),ic_sig,20,5);
    
    mem1((i-1)*20+1:i*20) =  mean(sort(tmp,1),2);
    
    
end

tmp=normrnd(0,bc_sig,1000,5);
mem2=mean(sort(tmp,1),2);

figure; histogram(mem1,11)

% figure; histogram(mem2)

%%

bc_sig=10;
ic_sig=0.1;

tmp=normrnd(0,ic_sig,20,10);
ICP=mean(sort(tmp,1),2);

for i=1:20
   
    tmp=normrnd(ICP(i),bc_sig,50,5);
    
    mem1((i-1)*50+1:i*50) =  mean(sort(tmp,1),2);
    
    
end

tmp=normrnd(0,bc_sig,1000,5);
mem2=mean(sort(tmp,1),2);

figure; histogram(mem1,11)

% figure; histogram(mem2)