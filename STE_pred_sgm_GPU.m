function [ Z2, E2, Z1, E1, Z0, oZ1, oZ2 ] = STE_pred_sgm_GPU( sX, io_f, W_f, b_f, varargin )
% Bidirectional prediction
%
% learn : the result will be used to learning.
% e.g.) [ Z2, E2, Z1, E1, Z0, oZ1, oZ2 ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'learn' )
%
% prior : providing prior instead of using uniformly distributed random prior.
% e.g.) [ Z2, E2, Z1, E1, Z0, oZ1, oZ2 ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX )


type_learn = find( strcmpi(varargin, 'learn') == 1, 1 );

type_prior = find( strcmpi(varargin, 'prior') == 1, 1 );

nPred = size( sX, 3 );
nPred = gpuArray( nPred );

miniBatchSize = size( sX, 1 );
miniBatchSize = gpuArray( miniBatchSize );

nH = size( io_f, 1 );

nP = [];
nZ = [];
for h = 1 : nH
    nP( h, 1 ) = size( io_f{ h, 1 }, 1 );
    totalZ = [];
    for p = 1 : nP( h )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end
    nZ( h, 1 ) = length( unique( totalZ ) );
end
nZ = gpuArray( nZ );


% ---------------------------------------------------------------------


Z_curr = cell( nH + 1, 1 );
for h = 1 : nH + 1
    if h == 1
        Z_curr{ h, 1 } = sX( :, :, 1 );
    else
        if isempty( type_prior )
            % uniformly generated prior on hypercube.
            rX = rand( miniBatchSize, nZ( h - 1 ), 'gpuArray' );
        elseif ~isempty( type_prior )
            rX = varargin( type_prior + 1);
            rX = rX{ 1, 1 };
            rX = rX{ h - 1, 1 };
        end
        Z_curr{ h, 1 } = rX;
    end
end
E_curr = cell( nH + 1, 1 );
for h = 1 : nH + 1
    if h == 1
        E_curr{ h, 1 } = zeros( size( sX( :, :, 1 ) ), 'gpuArray' );
    else
        E_curr{ h, 1 } = zeros( miniBatchSize, nZ( h - 1 ), 'gpuArray' );
    end
end


% -------------------------------------------------------------------------


Z2 = cell( nH, 1 );
E2 = cell( nH + 1, 1 );
Z1 = cell( nH, 1 );
E1 = cell( nH + 1, 1 );
Z0 = cell( nH, 1 );
oZ1 = cell( nH, 3 );
oZ2 = cell( nH, 3 );
Z_input = cell( nH + 1, 1 );

ct = 0;

for tt = 1 : nPred
    
    for h = 1 : nH + 1
        if h == 1
            Z_input{ h, 1 } = sX( :, :, tt );
        else
            Z_input{ h, 1 } = Z_curr{ h, 1 };
        end
    end
    
    [ t_Z, t_oZ ] = STE_f_sgm_GPU( Z_input, io_f, W_f, b_f );
    
    for h = 1 : nH
        for d = 1 : 3
            if d < 3
                nPh = nP( h );
            elseif d == 3
                nPh = 1;
            end
            for p = 1 : nPh
                for l = 1 : size( t_oZ{ h, d }{ p, 1 }, 1 )
                    for k = 1 : size( t_oZ{ h, d }{ p, 1 }, 2 )
                        oZ2{ h, d }{ p, 1 }{ l, k }( :, ct + [ 1 : miniBatchSize ] ) = t_oZ{ h, d }{ p, 1 }{ l, k };
                        if tt == 1
                            oZ1{ h, d }{ p, 1 }{ l, k }( :, ct + [ 1 : miniBatchSize ] ) = t_oZ{ h, d }{ p, 1 }{ l, k };
                            oZ1{ h, d }{ p, 1 }{ l, k }( :, ct + [ 1 : miniBatchSize ] ) = NaN;
                        else
                            oZ1{ h, d }{ p, 1 }{ l, k }( :, ct + [ 1 : miniBatchSize ] ) = oZ2{ h, d }{ p, 1 }{ l, k }( :, ct - miniBatchSize + [ 1 : miniBatchSize ] );
                        end
                    end
                end
            end
        end
    end
    
    if tt == 1
        for h = 1 : nH
            Z1{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = Z_curr{ h + 1, 1 };
            Z0{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = Z_curr{ h + 1, 1 };
            Z0{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = NaN;
        end
    else
        for h = 1 : nH
            Z1{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = Z2{ h, 1 }( ct - miniBatchSize + [ 1 : miniBatchSize ], : );
            Z0{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = Z1{ h, 1 }( ct - miniBatchSize + [ 1 : miniBatchSize ], : );
        end
    end
    
    for h = 1 : nH + 1
        
        if h == 1
            E_curr{ h, 1 } = Z_curr{ h, 1 } - sX( :, :, tt );
        else
            E_curr{ h, 1 } = Z_curr{ h, 1 } - t_Z{ h, 1 };
        end
        
        Z_curr{ h, 1 } = t_Z{ h, 1 };
        
    end
    
    for h = 1 : nH
        Z2{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = Z_curr{ h + 1, 1 };
    end
    
    for h = 1 : nH + 1
        E1{ h, 1 }( ct + [ 1 : miniBatchSize ], : ) = E_curr{ h, 1 };
    end
    
    % ---------------------------------------------------------------------
    
    ct = ct + miniBatchSize;
    
end

for h = 1 : nH + 1
    E2{ h, 1 } = [ E1{ h, 1 }( miniBatchSize + 1 : end , : ); NaN( miniBatchSize, size( E1{ h, 1 },2  ), 'gpuArray' ) ];
end


% -------------------------------------------------------------------------


if ~isempty( type_learn )
    
    for h = 1 : nH
        Z2{ h, 1 } = Z2{ h, 1 }( miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize, : );
        Z1{ h, 1 } = Z1{ h, 1 }( miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize, : );
        Z0{ h, 1 } = Z0{ h, 1 }( miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize, : );
    end
    
    for h = 1 : nH + 1
        E2{ h, 1 } = E2{ h, 1 }( miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize, : );
        E1{ h, 1 } = E1{ h, 1 }( miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize, : );
    end
    
    for h = 1 : nH
        for d = 1 : 3
            if d < 3
                nPh = nP( h );
            elseif d == 3
                nPh = 1;
            end
            for p = 1 : nPh
                for l = 1 : size( oZ2{ h, d }{ p, 1 }, 1 )
                    for k = 1 : size( oZ2{ h, d }{ p, 1 }, 2 )
                        oZ2{ h, d }{ p, 1 }{ l, k } = oZ2{ h, d }{ p, 1 }{ l, k }( :, miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize );
                        oZ1{ h, d }{ p, 1 }{ l, k } = oZ1{ h, d }{ p, 1 }{ l, k }( :, miniBatchSize + 1 : ( nPred - 1 ) * miniBatchSize );
                    end
                end
            end
        end
    end
    
end
