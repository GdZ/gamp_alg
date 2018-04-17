 classdef MotherNode < handle

    properties
       id             % id of the object
       linklist       % linklist, 1xn cell array
       link_id        % link_id, 1xn array
       inbound_msg    % inbound message, nx1 cell array
       from_node      % from node, 1xn cell array
       from_id        % from id, 1xn array
       outbound_msg   % outbound message nx1 cell array
       to_node        % to node, nx1 cell array
       to_id          % to id, 1xn array             
    end
    
    methods
        function FN = MotherNode(id) % constructor  �ṹ��  
           % constructor
           FN.id = id; 
           FN.linklist = {};
           FN.inbound_msg = {};
           FN.outbound_msg = {};
           FN.from_node = {};
           FN.to_node = {};
           FN.from_id = [];
           FN.to_id = [];
        end
        
        function reset(FN)
            % reset properties
            FN.inbound_msg = {};
            FN.outbound_msg = {};
            FN.from_node = {};
            FN.to_node = {};
            FN.from_id = [];
            FN.to_id = [];
        end
        
        function setup_link(FN,linklist)
            % update linklist
            FN.linklist = linklist;
            FN.link_id = [];
            for i = 1:size(linklist,2)
                FN.link_id = [FN.link_id linklist{i}.id]; % linklist ����������ͬһ��FN�й�ϵ��VN�б�
            end
            FN.inbound_msg = {}; % FN ������Ϣ
            for i = 1:size(FN.linklist,2)
                FN.inbound_msg{i,1} = [];
                FN.outbound_msg{i,1} = [];
            end
            FN.to_node = FN.linklist;
            FN.from_node = FN.linklist;
            FN.to_id = FN.link_id;
            FN.from_id = FN.link_id;            
        end
        

        function update_node(FN, default_msg)
            for i = 1:size(FN.linklist,2)
                % i is the destination of message
                % collect all message except from i
                in_msg = {}; fm_id = [];
                for j = 1:size(FN.linklist,2)
                    if (i == j)
                        continue;
                    end
                    in_msg{size(in_msg,1)+1,1} = FN.inbound_msg{j}; % ���µ�msg����
                    %FN ���յ�������Ϣ ��ѡ��ڶ�������VN1
                    fm_id = [fm_id; FN.link_id(j)];
                    % for 2x2 MIMO ��һ��ѭ������ڶ���VN������һ��VN����Ϣ
                end % for j = ...
                % execute factor function
                snd_msg = FN.factor_fun(in_msg, fm_id, FN.link_id(i),default_msg);
                %���㷴����VN��msg VN��˳��
                % send message
                FN.linklist{i}.rx_msg(FN, snd_msg); %��FN ���͵���Ϣ���� VN ��rx_msg
                % update outbound record ����
                k = find(FN.to_id == FN.from_id(i));
                if i~=k
                    disp('i not equal to k');
                    error('i not equal to k')
                end
                FN.to_node{k} = FN.from_node{i};
                FN.outbound_msg{i} = snd_msg;
            end % for i = ...
        end %function update_node
        
        
        
    end % method
    
    methods (Access = protected)
        function rx_msg(FN, from_node, msg) % from_nodeΪVN
            s = FN; % s ΪFN
            from_nodeID = from_node.id;
            from_nodeIndx = find(s.link_id == from_nodeID);
            s.from_node{from_nodeIndx} = from_node;
            s.inbound_msg{from_nodeIndx} = msg;
            s.from_id(from_nodeIndx) = [from_node.id];
            
        end % function rx_msg
    end % methods
end