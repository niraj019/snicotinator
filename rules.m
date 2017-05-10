function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
        fncs{i} = str2func(fncs{i});
    end
end

%ADD RULES BELOW
function result = ddr1( model, trace, params, t )
    erl_new = trace(t).erl + (1-model.parameters.default.beta) * (( (1-model.parameters.default.w) * model.parameters.default.v1 + model.parameters.default.w * trace(t).v2 ) - trace(t).erl) * model.parameters.default.delta_t;
    result = {t+1, 'erl', erl_new};
end
function result = ddr2( model, trace, params, t )
    v2_new = trace(t).v2 - ( model.parameters.default.a2 * trace(t).d / model.parameters.default.d_max ) * model.parameters.default.delta_t;
    result = {t+1, 'v2', v2_new};
end
function result = ddr3( model, trace, params, t )
    d_new = trace(t).erl - model.parameters.default.erl_norm;
    result = {t+1, 'd', d_new};
end

function result = padr1( model, trace, params, t )
    
    if mod(t,5) == 0;
        t
        
        if model.parameters.default.a2 > 0.0
            %PUNTEN GRAFIEK REAPPRAISAL
            graph_values = [0.004 0.012 0.034 0.057 0.068 0.082 0.093 0.097 0.105 0.112 0.117 0.128 0.132 0.129 0.131 0.136 0.139 0.142 0.148 0.153]; 
        else
            %PUNTEN GRAFIEK DEFAULT
            graph_values = [0.014 0.023 0.041 0.072 0.093 0.116 0.125 0.133 0.144 0.147 0.150 0.152 0.153 0.156 0.159 0.164 0.169 0.181 0.189 0.191];
        end
        
        
        
        graph_value = graph_values(t/5)
        
        min_margin = graph_value - 0.01 
        max_margin = graph_value + 0.01
        
        erl = trace(t).erl
        
        if erl < min_margin 
            
            correctness_graph = 'low'
            result = {t+1, 'correctness_graph', correctness_graph};
            
        elseif erl > max_margin
            
            correctness_graph = 'high'
            result = {t+1, 'correctness_graph', correctness_graph};
            
        else
            
            correctness_graph = 'good'
            result = {t+1, 'correctness_graph', correctness_graph};
        end
        
    else
        correctness_graph = 'not_revised'
        result = {t+1, 'correctness_graph', correctness_graph};
    end
end

function result = padr2(model, trace, params, t)
    
    for correctness_graph = l2.getall(trace, t, 'correctness_graph', {NaN})

        if strcmp(correctness_graph.arg{1}, 'low') 
            model.parameters.default.beta = model.parameters.default.beta       - 0.03;
            model.parameters.default.w = model.parameters.default.w             - 0.09;
            model.parameters.default.v1 = model.parameters.default.v1           + 0.01;
            model.parameters.default.delta_t = model.parameters.default.delta_t + 0.03;
            model.parameters.default.d_max = model.parameters.default.d_max     - 0.03;
            model.parameters.default.erl_norm = model.parameters.default.erl_norm +0.01;

        elseif strcmp(correctness_graph.arg{1}, 'high')
            model.parameters.default.beta = model.parameters.default.beta       + 0.03;
            model.parameters.default.w = model.parameters.default.w             + 0.09;
            model.parameters.default.v1 = model.parameters.default.v1           - 0.01;
            model.parameters.default.delta_t = model.parameters.default.delta_t - 0.03;
            model.parameters.default.d_max = model.parameters.default.d_max     + 0.02;
            model.parameters.default.erl_norm = model.parameters.default.erl_norm -0.01;
                     
        elseif strcmp(correctness_graph.arg{1}, 'good') && (trace(t).erl <= trace(t-1).erl)
            model.parameters.default.beta = model.parameters.default.beta       - 0.03;
            model.parameters.default.w = model.parameters.default.w             - 0.09;
            model.parameters.default.v1 = model.parameters.default.v1           + 0.01;
            model.parameters.default.delta_t = model.parameters.default.delta_t + 0.03;
            model.parameters.default.d_max = model.parameters.default.d_max     - 0.03;
            model.parameters.default.erl_norm = model.parameters.default.erl_norm +0.01;
            

        else
            ;
            
        end   
        
    end
      
    result = {t+1, 'beta', model.parameters.default.beta};
    result = {t+1, 'w', model.parameters.default.w};
    result = {t+1, 'v1', model.parameters.default.v1};
    result = {t+1, 'delta_t', model.parameters.default.delta_t};
    result = {t+1, 'd_max', model.parameters.default.d_max};
    result = {t+1, 'erl_norm', model.parameters.default.erl_norm};

end

