function [prob, label] = single_scale_evaluation(G, group, conversion, options)


prob = zeros(size(group,2),2);
label = zeros(size(group));

is_nested = options.is_nested;


% Configuration LeastR parameter
opts=[];
opts.init=2;
opts.rFlag=1;
opts.mFlag=0;
opts.nFlag=0;
opts.lFlag=0;
opts.tFlag=0;
opts.sWeight=[1 2];


% CN/AD -  classification 
id_cnad = find(group==0 | group==3);
xtrain = G(id_cnad,:);
ytrain = 1+(group(id_cnad)==3)';
%
ypred_cnad = zeros(size(ytrain));
v_cnad = zeros(size(ytrain,1),2);

% sMCI/pMCI - classification
id_mci = find(conversion==1 | conversion==2 | conversion==3 | conversion==4); 
ypred_mci = zeros(size(id_mci));
v_mci = zeros(size(id_mci,1),2);



cv = cvpartition(ytrain,'kfold',10);
for j=1:cv.NumTestSets
	teIdx = cv.test(j);
	trIdx = cv.training(j);
	teIdx = find(teIdx==1);

	xtrainRF = xtrain(trIdx,:);
	ytrainRF = ytrain(trIdx,:);

	if ~is_nested
		lambda = 0.05; rho=0.04; 
		opts.rsL2=rho;
		opts.mu = mean(xtrainRF,1);
		opts.nu = sqrt(sum(xtrainRF.^2,2)/size(xtrainRF,2));		
		[xcoeff,~,~] = LeastR(xtrainRF, ytrainRF, lambda, opts);
		selected =  abs(xcoeff)>0.0;
	else
		accmax = 0;

		% Nested cross-validation for parameter optimisation
		cv_nested = cvpartition(ytrainRF,'kfold',5);
		id_nested = cv_nested.test(1);
		id_valid  = cv_nested.training(1);
		for l=options.range_lambda
			for r=options.range_rho
				cvXTrain = xtrainRF(id_nested,:);
				cvYTrain = ytrainRF(id_nested);					
				opts.rsL2 = r;
				opts.mu = mean(cvXTrain,1);
				opts.nu = sqrt(sum(cvXTrain.^2,2)/size(cvXTrain,2));		
				[xcoeff,~,~] = LeastR(cvXTrain, cvYTrain, l, opts);
				selected =  abs(xcoeff)>0.0;
                
				cvXTrain = cvXTrain(:,selected); 
				cvXTest  = xtrainRF(id_valid,selected); 	
				cvYTest  = ytrainRF(id_valid);			
                                mtry = floor(sqrt(sum(selected)));
				model = classRF_train(cvXTrain, cvYTrain, options.ntree, mtry); 
				[ypredN, ~] = classRF_predict(cvXTest, model);
				
				senN 	= sum((ypredN==2).*(cvYTest==2))/...
						sum(cvYTest==2);
				speN 	= sum((ypredN==1).*(cvYTest==1))/...
						sum(cvYTest==1);	
				bacc =  (senN+speN)/2;
				
				if accmax<bacc
					accmax = bacc;
					rho = r;
					lambda = l;
				end
			end	
        end
        opts.rsL2=rho;
        opts.mu = mean(xtrainRF,1);
        opts.nu = sqrt(sum(xtrainRF.^2,2)/size(xtrainRF,2));		
        [xcoeff,~,~] = LeastR(xtrainRF, ytrainRF, lambda, opts);
        selected =  abs(xcoeff)>0.0;        
    end

	% CN/AD training	
	xtrainRF = xtrainRF(:,selected);
 	mtry = floor(sqrt(sum(selected)));
	model = classRF_train(xtrainRF, ytrainRF, options.ntree, mtry); 

	% CN/AD testing
	xtestRF = xtrain(teIdx, selected);
	[ypred_cnad(teIdx), v_cnad(teIdx,:)] = classRF_predict(xtestRF, model);

	% sMCI/pMCI testing
	xtestMCI = G(id_mci, selected);
	[ypred_mci, v_mci] = classRF_predict(xtestMCI, model);
end

p = v_cnad./repmat(sum(v_cnad,2),1,size(v_cnad,2));
prob(id_cnad,:) = p;
label(id_cnad) = ypred_cnad;

p = v_mci./repmat(sum(v_mci,2),1,size(v_mci,2));
prob(id_mci,:) = p;
label(id_mci) = ypred_mci;

end
