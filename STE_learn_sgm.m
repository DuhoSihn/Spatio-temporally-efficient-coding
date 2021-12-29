function [ W_f, b_f, LS ] = STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, varargin )
% Learning Spatio-temporally Efficient coding.
% Training multilayer perceptrons f : X -> Z and f : Z -> X.
% using He and Xavier initialization and Adam optimization.
%
% X : the training set, real value if observed & NaN otherwise, (the number of trials) X (the number of variables) matrix.
% io_f{ h, d }{ p, 1 } : indices of the domain of the ( p )th function from the hierarchy ( h - 1 ) to the hierarchy ( h ).
% io_f{ h, d }{ p, 2 } : indices of the range of the ( p )th function from the hierarchy ( h - 1 ) to the hierarchy ( h ).
% io_f{ h, 1 } : bottom-up.
% io_f{ h, 2 } : top-down.
% io_f{ h, 3 } : recurrent.
% hl_f{ h, d }{ p, 1 } : the number of neurons in each hidden layer of the ( p )th neural network f, ( the numebr of hidden layers ) X 2.
% If there is no hidden layer in f, then set hl_f{ h, 1 } = [].
% hl_f{ h, 1 } : bottom-up.
% hl_f{ h, 2 } : top-down.
% hl_f{ h, 3 } : recurrent.
% hl_f{ h, d }{ p, 1 }( 1, 1 ) : the number of neurons in the just next layer from the input layer.
% hl_f{ h, d }{ p, 1 }( end, 1 ) : the number of neurons in the previous layer from the output layer.
% lambda : balancing paramter, scalar.
% lambda : balance of the first to second expectation.
% lambda > 0.
% kWidth : kernel widths used in kernel density estimation to maximize entropy, (the number of hierarchy) X (1) vector.
% miniBatchSize : the number of samples for mini-batch, scalar.
% miniBatchSize <= size( X, 1 ).
% nPred : the number of predictive iterations, >= 1.
% nMaxIter : the number of maximum allowable iterations of the gradient method, scalar.
%
% W_f{ h, 1 } : weights of the neural network f, (the number of hidden layers + 1) X (3) cell.
% W_f{ h, 1 } : bottom-up.
% W_f{ h, 2 } : top-down.
% W_f{ h, 3 } : recurrent.
% W_f{ h, 1 }{ l, 1 } : (the number of neurons in the present layer) X (the number of neurons in the previous layer) matrix.
% b_f{ h, 1 } : bias of the neural network f, (the number of hidden layers + 1) X (2) cell.
% b_f{ h, 1 }{ l, 1 } : (the number of neurons in the present layer) X (1) vector;
% LS : the objective to be minimized.
%
% initial : providing initial weight and bias.
% e.g.) [ W_f, b_f, LS ] = STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'initial', W_f, b_f )
% params : learning parameters of Adam optimization.
% e.g.) [ W_f, b_f, LS ] = STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'params', alpha, beta1, beta2, epsilon )


[ nN, nV ] = size( X );

nH = size( io_f, 1 );

nP = [];
nZ = [];% nZ( h ) : the dimension of latent space Z, scalar.
for h = 1 : nH
    nP( h, 1 ) = size( io_f{ h, 1 }, 1 );
    totalZ = [];
    for p = 1 : nP( h )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end
    nZ( h, 1 ) = length( unique( totalZ ) );
end

nL_f = nan( nH, 3, max( nP, [], 1 ) );
for h = 1 : nH
    for d = 1 : 3
        if d < 3
            for p = 1 : nP( h )
                nL_f( h, d, p ) = length( hl_f{ h, d }{ p, 1 } ) + 1;
            end
        elseif d == 3
            nL_f( h, d, 1 ) = length( hl_f{ h, d }{ 1, 1 } ) + 1;
        end
    end
end


% initial weights and bias
type_initial = find( strcmpi(varargin, 'initial') == 1 );
if ~isempty( type_initial )
    W_f = varargin( type_initial + 1);
    W_f = W_f{1,1};
    b_f = varargin( type_initial + 2);
    b_f = b_f{1,1};
elseif isempty( type_initial )
    % Xavier initialization for the last layer for each hierrarchy
    % He initialization for the other layers for each hierrarchy
    W_f = cell( nH, 3 );
    b_f = cell( nH, 3 );
    for h = 1 : nH
        for d = 1 : 3% bottom-up, top-down, recurrent
            if d < 3
                W_f{ h, d } = cell( nP( h ), 1 );
                b_f{ h, d } = cell( nP( h ), 1 );
                nPh = nP( h );
            elseif d == 3
                W_f{ h, d } = cell( 1, 1 );
                b_f{ h, d } = cell( 1, 1 );
                nPh = 1;
            end
            for p = 1 : nPh
                W_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
                b_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
                if nL_f( h, d, p ) == 1
                    W_f{ h, d }{ p, 1 }{ 1, 1 } = randn( length( io_f{ h, d }{ p, 2 } ), length( io_f{ h, d }{ p, 1 } ) ) * sqrt( 2 / ( length( io_f{ h, d }{ p, 1 } ) + length( io_f{ h, d }{ p, 2 } ) ) );
                    b_f{ h, d }{ p, 1 }{ 1, 1 } = zeros( length( io_f{ h, d }{ p, 2 } ), 1 );
                elseif nL_f( h, d, p ) > 1
                    for l = 1 : nL_f( h, d, p )
                        if l == 1
                            W_f{ h, d }{ p, 1 }{ l, 1 } = randn( hl_f{ h, d }{ p, 1 }( l, 1 ), length( io_f{ h, d }{ p, 1 } ) ) * sqrt( 2 / ( length( io_f{ h, d }{ p, 1 } ) ) );
                            b_f{ h, d }{ p, 1 }{ l, 1 } = zeros( hl_f{ h, d }{ p, 1 }( l, 1 ), 1 );
                        elseif l > 1 && l < nL_f( h, d, p )
                            W_f{ h, d }{ p, 1 }{ l, 1 } = randn( hl_f{ h, d }{ p, 1 }( l, 1 ), hl_f{ h, d }{ p, 1 }( l - 1, 1 ) ) * sqrt( 2 / ( hl_f{ h, d }{ p, 1 }( l - 1, 1 ) ) );
                            b_f{ h, d }{ p, 1 }{ l, 1 } = zeros( hl_f{ h, d }{ p, 1 }( l, 1 ), 1 );
                        elseif l > 1 && l == nL_f( h, d, p )
                            W_f{ h, d }{ p, 1 }{ l, 1 } = randn( length( io_f{ h, d }{ p, 2 } ), hl_f{ h, d }{ p, 1 }( l - 1, 1 ) ) * sqrt( 2 / ( hl_f{ h, d }{ p, 1 }( l - 1, 1 ) + length( io_f{ h, d }{ p, 2 } ) ) );
                            b_f{ h, d }{ p, 1 }{ l, 1 } = zeros( length( io_f{ h, d }{ p, 2 } ), 1 );
                        end
                    end
                end
            end
        end
    end
end


% Parameters of Adam optimization -----------------------------------------
type_params = find( strcmpi(varargin, 'params') == 1 );
if ~isempty( type_params )
    alpha = varargin( type_params + 1);
    alpha = alpha{1,1};
    beta1 = varargin( type_params + 2);
    beta1 = beta1{1,1};
    beta2 = varargin( type_params + 3);
    beta2 = beta2{1,1};
    epsilon = varargin( type_params + 4);
    epsilon = epsilon{1,1};
elseif isempty( type_params )
    alpha = 0.001;
    % alpha = 0.0001;
    beta1 = 0.9;
    % beta1 = 0.5;
    beta2 = 0.999;
    epsilon = 10^(-8);
end

m_W_f = cell( nH, 3 );
m_b_f = cell( nH, 3 );
v_W_f = cell( nH, 3 );
v_b_f = cell( nH, 3 );
for h = 1 : nH
    for d = 1 : 3
        if d < 3
            nPh = nP( h );
        elseif d == 3
            nPh = 1;
        end
        m_W_f{ h, d } = cell( nPh, 1 );
        m_b_f{ h, d } = cell( nPh, 1 );
        v_W_f{ h, d } = cell( nPh, 1 );
        v_b_f{ h, d } = cell( nPh, 1 );
        for p = 1 : nPh
            m_W_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
            m_b_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
            v_W_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
            v_b_f{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
            for l = 1 : nL_f( h, d, p )
                m_W_f{ h, d }{ p, 1 }{ l, 1 } = zeros( size( W_f{ h, d }{ p, 1 }{ l, 1 } ) );
                m_b_f{ h, d }{ p, 1 }{ l, 1 } = zeros( size( b_f{ h, d }{ p, 1 }{ l, 1 } ) );
                v_W_f{ h, d }{ p, 1 }{ l, 1 } = zeros( size( W_f{ h, d }{ p, 1 }{ l, 1 } ) );
                v_b_f{ h, d }{ p, 1 }{ l, 1 } = zeros( size( b_f{ h, d }{ p, 1 }{ l, 1 } ) );
            end
        end
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
dW_f_1 = cell( nH, 3 );% gradient for wieght of the first term in Equation ()
db_f_1 = cell( nH, 3 );% gradient for bias of the first term in Equation ()
dW_f_2 = cell( nH, 3 );% gradient for wieght of the first term in Equation ()
db_f_2 = cell( nH, 3 );% gradient for bias of the first term in Equation ()
for h = 1 : nH
    for d = 1 : 3
        if d < 3
            nPh = nP( h );
        elseif d == 3
            nPh = 1;
        end
        dW_f_1{ h, d } = cell( nPh, 1 );
        db_f_1{ h, d } = cell( nPh, 1 );
        dW_f_2{ h, d } = cell( nPh, 1 );
        db_f_2{ h, d } = cell( nPh, 1 );
        for p = 1 : nPh
            dW_f_1{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );% gradient for wieght of the first term in Equation ()
            db_f_1{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );% gradient for bias of the first term in Equation ()
            dW_f_2{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );% gradient for wieght of the first term in Equation ()
            db_f_2{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );% gradient for bias of the first term in Equation ()
        end
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
transCoords = cell( nH, 3 );
for h = 1 : nH
    for d = 1 : 3
        if d == 1
            if h < nH
                transCoords{ h, d } = [ [ h + 1, 1 ]; [ h, 2 ]; [ h, 3 ] ];
            elseif h == nH
                transCoords{ h, d } = [ [ h, 2 ]; [ h, 3 ] ];
            end
        elseif d == 2
            if h > 1
                transCoords{ h, d } = [ [ h, 1 ]; [ h - 1, 2 ]; [ h - 1, 3 ] ];
            elseif h == 1
                transCoords{ h, d } = [ [ h, 1 ] ];
            end
        elseif d == 3
            if h < nH
                transCoords{ h, d } = [ [ h + 1, 1 ]; [ h, 2 ]; [ h, 3 ] ];
            elseif h == nH
                transCoords{ h, d } = [ [ h, 2 ]; [ h, 3 ] ];
            end
        end
    end
end
invTransCoords = cell( nH, 3 );
for h = 1 : nH
    for d = 1 : 3
        for hh = 1 : nH
            for dd = 1 : 3
                for hc = 1 : size( transCoords{ hh, dd }, 1 )
                    if all( [ h, d ] == transCoords{ hh, dd }( hc, : ) )
                        invTransCoords{ h, d } = [ invTransCoords{ h, d }; [ hh, dd ] ];
                    end
                end
            end
        end
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
rX = cell( nH, 1 );
sZ1 = cell( nH, 1 );
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
LS{ 1, 1 } = NaN( nMaxIter, nH + 1 );
LS{ 2, 1 } = NaN( nMaxIter, nH );
% -------------------------------------------------------------------------


t = 0;% the number of iteration
stopCriterion = 0;


while stopCriterion == 0
    
    
    t = t + 1;
    
    
    % Sampling ------------------------------------------------------------
    
    rn = randperm( nN );
    sX = X( rn( 1 : miniBatchSize ), : );
    sX_learn = repmat( sX, [ nPred - 2, 1 ] );
    sX = repmat( sX, [ 1, 1, nPred ] );
    
    if t == 1
        [ Z2, E2, Z1, ~, Z0, oZ1, oZ2 ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'learn' );
    else
        for h = 1 : nH
            rX{ h, 1 } = Z2{ h, 1 }( ( prod( nPred, 2 ) - 3 ) * miniBatchSize + [ 1 : miniBatchSize ], : );
        end
        [ Z2, E2, Z1, ~, Z0, oZ1, oZ2 ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'learn', 'prior', rX );
    end
    
    for h = 1 : nH + 1
        LS{ 1, 1 }( t, h ) = mean( mean( E2{ h, 1 } .^ 2, 2 ), 1 );
    end
    
    for h = 1 : nH
        sZ1{ h, 1 } = rand( miniBatchSize * ( prod( nPred, 2 ) - 2 ), nZ( h ) );
    end
    
    for h = 1 : nH
        d_Z{ h, 1 } = bsxfun( @minus, Z1{ h, 1 }, permute( Z1{ h, 1 }, [ 3, 2, 1 ] ) );
        ds_Z{ h, 1 } = permute( sqrt( sum( d_Z{ h, 1 } .^ 2, 2 ) ), [ 1, 3, 2 ] );
        dsk_Z{ h, 1 } = normpdf( ds_Z{ h, 1 }, 0, kWidth( h ) );
        dsk_Z{ h, 1 }( logical( eye( miniBatchSize * ( prod( nPred, 2 ) - 2 ) ) ) ) = NaN;
        d_sZ{ h, 1 } = bsxfun( @minus, Z1{ h, 1 }, permute( sZ1{ h, 1 }, [ 3, 2, 1 ] ) );
        ds_sZ{ h, 1 } = permute( sqrt( sum( d_sZ{ h, 1 } .^ 2, 2 ) ), [ 1, 3, 2 ] );
        dsk_sZ{ h, 1 } = normpdf( ds_sZ{ h, 1 }, 0, kWidth( h ) );
    end
    
    for h = 1 : nH
        LS{ 2, 1 }( t, h ) = mean( log( mean( dsk_Z{ h, 1 }, 2, 'omitnan' ) ./ mean( dsk_sZ{ h, 1 }, 2, 'omitnan' ) ), 1 );
    end
    
    % ---------------------------------------------------------------------
    
    
    % Gradient 1 ----------------------------------------------------------

    ct = cell( nH, 3 );
    for h = 1 : nH
        for d = 1 : 3
            if d < 3
                nPh = nP( h );
            elseif d == 3
                nPh = 1;
            end
            ct{ h, d } = cell( nPh, 1 );
            for p = 1 : nPh
                ct{ h, d }{ p, 1 } = zeros( nL_f( h, d, p ), 1 );
            end
        end
    end
    
    for h = 1 : nH
        
        for d2 = [ 1, 2, 3 ]% (2) bottom-up, top-down, recurrent
            
            if d2 == 1
                d_cum2_b = 2 * E2{ h + 1, 1 };% derivative of square of L2 norm.
            elseif d2 == 2
                d_cum2_b = 2 * E2{ h, 1 };% derivative of square of L2 norm.
            elseif d2 == 3
                d_cum2_b = 2 * E2{ h + 1, 1 };% derivative of square of L2 norm.
            end
            
            d_cum2_b = transpose( d_cum2_b );
            
            if d2 == 1
                if h == 1
                    d_cum2_e = zeros( nV, ( prod( nPred, 2 ) - 2 ) * miniBatchSize );
                else
                    d_cum2_e = zeros( nZ( h - 1 ), ( prod( nPred, 2 ) - 2 ) * miniBatchSize );
                end
            elseif d2 == 2
                d_cum2_e = zeros( nZ( h ), ( prod( nPred, 2 ) - 2 ) * miniBatchSize );
            elseif d2 == 3
                d_cum2_e = zeros( nZ( h ), ( prod( nPred, 2 ) - 2 ) * miniBatchSize );
            end
            
            if d2 < 3
                nPh2 = nP( h );
            elseif d2 == 3
                nPh2 = 1;
            end
            for p = 1 : nPh2
                
                d_cum2 = d_cum2_b( io_f{ h, d2 }{ p, 2 }, : );
                
                for l = nL_f( h, d2, p ) : -1 : 1
                    
                    if l == nL_f( h, d2, p )
                        
                        % derivative of sigmoid activation function
                        daf = oZ2{ h, d2 }{ p, 1 }{ l, 1 };
                        daf = bsxfun( @rdivide, exp( -daf ), bsxfun( @plus, 1, exp( -daf ) ) .^ 2 );
                        
                        d_cum2 = d_cum2 .* daf;
                        
                        t_db_f = d_cum2;
                        
                        if l > 1
                            t_dW_f = bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), permute( oZ2{ h, d2 }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                        elseif l == 1
                            if d2 == 1
                                if h == 1
                                    t_X = [ sX_learn ];
                                else
                                    t_X = [ Z1{ h - 1, 1 } ];
                                end
                            elseif d2 == 2
                                t_X = [ Z1{ h, 1 } ];
                            elseif d2 == 3
                                t_X = [ Z1{ h, 1 } ];
                            end
                            t_X = t_X( :, io_f{ h, d2 }{ p, 1 } );
                            t_dW_f = bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                        end
                        
                    elseif l < nL_f( h, d2, p )
                        
                        d_cum2 = permute( sum( bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), W_f{ h, d2 }{ p, 1 }{ l + 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                        
                        % derivative of ReLU activation function
                        daf = oZ2{ h, d2 }{ p, 1 }{ l, 1 };
                        daf( daf > 0 ) = 1;
                        daf( daf <= 0 ) = 0;
                        
                        d_cum2 = d_cum2 .* daf;
                        
                        t_db_f = d_cum2;
                        
                        if l > 1
                            t_dW_f = bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), permute( oZ2{ h, d2 }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                        elseif l == 1
                            if d2 == 1
                                if h == 1
                                    t_X = [ sX_learn ];
                                else
                                    t_X = [ Z1{ h - 1, 1 } ];
                                end
                            elseif d2 == 2
                                t_X = [ Z1{ h, 1 } ];
                            elseif d2 == 3
                                t_X = [ Z1{ h, 1 } ];
                            end
                            t_X = t_X( :, io_f{ h, d2 }{ p, 1 } );
                            t_dW_f = bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                        end
                        
                    end
                    
                    ct{ h, d2 }{ p, 1 }( l ) = ct{ h, d2 }{ p, 1 }( l ) + 1;
                    t_db_f = mean( t_db_f, 2 );
                    t_dW_f = mean( t_dW_f, 3 );
                    db_f_1{ h, d2 }{ p, 1 }{ l, 1 }( :, ct{ h, d2 }{ p, 1 }( l ) ) = t_db_f;
                    dW_f_1{ h, d2 }{ p, 1 }{ l, 1 }( :, :, ct{ h, d2 }{ p, 1 }( l ) ) = t_dW_f;
                    
                end
                
                d_cum2 = permute( sum( bsxfun( @times, permute( d_cum2, [ 1, 3, 2 ] ), W_f{ h, d2 }{ p, 1 }{ 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                d_cum2_e( io_f{ h, d2 }{ p, 1 }, : ) = d_cum2_e( io_f{ h, d2 }{ p, 1 }, : ) + d_cum2;
                
            end
            
            for hc = 1 : size( invTransCoords{ h, d2 }, 1 )
                
                h1 = invTransCoords{ h, d2 }( hc, 1 );
                d1 = invTransCoords{ h, d2 }( hc, 2 );% (1)
                
                if d1 < 3
                    nPh1 = nP( h1 );
                elseif d1 == 3
                    nPh1 = 1;
                end
                for p = 1 : nPh1
                    
                    d_cum1 = d_cum2_e( io_f{ h1, d1 }{ p, 2 }, : );
                    
                    for l = nL_f( h1, d1, p ) : -1 : 1
                        
                        if l == nL_f( h1, d1, p )
                            
                            % derivative of sigmoid activation function
                            daf = oZ1{ h1, d1 }{ p, 1 }{ l, 1 };
                            daf = bsxfun( @rdivide, exp( -daf ), bsxfun( @plus, 1, exp( -daf ) ) .^ 2 );
                            
                            d_cum1 = d_cum1 .* daf;
                            
                            t_db_f = d_cum1;
                            
                            if l > 1
                                t_dW_f = bsxfun( @times, permute( d_cum1, [ 1, 3, 2 ] ), permute( oZ1{ h1, d1 }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                            elseif l == 1
                                if d1 == 1
                                    if h1 == 1
                                        t_X = [ sX_learn ];
                                    else
                                        t_X = [ Z0{ h1 - 1, 1 } ];
                                    end
                                elseif d1 == 2
                                    t_X = [ Z0{ h1, 1 } ];
                                elseif d1 == 3
                                    t_X = [ Z0{ h1, 1 } ];
                                end
                                t_X = t_X( :, io_f{ h1, d1 }{ p, 1 } );
                                t_dW_f = bsxfun( @times, permute( d_cum1, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                            end
                            
                        elseif l < nL_f( h1, d1, p )
                            
                            d_cum1 = permute( sum( bsxfun( @times, permute( d_cum1, [ 1, 3, 2 ] ), W_f{ h1, d1 }{ p, 1 }{ l + 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                            
                            % derivative of ReLU activation function
                            daf = oZ1{ h1, d1 }{ p, 1 }{ l, 1 };
                            daf( daf > 0 ) = 1;
                            daf( daf <= 0 ) = 0;
                            
                            d_cum1 = d_cum1 .* daf;
                            
                            t_db_f = d_cum1;
                            
                            if l > 1
                                t_dW_f = bsxfun( @times, permute( d_cum1, [ 1, 3, 2 ] ), permute( oZ1{ h1, d1 }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                            elseif l == 1
                                if d1 == 1
                                    if h1 == 1
                                        t_X = [ sX_learn ];
                                    else
                                        t_X = [ Z0{ h1 - 1, 1 } ];
                                    end
                                elseif d1 == 2
                                    t_X = [ Z0{ h1, 1 } ];
                                elseif d1 == 3
                                    t_X = [ Z0{ h1, 1 } ];
                                end
                                t_X = t_X( :, io_f{ h1, d1 }{ p, 1 } );
                                t_dW_f = bsxfun( @times, permute( d_cum1, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                            end
                            
                        end
                        
                        ct{ h1, d1 }{ p, 1 }( l ) = ct{ h1, d1 }{ p, 1 }( l ) + 1;
                        t_db_f = mean( t_db_f, 2 );
                        t_dW_f = mean( t_dW_f, 3 );
                        db_f_1{ h1, d1 }{ p, 1 }{ l, 1 }( :, ct{ h1, d1 }{ p, 1 }( l ) ) = t_db_f;
                        dW_f_1{ h1, d1 }{ p, 1 }{ l, 1 }( :, :, ct{ h1, d1 }{ p, 1 }( l ) ) = t_dW_f;
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    % ---------------------------------------------------------------------
    
    
    % Gradient 2 ----------------------------------------------------------
    
    for h = 1 : nH
        
        d = 1;% (1) bottom-up
        
        % derivative of log-probability term (numerator).
        d_cum_n = 1 ./ ds_Z{ h, 1 };
        d_cum_n( logical( eye( miniBatchSize * ( prod( nPred, 2 ) - 2 ) ) ) ) = NaN;
        d_cum_n = bsxfun( @times, d_cum_n, -permute( d_Z{ h, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h ) .^ 2 ) );
        d_cum_n = mean( bsxfun( @times, d_cum_n, dsk_Z{ h, 1 } ), 2, 'omitnan' );% derivative of P(x)
        d_cum_n = permute( bsxfun( @rdivide, d_cum_n, mean( dsk_Z{ h, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P(x) )
        
        % derivative of log-probability term (denominator).
        d_cum_d = 1 ./ ds_sZ{ h, 1 };
        d_cum_d = bsxfun( @times, d_cum_d, -permute( d_sZ{ h, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h ) .^ 2 ) );
        d_cum_d = mean( bsxfun( @times, d_cum_d, dsk_sZ{ h, 1 } ), 2, 'omitnan' );% derivative of P_{u}(x)
        d_cum_d = permute( bsxfun( @rdivide, d_cum_d, mean( dsk_sZ{ h, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P_{u}(x) )
        
        d_cum_b = d_cum_n - d_cum_d;
        
        d_cum_b = transpose( d_cum_b );
        
        for p = 1 : nP( h )
            
            d_cum = d_cum_b( io_f{ h, d }{ p, 2 }, : );
            
            for l = nL_f( h, d, p ) : -1 : 1
                
                if l == nL_f( h, d, p )
                    
                    % derivative of sigmoid activation function
                    daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                    daf = bsxfun( @rdivide, exp( -daf ), bsxfun( @plus, 1, exp( -daf ) ) .^ 2 );
                    
                    d_cum = d_cum .* daf;
                    
                    t_db_f = d_cum;
                    
                    if l > 1
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                    elseif l == 1
                        if h == 1
                            t_X = [ sX_learn ];
                        else
                            t_X = [ Z0{ h - 1, 1 } ];
                        end
                        t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                    end
                    
                elseif l < nL_f( h, d, p )
                    
                    d_cum = permute( sum( bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), W_f{ h, d }{ p, 1 }{ l + 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                    
                    % derivative of ReLU activation function
                    daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                    daf( daf > 0 ) = 1;
                    daf( daf <= 0 ) = 0;
                    
                    d_cum = d_cum .* daf;
                    
                    t_db_f = d_cum;
                    
                    if l > 1
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                    elseif l == 1
                        if h == 1
                            t_X = [ sX_learn ];
                        else
                            t_X = [ Z0{ h - 1, 1 } ];
                        end
                        t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                    end
                    
                end
                
                t_db_f = mean( t_db_f, 2 );
                t_dW_f = mean( t_dW_f, 3 );
                db_f_2{ h, d }{ p, 1 }{ l, 1 } = t_db_f;
                dW_f_2{ h, d }{ p, 1 }{ l, 1 } = t_dW_f;
                
            end
            
        end
        
        d = 2;% (1) top-down
        
        if h > 1
            
            % derivative of log-probability term (numerator).
            d_cum_n = 1 ./ ds_Z{ h - 1, 1 };
            d_cum_n( logical( eye( miniBatchSize * ( prod( nPred, 2 ) - 2 ) ) ) ) = NaN;
            d_cum_n = bsxfun( @times, d_cum_n, -permute( d_Z{ h - 1, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h - 1 ) .^ 2 ) );
            d_cum_n = mean( bsxfun( @times, d_cum_n, dsk_Z{ h - 1, 1 } ), 2, 'omitnan' );% derivative of P(x)
            d_cum_n = permute( bsxfun( @rdivide, d_cum_n, mean( dsk_Z{ h - 1, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P(x) )
            
            % derivative of log-probability term (denominator).
            d_cum_d = 1 ./ ds_sZ{ h - 1, 1 };
            d_cum_d = bsxfun( @times, d_cum_d, -permute( d_sZ{ h - 1, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h - 1 ) .^ 2 ) );
            d_cum_d = mean( bsxfun( @times, d_cum_d, dsk_sZ{ h - 1, 1 } ), 2, 'omitnan' );% derivative of P_{u}(x)
            d_cum_d = permute( bsxfun( @rdivide, d_cum_d, mean( dsk_sZ{ h - 1, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P_{u}(x) )
            
            d_cum_b = d_cum_n - d_cum_d;
            
            d_cum_b = transpose( d_cum_b );
            
            for p = 1 : nP( h )
                
                d_cum = d_cum_b( io_f{ h, d }{ p, 2 }, : );
                
                for l = nL_f( h, d, p ) : -1 : 1
                    
                    if l == nL_f( h, d, p )
                        
                        % derivative of sigmoid activation function
                        daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                        daf = bsxfun( @rdivide, exp( -daf ), bsxfun( @plus, 1, exp( -daf ) ) .^ 2 );
                        
                        d_cum = d_cum .* daf;
                        
                        t_db_f = d_cum;
                        
                        if l > 1
                            t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                        elseif l == 1
                            t_X = [ Z0{ h, 1 } ];
                            t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                            t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                        end
                        
                    elseif l < nL_f( h, d, p )
                        
                        d_cum = permute( sum( bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), W_f{ h, d }{ p, 1 }{ l + 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                        
                        % derivative of ReLU activation function
                        daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                        daf( daf > 0 ) = 1;
                        daf( daf <= 0 ) = 0;
                        
                        d_cum = d_cum .* daf;
                        
                        t_db_f = d_cum;
                        
                        if l > 1
                            t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                        elseif l == 1
                            t_X = [ Z0{ h, 1 } ];
                            t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                            t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                        end
                        
                    end
                    
                    t_db_f = mean( t_db_f, 2 );
                    t_dW_f = mean( t_dW_f, 3 );
                    db_f_2{ h, d }{ p, 1 }{ l, 1 } = t_db_f;
                    dW_f_2{ h, d }{ p, 1 }{ l, 1 } = t_dW_f;
                    
                end
                
            end
            
        end
        
        d = 3;% (1) recurrent
        
        % derivative of log-probability term (numerator).
        d_cum_n = 1 ./ ds_Z{ h, 1 };
        d_cum_n( logical( eye( miniBatchSize * ( prod( nPred, 2 ) - 2 ) ) ) ) = NaN;
        d_cum_n = bsxfun( @times, d_cum_n, -permute( d_Z{ h, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h ) .^ 2 ) );
        d_cum_n = mean( bsxfun( @times, d_cum_n, dsk_Z{ h, 1 } ), 2, 'omitnan' );% derivative of P(x)
        d_cum_n = permute( bsxfun( @rdivide, d_cum_n, mean( dsk_Z{ h, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P(x) )
        
        % derivative of log-probability term (denominator).
        d_cum_d = 1 ./ ds_sZ{ h, 1 };
        d_cum_d = bsxfun( @times, d_cum_d, -permute( d_sZ{ h, 1 }, [ 1, 3, 2 ] ) / ( kWidth( h ) .^ 2 ) );
        d_cum_d = mean( bsxfun( @times, d_cum_d, dsk_sZ{ h, 1 } ), 2, 'omitnan' );% derivative of P_{u}(x)
        d_cum_d = permute( bsxfun( @rdivide, d_cum_d, mean( dsk_sZ{ h, 1 }, 2, 'omitnan' ) ), [ 1, 3, 2 ] );% derivative of log( P_{u}(x) )
        
        d_cum_b = d_cum_n - d_cum_d;
        
        d_cum_b = transpose( d_cum_b );
        
        for p = 1
            
            d_cum = d_cum_b( io_f{ h, d }{ p, 2 }, : );
            
            for l = nL_f( h, d, p ) : -1 : 1
                
                if l == nL_f( h, d, p )
                    
                    % derivative of sigmoid activation function
                    daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                    daf = bsxfun( @rdivide, exp( -daf ), bsxfun( @plus, 1, exp( -daf ) ) .^ 2 );
                    
                    d_cum = d_cum .* daf;
                    
                    t_db_f = d_cum;
                    
                    if l > 1
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                    elseif l == 1
                        if h == 1
                            t_X = [ sX_learn ];
                        else
                            t_X = [ Z0{ h, 1 } ];
                        end
                        t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                    end
                    
                elseif l < nL_f( h, d, p )
                    
                    d_cum = permute( sum( bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), W_f{ h, d }{ p, 1 }{ l + 1, 1 } ), 1 ), [ 2, 3, 1 ] );
                    
                    % derivative of ReLU activation function
                    daf = oZ1{ h, d }{ p, 1 }{ l, 1 };
                    daf( daf > 0 ) = 1;
                    daf( daf <= 0 ) = 0;
                    
                    d_cum = d_cum .* daf;
                    
                    t_db_f = d_cum;
                    
                    if l > 1
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( oZ1{ h, d }{ p, 1 }{ l - 1, 2 }, [ 3, 1, 2 ] ) );
                    elseif l == 1
                        if h == 1
                            t_X = [ sX_learn ];
                        else
                            t_X = [ Z0{ h, 1 } ];
                        end
                        t_X = t_X( :, io_f{ h, d }{ p, 1 } );
                        t_dW_f = bsxfun( @times, permute( d_cum, [ 1, 3, 2 ] ), permute( transpose( t_X ), [ 3, 1, 2 ] ) );
                    end
                    
                end
                
                t_db_f = mean( t_db_f, 2 );
                t_dW_f = mean( t_dW_f, 3 );
                db_f_2{ h, d }{ p, 1 }{ l, 1 } = t_db_f;
                dW_f_2{ h, d }{ p, 1 }{ l, 1 } = t_dW_f;
                
            end
            
        end
        
    end
    
    % ---------------------------------------------------------------------
    
    
    % Gradient descent ----------------------------------------------------
    
    dW_f_t_pool = cell( nH, 3 );
    db_f_t_pool = cell( nH, 3 );
    for h = 1 : nH
        for d = 1 : 3
            if d < 3
                nPh = nP( h );
            elseif d == 3
                nPh = 1;
            end
            dW_f_t_pool{ h, d } = cell( nPh, 1 );
            db_f_t_pool{ h, d } = cell( nPh, 1 );
            for p = 1 : nPh
                dW_f_t_pool{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
                db_f_t_pool{ h, d }{ p, 1 } = cell( nL_f( h, d, p ), 1 );
                for l = 1 : nL_f( h, d, p )
                    
                    if ~( h == 1 && d == 2 )
                        dW_f_t = sum( dW_f_1{ h, d }{ p, 1 }{ l, 1 }, 3 ) + lambda * dW_f_2{ h, d }{ p, 1 }{ l, 1 };% gradient for weight in Equation ()
                        db_f_t = sum( db_f_1{ h, d }{ p, 1 }{ l, 1 }, 2 ) + lambda * db_f_2{ h, d }{ p, 1 }{ l, 1 };% gradient for bias in Equation ()
                    else
                        dW_f_t = sum( dW_f_1{ h, d }{ p, 1 }{ l, 1 }, 3 );% gradient for weight in Equation ()
                        db_f_t = sum( db_f_1{ h, d }{ p, 1 }{ l, 1 }, 2 );% gradient for bias in Equation ()
                    end
                    if ~isempty( find( isnan( dW_f_t ), 1 ) ), error('There is NaN in the gradient. Decrease, the learning rate.'), end
                    if ~isempty( find( isnan( db_f_t ), 1 ) ), error('There is NaN in the gradient. Decrease, the learning rate.'), end
                    
                    dW_f_t_pool{ h, d }{ p, 1 }{ l, 1 } = dW_f_t;
                    db_f_t_pool{ h, d }{ p, 1 }{ l, 1 } = db_f_t;
                    
                end
            end
        end
    end
    
    for h = 1 : nH
        if h < nH
            
            t_db_f_t = zeros( nZ( h ), 3 );
            
            for p = 1 : nP( h )
                t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 ) = t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 ) + db_f_t_pool{ h, 1 }{ p, 1 }{ nL_f( h, 1, p ), 1 };
            end
            for p = 1 : nP( h + 1 )
                t_db_f_t( io_f{ h + 1, 2 }{ p, 2 }, 2 ) = t_db_f_t( io_f{ h + 1, 2 }{ p, 2 }, 2 ) + db_f_t_pool{ h + 1, 2 }{ p, 1 }{ nL_f( h + 1, 2, p ), 1 };
            end
            for p = 1
                t_db_f_t( io_f{ h, 3 }{ p, 2 }, 3 ) = t_db_f_t( io_f{ h, 3 }{ p, 2 }, 3 ) + db_f_t_pool{ h, 3 }{ p, 1 }{ nL_f( h, 3, p ), 1 };
            end
            
            t_db_f_t = sum( t_db_f_t, 2 );
            
            for p = 1 : nP( h )
                db_f_t_pool{ h, 1 }{ p, 1 }{ nL_f( h, 1, p ), 1 } = t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 );
            end
            for p = 1 : nP( h + 1 )
                db_f_t_pool{ h + 1, 2 }{ p, 1 }{ nL_f( h + 1, 2, p ), 1 } = t_db_f_t( io_f{ h + 1, 2 }{ p, 2 }, 1 );
            end
            for p = 1
                db_f_t_pool{ h, 3 }{ p, 1 }{ nL_f( h, 3, p ), 1 } = t_db_f_t( io_f{ h, 3 }{ p, 2 }, 1 );
            end
            
        elseif h == nH
            
            t_db_f_t = zeros( nZ( h ), 3 );
            
            for p = 1 : nP( h )
                t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 ) = t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 ) + db_f_t_pool{ h, 1 }{ p, 1 }{ nL_f( h, 1, p ), 1 };
            end
            for p = 1
                t_db_f_t( io_f{ h, 3 }{ p, 2 }, 3 ) = t_db_f_t( io_f{ h, 3 }{ p, 2 }, 3 ) + db_f_t_pool{ h, 3 }{ p, 1 }{ nL_f( h, 3, p ), 1 };
            end
            
            t_db_f_t = sum( t_db_f_t, 2 );
            
            for p = 1 : nP( h )
                db_f_t_pool{ h, 1 }{ p, 1 }{ nL_f( h, 1, p ), 1 } = t_db_f_t( io_f{ h, 1 }{ p, 2 }, 1 );
            end
            for p = 1
                db_f_t_pool{ h, 3 }{ p, 1 }{ nL_f( h, 3, p ), 1 } = t_db_f_t( io_f{ h, 3 }{ p, 2 }, 1 );
            end
            
        end
        
    end
    
    for h = 1 : nH
        for d = 1 : 3
            if d < 3
                nPh = nP( h );
            elseif d == 3
                nPh = 1;
            end
            for p = 1 : nPh
                for l = 1 : nL_f( h, d, p )
                    
                    dW_f_t = dW_f_t_pool{ h, d }{ p, 1 }{ l, 1 };
                    db_f_t = db_f_t_pool{ h, d }{ p, 1 }{ l, 1 };
                    
                    % Adam optimization
                    m_W_f{ h, d }{ p, 1 }{ l, 1 } = ( beta1 * m_W_f{ h, d }{ p, 1 }{ l, 1 } ) + ( ( 1 - beta1 ) * dW_f_t );
                    m_b_f{ h, d }{ p, 1 }{ l, 1 } = ( beta1 * m_b_f{ h, d }{ p, 1 }{ l, 1 } ) + ( ( 1 - beta1 ) * db_f_t );
                    v_W_f{ h, d }{ p, 1 }{ l, 1 } = ( beta2 * v_W_f{ h, d }{ p, 1 }{ l, 1 } ) + ( ( 1 - beta2 ) * ( dW_f_t .^ 2 ) );
                    v_b_f{ h, d }{ p, 1 }{ l, 1 } = ( beta2 * v_b_f{ h, d }{ p, 1 }{ l, 1 } ) + ( ( 1 - beta2 ) * ( db_f_t .^ 2 ) );
                    m_W_f_hat = m_W_f{ h, d }{ p, 1 }{ l, 1 } / ( 1 - ( beta1 ^ t ) );
                    m_b_f_hat = m_b_f{ h, d }{ p, 1 }{ l, 1 } / ( 1 - ( beta1 ^ t ) );
                    v_W_f_hat = v_W_f{ h, d }{ p, 1 }{ l, 1 } / ( 1 - ( beta2 ^ t ) );
                    v_b_f_hat = v_b_f{ h, d }{ p, 1 }{ l, 1 } / ( 1 - ( beta2 ^ t ) );
                    W_f{ h, d }{ p, 1 }{ l, 1 } = W_f{ h, d }{ p, 1 }{ l, 1 } - alpha * ( m_W_f_hat ./ ( sqrt( v_W_f_hat ) + epsilon * ones( size( v_W_f_hat ) ) ) );% gradient descent
                    b_f{ h, d }{ p, 1 }{ l, 1 } = b_f{ h, d }{ p, 1 }{ l, 1 } - alpha * ( m_b_f_hat ./ ( sqrt( v_b_f_hat ) + epsilon * ones( size( v_b_f_hat ) ) ) );% gradient descent
                    
                end
            end
        end
    end
    
    % ---------------------------------------------------------------------
    
    
    % Stop criterion ------------------------------------------------------
    %     if t >= ceil( nN / miniBatchSize(1) ) + 1 ...
    %             && ( C( t - ceil( nN / miniBatchSize(1) ), 1 ) - C( t, 1 ) ) ...
    %             < ...
    %             ( C( 1, 1 ) - C( ceil( nN / miniBatchSize(1) ) + 1, 1 ) ) * 10^(-3)
    %         stopCriterion = 1;
    %     end
    % ---------------------------------------------------------------------
    
    
    % Algorithm stop when reaching the user's allowable iterations --------
    if t >= nMaxIter
        stopCriterion = 1;
    end
    % ---------------------------------------------------------------------
    
    
end
