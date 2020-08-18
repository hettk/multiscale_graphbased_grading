

function [prob,label] = multi_scale_evaluation(G, group, conversion, options)

% CN vs. AD (Imaging-based biomarker)
idtrain = find(group==0 | group==3);
xtrain = G(idtrain,:);
ytrain = 1+(group(idtrain)==3)';

cv = cvpartition(ytrain, 'leaveout');
ypred = zeros(size(ytrain));
v = zeros(size(ytrain,1),2);

for j=1:cv.NumTestSets
    teIdx = cv.test(j);
    trIdx = cv.training(j);
    teIdx = find(teIdx==1);
    
    xtrainRF = xtrain(trIdx,:);
    ytrainRF = ytrain(trIdx,:);
    
    xtestRF = xtrain(teIdx,:);    
    model = fitcdiscr(xtrainRF, ytrainRF);
    [ypred(teIdx), v(teIdx,:)] = model.predict(xtestRF);
end
prob(idtrain,:) = v;
label(idtrain) = ypred;
	

% sMCI vs. pMCI 
idtest = find(conversion==1 | conversion==2 | conversion==3 | conversion==4);  

xtest = G(idtest,:);
model = fitcdiscr(xtrain, ytrain,'discrimType', 'pseudolinear'); 
[ypred, p] = model.predict(xtest);

prob(idtest,:) = p;
label(idtest) = ypred;
	

end	
