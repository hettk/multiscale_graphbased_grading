% Main function to build the graph of structures grading
%
% G = build_graph(gmap, mask, options):  Compute the graph of
% structure grading for the subject under study (see Hett et al.
% Medical Image analysis 2020)
% 
% Arguments: 
%   - gmap
%       input.mri : path of the mri understudy
%       input.mask: mask of the region of interest
%       input.age : age of the subject understudy at scan
%   - mask
%       templates.t1_path  : list of path of the template mri
%       templates.mask_path: list of path of the template mask
%       templates.ages     : Vector of ages of templates at scan
%   - options 
%       options.A;              % [min, max] for each structure [Nstruct,2]
%       options.C;              % Age regression coefficients   [Nstruct,3]
%       options.nbins;          % Number of bins per histogram
%       options.age;            % Age of the subject under study
%       options.label_str;      % Label for each structure      [2, Nstruct]
%
% Return:
%   - G: Graph of grading structures
%       G.MS -> Mean of grading values within each structures (vertices)
%       G.D  -> Distance of grading distributions between each pair of
%               structures (Edges)
%
%
% Author: Kilian Hett, kilianhett@vanderbilt.edu 
%         (Vanderbilt University, University of Bordeaux) 


function G = build_graph(gmap, mask, options)

A       = options.A;         
C       = options.C;          
nbins   = options.nbins;     
age     = options.age;         

r_str   = options.label_str(1,:);
l_str   = options.label_str(2,:);
N       = size(2,label_str);


MS  = zeros(N*2,1);
B   = cell(2*N,1);
for j=1:N
    r_label = r_str(j);
    l_label = l_str(j);

    ids_right   = find(mask==r_label);
    ids_left    = find(mask==l_label);

    B{(j-1)*2 + 1}  = gmap(ids_right);     
    B{(j-1)*2 + 2}  = gmap(ids_left);            

    MS((j-1)*2 + 1) = mean(gmap(ids_right)); 
    MS((j-1)*2 + 2) = mean(gmap(ids_left));  
end


% Correction of bias related to age
for j=1:size(MS,2)
    if C(j,3)<0.05
        MS(:,j) = MS(:,j) - (age*C(j,2)+C(j,1))';
        B{j}    = B{j} - (age*C(j,2)+C(j,1));
    end
end

% Data normalisation and Histogram computation
H = zeros(length(B), nbins);
for j=1:size(C,1)
    L = A{j};    
    B{j} = (B{j} - L(1))/(L(2) - L(1));

    p = hist([B{j};0;1], nbins);
    p = p/sum(p(:));
    H(j,:) = p;
end
H(isnan(H)) = 0;
MS(isnan(MS)) = 0;

Hl = zeros(length(H), nbins);
for j=1:2:N*2
    Hl(ceil(j/2),:) = (H(j,:) + H(j+1,:))/2.;
end
	
% Wasserstein distance computation
X    = 0:nbins-1;
Cost = toeplitz(X.^2);
D    = [];
for i=1:N-1
    for j=i+1:N
        if j~=i
            h1 = reshape(Hl(i,:),nbins,1);
            h2 = reshape(Hl(j,:),nbins,1);
            if max(h1)>min(h1) & max(h2)>min(h2)
                [d,~]   = mexEMD(h1,h2,Cost);
            elseif max(h1)==min(h1)
                h1      = ones(size(h1));
                h1      = h1./sum(h1);
                [d,~]   = mexEMD(h1,h2,Cost);
            elseif max(h2)==min(h2)
                h2      = ones(size(h2));
                h2      = h2./sum(h2);
                [d,~]   = mexEMD(h1,h2,Cost);
            end 
            D = [D d];
        end
    end
end
G.MS = MS;
G.D  = exp(-D/std(D(:)));

end
