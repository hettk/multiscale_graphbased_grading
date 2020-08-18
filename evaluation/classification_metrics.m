%
%
%
% Author: Kilian Hett (kilian.hett@vanderbilt.edu)


function [auc, acc, sen, spe, bac] = classification_metrics(p, lab, group, idx, lab_true, fun_equal)

	ytrain  = 1+fun_equal(group(idx),lab_true);
	ypred 	= lab(idx);
	p       = p(idx,:);

	auc = scoreAUC(ytrain'==1, p(:,1));
	acc = mean(ypred==ytrain);
	sen = sum((ypred==2).*(ytrain==2))/sum(ytrain==2);
	spe = sum((ypred==1).*(ytrain==1))/sum(ytrain==1);	
	bac = (spe+sen)/2.;
end
