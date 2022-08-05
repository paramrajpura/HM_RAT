%% HexMaze node selection%tabula rasa
clc
clear all
close all%
% construct the graph
time2wait=20;
G=graph(); %initialize the graph
island=['ijhe']; %name the islands
nodes={}; %initialize the nodes
for m=1:4 %for each island
    for i=1:24 %for each node
        if i<=9
            nodes(end+1)={strcat(island(m),'0',num2str(i))};
        else
            nodes(end+1)={strcat(island(m),num2str(i))};
        end
    end
end
%nodes is now a 96-long vector containing the name of all the nodes,
%referred as a letter-number combination
G = addnode(G,nodes); %add the nodes to the graph
nds=nodes;%add the within-isnand edges to the graph
for k=1:4
    G=addedge(G,[nds(1) nds(1)],[nds(2) nds(7)]);
    G=addedge(G,[nds(2)],[nds(3)]);
    G=addedge(G,[nds(3) nds(3)],[nds(4) nds(9)]);
    G=addedge(G,[nds(4)],[nds(5)]);
    G=addedge(G,[nds(5)],[nds(11)]);
    G=addedge(G,[nds(6) nds(6)],[nds(7) nds(13)]);
    G=addedge(G,[nds(7)],[nds(8)]);
    G=addedge(G,[nds(8) nds(8)],[nds(9) nds(15)]);
    G=addedge(G,[nds(9)],[nds(10)]);
    G=addedge(G,[nds(10) nds(10)],[nds(11) nds(17)]);
    G=addedge(G,[nds(11)],[nds(12)]);
    G=addedge(G,[nds(12)],[nds(19)]);
    G=addedge(G,[nds(13)],[nds(14)]);
    G=addedge(G,[nds(14) nds(14)],[nds(15) nds(20)]);
    G=addedge(G,[nds(15)],[nds(16)]);
    G=addedge(G,[nds(16) nds(16)],[nds(17) nds(22)]);
    G=addedge(G,[nds(17)],[nds(18)]);
    G=addedge(G,[nds(18) nds(18)],[nds(19) nds(24)]);
    G=addedge(G,[nds(20)],[nds(21)]);
    G=addedge(G,[nds(21)],[nds(22)]);
    G=addedge(G,[nds(22)],[nds(23)]);
    G=addedge(G,[nds(23)],[nds(24)]);
    nds=nds(25:end);
end% add the between-islands edges to the graph
G=addedge(G,[nodes(21)],[nodes(2+24*2)]);
G=addedge(G,[nodes(24)],[nodes(1+24*1)]);
G=addedge(G,[nodes(20+24*1)],[nodes(5+24*2)]);
G=addedge(G,[nodes(23+24*1)],[nodes(4+24*3)]);
G=addedge(G,[nodes(24+24*2)],[nodes(1+24*3)]);
P=plot(G);% make it look good
set(gca,'Color',[143,188,143]/256)
sgtitle('Node selection')
a=7;
b=6;
c=3;
d=2;
e=-2;
f=-3;
g=-6;
h=-7;i=-6;
j=-4;
k=-2;
m=0;
n=2;
o=4;
p=6;
y_es=[b a b a b d c d c d c d e f e f e f e g h g h g];
x_es=[j k m n o i j k m n o p i j k m n o p j k m n o];
P.XData=[x_es-6 x_es+6 x_es-6 x_es+6];
P.YData=[y_es+25 y_es+8 y_es-8 y_es-25];% add additional information to the graph
unreach=nodes([[13,14,15,20]+24,[5 10 11 12]+24*2]); %nodes that cannot be used because unreachable
prompt = {'Please insert the Goal Location. Format yxx, where y is the island and x is the node number'};
dlgtitle = 'Input';
dims = [1 50];
definput = {''};
gl_cod = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
% gl_cod=314;
temp=num2str(gl_cod);
gl={strcat(island(str2num(temp(1))),temp(2:end))};
gl_island=nodes(strmatch(gl{1}(1),nodes)); %nodes in the same island of the goal location
gl_neig=neighbors(G,gl)';
prompt = {'Please insert the 20 nodes from the previous study day. Both used and non-used nodes should be inserted. Format yxx, where y is the island and x is the node number'};
dlgtitle = 'Input';
dims = [1 50];
definput = {''};
nd = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
% nd=[403
% 223
% 122
% 412
% 219
% 104
% 413
% 106
% 221
% 120
% 418
% 111
% 205
% 405
% 102
% 407
% 117
% 208
% 421
% 217];
prev={};
for i=1:length(nd)
    temp=num2str(nd(i));
    prev(end+1)={strcat(island(str2num(temp(1))),temp(2:end))};
end
prompt = {'Please insert the number of trials the animal did during that session. Integers from 0 to 20 are accepted'};
dlgtitle = 'Input';
dims = [1 15];
definput = {''};
n_trials = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
old=prev(1:n_trials); %nodes used in the old session
previous=prev(n_trials+1:end);%nodes previously used in the same session
adjacent={}; %nodes adjacent to the previousl nodes of the same session
for i=1:length(previous)
    temp=neighbors(G,previous(i));
    for j=1:length(temp)
        adjacent(end+1)=temp(j);
    end
end% labelnode(P,unreach,'X')
% labelnode(P,old,'X')
% labelnode(P,previous,'X')
% labelnode(P,adjacent,'X')
% labelnode(P,gl,'X')
% labelnode(P,gl_island,'X')
% labelnode(P,gl_neig,'X')
nope=unique([gl,gl_island,gl_neig,adjacent,old,previous,unreach]);
%% select the islands of the new nodes
unsatisfied=true;
while unsatisfied
    highlight(P,nodes,'Marker','o','NodeColor',[0 0.4470 0.7410],'MarkerSize',4)
    highlight(P,old,'Marker','o','NodeColor','r','MarkerSize',5)
    highlight(P,previous,'Marker','o','NodeColor','k','MarkerSize',5)
    highlight(P,adjacent,'Marker','o','NodeColor',[0.5 0.5 0.5],'MarkerSize',5)
    highlight(P,gl_island,'Marker','o','NodeColor',[0.6350 0.0780 0.1840],'MarkerSize',5)
    highlight(P,gl,'Marker','p','NodeColor','m','MarkerSize',10)
    highlight(P,unreach,'Marker','x','NodeColor','r','MarkerSize',8)
    t=true;
    tic
    %start by determining the number of nodes that have to be selected.
    num_nodes=20-length(previous); %number of nodes to generate
    isl_avail=island(island~=gl{1}(1)); %islands that are available (i.e. except the gl)
    %find out how many nodes per island have to be generated
    isl2sel='iiiiiiijjjjjjjhhhhhhheeeeeee';
    isl2sel=isl2sel(isl2sel~=gl{1}(1));
    for i=1:length(previous)
        det=findstr(isl2sel,previous{i}(1));
        isl2sel(det(1))='';
    end
    isltosel=isl2sel;
    isl_prev=old{end}(1); %previous node. For the first node generated it is the last of the previous session
    isl_tempt=''; %initialize the variable that will contain the islands
    found=false; %loop until find a suitable pseudorandom sequence of islands
    a=true;
    while ~found
        while a==true
            try
                isl_prev=old{end}(1);
                isl_tempt='';
                found=true; %if it does not get to false by the end of the script, stop
                a=true;
                isl2sel=isltosel;
                for i=1:num_nodes                
                    isl_avail2=intersect(isl_avail(isl_avail~=isl_prev),isl2sel);
                    isl_tempt(i)=isl_avail2(randi([1 length(isl_avail2)]));
                    if i==2
                        isl_tempt(i)=isl_avail(isl_avail~=old{end}(1) & isl_avail~=isl_tempt(i-1));
                    end
                    if length(isl_tempt)>=6
                        for jj=1:length(isl_tempt)-5
                            if isl_tempt(jj:jj+1)==isl_tempt(jj+2:jj+3) & isl_tempt(jj+2:jj+3)==isl_tempt(jj+4:jj+5)
                                isl_tempt(i)=isl_avail(isl_avail~=isl_tempt(jj) & isl_avail~=isl_tempt(jj+1));
                            end
                        end
                    end
                    isl_prev=isl_tempt(end);
                    tem=findstr(isl2sel,isl_prev);
                    isl2sel(tem(1))='';
                end
                a=false;
            catch
                a=true;
            end
        end
        % evaluate now the tentative list of islands. If any of the
        % requirements is not met the code will re-generate one    %make sure that all the islands are selected at least once
        if num_nodes>=3
            if length(unique(isl_tempt))<=2
                found=false;
            end
        end
        %for some reason the first 2 islands are sometimes the same
        if length(isl_tempt)>=2
            if isl_tempt(1)==isl_tempt(2)
                found=false;
            end
        end
        %make sure that dupletes are not repeated more than 2 times
        if num_nodes>=6
            for jj=1:num_nodes-5
                if isl_tempt(jj:jj+1)==isl_tempt(jj+2:jj+3) & isl_tempt(jj+2:jj+3)==isl_tempt(jj+4:jj+5)
                    found=false;
                end
            end
        end
        %make sure that tripletes are not repeated more than 2 times
        if num_nodes>=9
            for jj=1:num_nodes-8
                if isl_tempt(jj:jj+2)==isl_tempt(jj+3:jj+5) & isl_tempt(jj+3:jj+5)==isl_tempt(jj+6:jj+8)
                    found=false;
                end
            end
        end
    end
    isl=isl_tempt;
    %% select the nodes inside the islands
    nodes_def=cell(1,length(isl));
    nodes2sel=setdiff(nodes,nope); % nodes eligible to be selected
    nodes_tempt={};
    %nodes_def={};
    for i=1:length(unique(isl)) %loop thru islands
        temp=unique(isl);
        isl_oi=temp(i); %select the island to generate the nodes
        nodes_isl='';
        for ii=1:length(nodes2sel)
            if ~isempty(nodes2sel(nodes2sel{ii}(1)==isl_oi))
                nodes_isl{end+1}=nodes2sel{ii};
            end
        end
%         for g=1:length(nodes_tempt)
%             if size(intersect(nodes_isl,neighbors(G,nodes_tempt{g})))>=1
%                 nodes_iss=setdiff(nodes_isl,neighbors(G,nodes_tempt{g}));
%             end
%         end
        while true
            try
                nodes_tempt={};
                nodes_iss=nodes_isl;
                for j=1:sum(isl==isl_oi) %each loop generates one node
                    nodes_tempt(end+1)=nodes_iss(randi([1 length(nodes_iss)]));
                    remove=neighbors(G,nodes_tempt{end});
                    nodes_iss(ismember(nodes_iss,nodes_tempt{end}))='';
                    nodes_iss(ismember(nodes_iss,remove))='';
                    
                    
                    if length(intersect(neighbors(G,nodes_tempt{end}),nodes_def(find(~cellfun(@isempty,nodes_def)))))>=1
                        continue
                    end
                end
                break
            catch
                continue
            end
        end
        nodes_def(isl==nodes_tempt{1}(1))=nodes_tempt(randperm(numel(nodes_tempt)));
    
    end
    nodes_def_code=[];
    for i=1:length(nodes_def)
        nodes_def_code=[nodes_def_code,str2num(strcat(num2str(findstr(island,nodes_def{i}(1))),nodes_def{i}(2:end)))];
    end
    nodes_def_code
    highlight(P,nodes_def,'Marker','o','NodeColor','g','MarkerSize',8)
    toc
    prompt = {'Satisfied of the selected nodes? 1 = yes ; 0 = no'};
    dlgtitle = 'Input';
    dims = [1 50];
    definput = {'0'};
    sat = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
    if sat==0
        unsatisfied=true;
    else
        unsatisfied=false;
    end
end

for i=1:length(nodes_def_code)
    isl_code(i)=find(isl(i)==island);
end
clear results
results(:,1)=array2table(isl')
results(:,2)=array2table(string(nodes_def'))
results(:,3)=array2table(isl_code')
results(:,4)=table(nodes_def_code')




