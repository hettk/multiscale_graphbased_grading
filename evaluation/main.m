clear all;

% Includes libraries
addpath(genpath('lib/SLEP'));
addpath(genpath('lib/randomforest-matlab'));


% Load demographics
expr = '%s%s%s%s%s%s%f%s%s%s%s%s';
listfile = sprintf('data/list_standarlized_hips');

fid = fopen(sprintf('%s.txt',listfile));
listmeta = textscan(fid, expr, 'Delimiter', ' ');
fclose(fid);

ids 	   = select_group_list(listmeta, 'ALL', 'id');
ages	   = select_group_list(listmeta, 'ALL', 'age');
sex 	   = select_group_list(listmeta, 'ALL', 'sex');
group 	   = select_group_list(listmeta, 'ALL', 'group');
conversion = select_group_list(listmeta, 'ALL', 'conversion');

%
options = [];
options.is_nested     = true;
options.num_iter      = 10;
options.ntree 	      = 500;
options.range_lambda  = 0.01:0.01:0.1;
options.range_rho     = 0.01:0.01:0.1;


% Loading graph-based grading features
load('data/GBSG_ADNI1_volbrain');
G_brain = G;
load('data/GHSG_ADNI1_hips');
G_hipp = G;


m_cnad = zeros(3,5,options.num_iter);
m_mci  = zeros(3,5,options.num_iter);
for i=1:options.num_iter

    % Single-scale classification
    % Graph of brain structures
    [p_gbsg, lab_gbsg] = single_scale_evaluation(G_brain, group, conversion, options);
    id_adcn = find(group==0|group==3);
    [m_cnad(1,1,i), m_cnad(1,2,i), m_cnad(1,3,i), m_cnad(1,4,i), m_cnad(1,5,i)]...
    	 = classification_metrics(p_gbsg, lab_gbsg, group, id_adcn, 3, @eq);
    id_mci = find(conversion==1|conversion==2|conversion==3|conversion==4);
    [m_mci(1,1,i), m_mci(1,2,i), m_mci(1,3,i), m_mci(1,4,i), m_mci(1,5,i)]...
    	 = classification_metrics(p_gbsg, lab_gbsg, conversion, id_mci, 4, @ne);
    
    % Graph of hippocampal subfields
    [p_ghsg, lab_ghsg] = single_scale_evaluation(G_hipp, group, conversion, options);
    id_adcn = find(group==0|group==3);
    [m_cnad(2,1,i), m_cnad(2,2,i), m_cnad(2,3,i), m_cnad(2,4,i), m_cnad(2,5,i)]...
    	 = classification_metrics(p_ghsg, lab_ghsg, group, id_adcn, 3, @eq);
    id_mci = find(conversion==1|conversion==2|conversion==3|conversion==4);
    [m_mci(2,1,i), m_mci(2,2,i), m_mci(2,3,i), m_mci(2,4,i), m_mci(2,5,i)]...
    	 = classification_metrics(p_ghsg, lab_ghsg, conversion, id_mci, 4, @ne);
	
     
    % Multi-scale classification
    MGG = [p_gbsg(:,1) p_ghsg(:,1)];
    [p_mgg, lab_mgg] = multi_scale_evaluation(MGG, group, conversion, options);
    id_adcn = find(group==0|group==3);
    [m_cnad(3,1,i), m_cnad(3,2,i), m_cnad(3,3,i), m_cnad(3,4,i), m_cnad(3,5,i)]...
    	 = classification_metrics(p_mgg, lab_mgg, group, id_adcn, 3, @eq);
    id_mci = find(conversion==1|conversion==2|conversion==3|conversion==4);
    [m_mci(3,1,i), m_mci(3,2,i), m_mci(3,3,i), m_mci(3,4,i), m_mci(3,5,i)]...
    	 = classification_metrics(p_mgg, lab_mgg, conversion, id_mci, 4, @ne);
end


% Display results
fprintf('Diagnosis evaluation (CN vs. AD) \n');
print_performances({'GBSG', 'GHSG', 'MGG'}, m_cnad);

fprintf('Prediction evaluation (sMCI vs. pMCI) \n');
print_performances({'GBSG', 'GHSG', 'MGG', 'MGG + Cog'}, m_mci);










