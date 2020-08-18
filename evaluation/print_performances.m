

function print_performances(group, measures)


	for i=1:length(group)
		fprintf('%s : auc = %.4f (%.4f), acc = %.4f (%.4f), bacc = %.4f (%.4f), sen = %.4f (%.4f), spe = %.4f (%.4f) \n', group{i},...
			mean(measures(i,1,:)), std(measures(i,1,:)),...
			mean(measures(i,2,:)), std(measures(i,2,:)),...
			mean(measures(i,5,:)), std(measures(i,5,:)),...
			mean(measures(i,3,:)), std(measures(i,3,:)),...
			mean(measures(i,4,:)), std(measures(i,4,:)));
% 		if (i>1 && size(measures,3)>1)
% 			dataset = [ones(size(measures,3),1) measures(i-1,2,:);...
% 				  (ones(size(measures,3),1)*2) measures(i,2,:)];
% 			[p, ~] = perm_multi_fisher(dataset);
% 			fprintf('[p = %.5f]\n\n', p);
% 		end
	end

end


