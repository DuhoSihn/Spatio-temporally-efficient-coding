function [ Z, oZ ] = STE_f_sgm( Z_input, io_f, W_f, b_f )
% f : X -> Z
% multilayer perceptron.
%
% X : the input, (the number of trials) X (the dimension of input variables) matrix.
% io_f{ h, d }{ p, 1 } : indices of the domain of the ( p )th function from the hierarchy ( h - 1 ) to the hierarchy ( h ).
% io_f{ h, d }{ p, 2 } : indices of the range of the ( p )th function from the hierarchy ( h - 1 ) to the hierarchy ( h ).
% io_f{ h, 1 } : bottom-up.
% io_f{ h, 2 } : top-down.
% io_f{ h, 3 } : recurrent.
% W_f : weights, (the number of hidden layers + 1) X (3) cell.
% W_f{ l, 1 } : (the number of neurons in the present layer) X (the number of neurons in the previous layer) matrix.
% b_f : bias, (the number of hidden layers + 1) X (3) cell.
% b_f{ l, 1 } : (the number of neurons in the present layer) X (1) vector;
%
% oZ{ l, 1 } : pre-activation output of the encoding f for X at each layer l, (the number of neurons in the present layer) X (the number of trials) matrix.
% oZ{ l, 2 } : output of the encoding f for X at each layer l, (the number of neurons in the present layer) X (the number of trials) matrix.
% Z : final output of encoding f, Z = transpose( oZ{ end, 2 } ).


nH = size( io_f, 1 );
nP = [];
for h = 1 : nH
    nP( h, 1 ) = size( io_f{ h, 1 }, 1 );
end

n_input = [];
for h = 1 : nH + 1
    n_input( h, 1 : 2 ) = size( Z_input{ h, 1 } );
end

nL = cell( nH, 3 );
oZ = cell( nH, 3 );
for h = 1 : nH
    for d = 1 : 3
        if d < 3
            nPh = nP( h );
        elseif d == 3
            nPh = 1;
        end
        oZ{ h, d } = cell( nPh, 1 );
        for p = 1 : nPh
            nL{ h, d }( p, 1 ) = size( W_f{ h, d }{ p, 1 }, 1 );
            oZ{ h, d }{ p, 1 } = cell( nL{ h, d }( p, 1 ), 2 );
        end
    end
end


for h = 1 : nH + 1
    
    if h == 1
        
        d = 2;% top-down
        X0 = [ Z_input{ h + 1, 1 } ];
        for p = 1 : nP( h )
            X = X0( :, io_f{ h, d }{ p, 1 } );
            for l = 1 : nL{ h, d }( p, 1 )
                
                if l == 1 && l < nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h, d }{ p, 1 }{ l, 1 } * oZ{ h, d }{ p, 1 }{ l - 1, 2 }, b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = W_f{ h, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = W_f{ h, d }{ p, 1 }{ l, 1 } * oZ{ h, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h, d }{ p, 1 }{ l, 2 } = oZ{ h, d }{ p, 1 }{ l, 1 };
                    oZ{ h, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h, d }{ p, 1 }{ l, 2 } = max( oZ{ h, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        % weighted sum + bias
        toZ = zeros( n_input( h, 2 ), n_input( h, 1 ) );
        tb_f = NaN( n_input( h, 2 ), 1 );
        for p = 1 : nP( h )
            toZ( io_f{ h, 2 }{ p, 2 }, : ) = toZ( io_f{ h, 2 }{ p, 2 }, : ) + oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 };
            tb_f( io_f{ h, 2 }{ p, 2 }, 1 ) = b_f{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 };
        end
        toZ = bsxfun( @plus, toZ, tb_f );
        for p = 1 : nP( h )
            oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 } = toZ( io_f{ h, 2 }{ p, 2 }, : );
        end
        
        % applying sigmoid activation function
        toZ = bsxfun( @rdivide, 1, bsxfun( @plus, 1, exp( -toZ ) ) );
        for p = 1 : nP( h )
            oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 2 } = toZ( io_f{ h, 2 }{ p, 2 }, : );
        end
        
        Z{ h, 1 } = transpose( toZ );
        
    elseif h > 1 && h < nH + 1
        
        d = 1;% bottom-up
        X0 = [ Z_input{ h - 1, 1 } ];
        for p = 1 : nP( h - 1 )
            X = X0( :, io_f{ h - 1, d }{ p, 1 } );
            for l = 1 : nL{ h - 1, d }( p, 1 )
                
                if l == 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 }, b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h - 1, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = oZ{ h - 1, d }{ p, 1 }{ l, 1 };
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = max( oZ{ h - 1, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        d = 2;% top-down
        X0 = [ Z_input{ h + 1, 1 } ];
        for p = 1 : nP( h )
            X = X0( :, io_f{ h, d }{ p, 1 } );
            for l = 1 : nL{ h, d }( p, 1 )
                
                if l == 1 && l < nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h, d }{ p, 1 }{ l, 1 } * oZ{ h, d }{ p, 1 }{ l - 1, 2 }, b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = W_f{ h, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h, d }{ p, 1 }{ l, 1 } = W_f{ h, d }{ p, 1 }{ l, 1 } * oZ{ h, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h, d }{ p, 1 }{ l, 2 } = oZ{ h, d }{ p, 1 }{ l, 1 };
                    oZ{ h, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h, d }{ p, 1 }{ l, 2 } = max( oZ{ h, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        d = 3;% recurrent
        X0 = [ Z_input{ h, 1 } ];
        for p = 1
            X = X0( :, io_f{ h - 1, d }{ p, 1 } );
            for l = 1 : nL{ h - 1, d }( p, 1 )
                
                if l == 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 }, b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h - 1, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = oZ{ h - 1, d }{ p, 1 }{ l, 1 };
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = max( oZ{ h - 1, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        % weighted sum + bias
        toZ = zeros( n_input( h, 2 ), n_input( h, 1 ) );
        tb_f = NaN( n_input( h, 2 ), 1 );
        for p = 1 : nP( h - 1 )
            toZ( io_f{ h - 1, 1 }{ p, 2 }, : ) = toZ( io_f{ h - 1, 1 }{ p, 2 }, : ) + oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 };
            tb_f( io_f{ h - 1, 1 }{ p, 2 }, 1 ) = b_f{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 };
        end
        for p = 1 : nP( h )
            toZ( io_f{ h, 2 }{ p, 2 }, : ) = toZ( io_f{ h, 2 }{ p, 2 }, : ) + oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 };
            tb_f( io_f{ h, 2 }{ p, 2 }, 1 ) = b_f{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 };
        end
        for p = 1
            toZ( io_f{ h - 1, 3 }{ p, 2 }, : ) = toZ( io_f{ h - 1, 3 }{ p, 2 }, : ) + oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 };
            tb_f( io_f{ h - 1, 3 }{ p, 2 }, 1 ) = b_f{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 };
        end
        toZ = bsxfun( @plus, toZ, tb_f );
        for p = 1 : nP( h - 1 )
            oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 } = toZ( io_f{ h - 1, 1 }{ p, 2 }, : );
        end
        for p = 1 : nP( h )
            oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 1 } = toZ( io_f{ h, d }{ p, 2 }, : );
        end
        for p = 1
            oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 } = toZ( io_f{ h - 1, 3 }{ p, 2 }, : );
        end
        
        % applying sigmoid activation function
        toZ = bsxfun( @rdivide, 1, bsxfun( @plus, 1, exp( -toZ ) ) );
        for p = 1 : nP( h - 1 )
            oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 2 } = toZ( io_f{ h - 1, 1 }{ p, 2 }, : );
        end
        for p = 1 : nP( h )
            oZ{ h, 2 }{ p, 1 }{ nL{ h, 2 }( p, 1 ), 2 } = toZ( io_f{ h, d }{ p, 2 }, : );
        end
        for p = 1
            oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 2 } = toZ( io_f{ h - 1, 3 }{ p, 2 }, : );
        end
        
        Z{ h, 1 } = transpose( toZ );
        
    elseif h == nH + 1
        
        d = 1;% bottom-up
        X0 = [ Z_input{ h - 1, 1 } ];
        for p = 1 : nP( h - 1 )
            X = X0( :, io_f{ h - 1, d }{ p, 1 } );
            for l = 1 : nL{ h - 1, d }( p, 1 )
                
                if l == 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 }, b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h - 1, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = oZ{ h - 1, d }{ p, 1 }{ l, 1 };
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = max( oZ{ h - 1, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        d = 3;% recurrent
        X0 = [ Z_input{ h, 1 } ];
        for p = 1
            X = X0( :, io_f{ h - 1, d }{ p, 1 } );
            for l = 1 : nL{ h - 1, d }( p, 1 )
                
                if l == 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X ), b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l < nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 }, b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l == 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * transpose( X );
                    % ----------
                    % oZ{ h - 1, d }{ p, 1 }{ l, 1 } = bsxfun( @plus, ...
                    %    permute( sum( bsxfun( @times, W_f{ h - 1, d }{ p, 1 }{ l, 1 }, permute( X, [ 3, 2, 1 ] ) ), 2, 'omitnan' ), [ 1, 3, 2 ] ), ...
                    %    b_f{ h - 1, d }{ p, 1 }{ l, 1 } );
                elseif l > 1 && l == nL{ h - 1, d }( p, 1 )
                    % weighted sum + bias
                    oZ{ h - 1, d }{ p, 1 }{ l, 1 } = W_f{ h - 1, d }{ p, 1 }{ l, 1 } * oZ{ h - 1, d }{ p, 1 }{ l - 1, 2 };
                end
                
                if l < nL{ h - 1, d }( p, 1 )
                    % applying ReLU activation function
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = oZ{ h - 1, d }{ p, 1 }{ l, 1 };
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 2 ) = zeros( size( oZ{ h - 1, d }{ p, 1 }{ l, 2 }( :, :, 1 ) ) );
                    oZ{ h - 1, d }{ p, 1 }{ l, 2 } = max( oZ{ h - 1, d }{ p, 1 }{ l, 2 }, [], 3 );
                end
                
            end
        end
        
        % weighted sum + bias
        toZ = zeros( n_input( h, 2 ), n_input( h, 1 ) );
        tb_f = NaN( n_input( h, 2 ), 1 );
        for p = 1 : nP( h - 1 )
            toZ( io_f{ h - 1, 1 }{ p, 2 }, : ) = toZ( io_f{ h - 1, 1 }{ p, 2 }, : ) + oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 };
            tb_f( io_f{ h - 1, 1 }{ p, 2 }, 1 ) = b_f{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 };
        end
        for p = 1
            toZ( io_f{ h - 1, 3 }{ p, 2 }, : ) = toZ( io_f{ h - 1, 3 }{ p, 2 }, : ) + oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 };
            tb_f( io_f{ h - 1, 3 }{ p, 2 }, 1 ) = b_f{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 };
        end
        toZ = bsxfun( @plus, toZ, tb_f );
        for p = 1 : nP( h - 1 )
            oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 1 } = toZ( io_f{ h - 1, 1 }{ p, 2 }, : );
        end
        for p = 1
            oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 1 } = toZ( io_f{ h - 1, 3 }{ p, 2 }, : );
        end
        
        % applying sigmoid activation function
        toZ = bsxfun( @rdivide, 1, bsxfun( @plus, 1, exp( -toZ ) ) );
        for p = 1 : nP( h - 1 )
            oZ{ h - 1, 1 }{ p, 1 }{ nL{ h - 1, 1 }( p, 1 ), 2 } = toZ( io_f{ h - 1, 1 }{ p, 2 }, : );
        end
        for p = 1
            oZ{ h - 1, 3 }{ p, 1 }{ nL{ h - 1, 3 }( p, 1 ), 2 } = toZ( io_f{ h - 1, 3 }{ p, 2 }, : );
        end
        
        Z{ h, 1 } = transpose( toZ );
        
    end
    
end
