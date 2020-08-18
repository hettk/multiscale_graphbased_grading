function [g] = select_group_list(meta, group, info, conv)

g=1;
j_meta = -1;
if strcmp(info,'id')
	j_meta = 1;
elseif strcmp(info,'age')
	j_meta = 3;
elseif strcmp(info,'group')
	j_meta=5;
elseif strcmp(info,'conversion')
	j_meta=6;	
elseif strcmp(info,'sex')
	j_meta=4;
elseif strcmp(info,'TC1')
	j_meta=7;
elseif strcmp(info,'TC2')
	j_meta=8;
elseif strcmp(info,'TC3')
	j_meta=9;
elseif strcmp(info,'TC4')
	j_meta=10;
elseif strcmp(info,'TC5')
	j_meta=11;
elseif strcmp(info,'TC6')
	j_meta=12;
end


if j_meta==-1
	disp('Error');
	return;
end

if j_meta==3 || j_meta==5 || j_meta==6 || j_meta==4
	g=zeros(size(meta,1),1);
elseif j_meta==1
	g={};
end

for i=1:size(meta{1},1)
	if j_meta==3 || j_meta==4 || j_meta==6 || j_meta>=8 
		if strcmp(group, meta{5}{i})
			g(i) = str2double(meta{j_meta}{i});
		elseif strcmp(group, 'ALL')
			g(i) = str2double(meta{j_meta}{i});
		end
	elseif j_meta==7
		if strcmp(group, meta{5}{i})
			g(i) = meta{j_meta}(i);
		elseif strcmp(group,'ALL')
			g(i) = meta{j_meta}(i);
		end
	elseif j_meta==1 
		if strcmp(group, meta{5}{i})
			g{i} = meta{j_meta}{i};
		elseif strcmp(group,'ALL')
			g{i} = meta{j_meta}{i};
		end
	elseif j_meta==5
		gr = meta{j_meta}{i};
		if strcmp(gr,'CN')
			id_gr = 0;
		elseif strcmp(gr,'EMCI')
			id_gr= 1;
		elseif strcmp(gr,'LMCI')
			id_gr= 2;
		elseif strcmp(gr,'MCI')
			id_gr=12;
		elseif strcmp(gr, 'AD')
			id_gr= 3;
		end

		if strcmp(group, meta{5}{i})
			g(i) = id_gr;
		elseif strcmp(group,'ALL')
			g(i) = id_gr;
		end
end

end
