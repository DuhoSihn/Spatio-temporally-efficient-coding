function [ W_f, b_f, LS ] = RR_SSTE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, varargin )
% Repetitive Restart optimization of SSTE_learn_sgm.m


type_initial = find( strcmpi(varargin, 'initial') == 1 );
if ~isempty( type_initial )
    W_f = varargin( type_initial + 1 );
    W_f = W_f{1,1};
    b_f = varargin( type_initial + 2 );
    b_f = b_f{1,1};
    LS = varargin( type_initial + 3 );
    LS = LS{1,1};
end

type_params = find( strcmpi(varargin, 'params') == 1 );
if ~isempty( type_params )
    alpha = varargin( type_params + 1 );
    alpha = alpha{1,1};
    beta1 = varargin( type_params + 2 );
    beta1 = beta1{1,1};
    beta2 = varargin( type_params + 3 );
    beta2 = beta2{1,1};
    epsilon = varargin( type_params + 4 );
    epsilon = epsilon{1,1};
elseif isempty( type_params )
    alpha = 0.001;
    % alpha = 0.0001;
    beta1 = 0.9;
    % beta1 = 0.5;
    beta2 = 0.999;
    epsilon = 10^(-8);
end

type_GPU = find( strcmpi(varargin, 'GPU') == 1 );


cumsum_nMaxIter = cumsum( nMaxIter );
if isempty( type_initial )
    LS = cell( 2, 1 );
end
disp( [ 'Begin, Repetitive Restart optimization...' ] )
for iter = 1 : length( nMaxIter )
    
    status = 0;
    while status == 0
        status = 1;
        try
            if iter == 1 && isempty( type_initial )
                if isempty( type_GPU )
                    [ W_f, b_f, tLS ] = SSTE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter( iter ), 'params', alpha, beta1, beta2, epsilon );
                else
                    [ W_f, b_f, tLS ] = SSTE_learn_sgm_GPU( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter( iter ), 'params', alpha, beta1, beta2, epsilon );
                end
            elseif ( iter == 1 && ~isempty( type_initial ) ) || iter > 1
                if isempty( type_GPU )
                    [ W_f, b_f, tLS ] = SSTE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter( iter ), 'initial', W_f, b_f, 'params', alpha, beta1, beta2, epsilon );
                else
                    [ W_f, b_f, tLS ] = SSTE_learn_sgm_GPU( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter( iter ), 'initial', W_f, b_f, 'params', alpha, beta1, beta2, epsilon );
                end
            end
        catch
            status = 0;
            disp( [ 'error!' ] )
            alpha = 0.5 * alpha;
            disp( [ 'Decreasing learning rate to alpha = ', num2str( alpha ) ] )
        end
    end
    
    for k = 1 : 2
        LS{ k, 1 } = [ LS{ k, 1 }; tLS{ k, 1 } ];
    end
    
    save( 'temp_RR_TP_learn.mat', 'W_f', 'b_f', 'LS' )
    
    disp( [ num2str( cumsum_nMaxIter( iter ) ), ' / ', num2str( cumsum_nMaxIter( end ) ) ] )
    
end
disp( [ 'End, Repetitive Restart optimization...' ] )
