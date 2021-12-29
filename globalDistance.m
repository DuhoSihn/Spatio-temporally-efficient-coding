function dist_X = globalDistance( X, dim, n )
% X := images, (# of images) X (# of pixels) matrix.
% dim := dimension of images, (1) X (2) vector, dim( 1 ) X dim( 2 ) = (# of pixels).
% n := number of image division.
%
% See,
% Di Gesu, V., Starovoitov, V. Distance-based functions for image comparison. Pattern Recognition Letters 1999; 20:207-214.


if mod( dim( 1 ) / n, 1 ) ~= 0 || mod( dim( 2 ) / n, 1 )
    error( 'dim must be divided by n.' )
end


idx_n = zeros( n .^ 2, prod( dim, 2 ) );
ct_n = 0;
for m1 = 1 : n
    for m2 = 1 : n
        ct_n = ct_n + 1;
        idx = zeros( dim );
        idx( ( dim( 1 ) / n ) * ( m1 - 1 ) + [ 1 : ( dim( 1 ) / n ) ], ( dim( 2 ) / n ) * ( m2 - 1 ) + [ 1 : ( dim( 2 ) / n ) ] ) = 1;
        idx_n( ct_n, : ) = idx( : );
    end
end
idx_n = logical( idx_n );


dist_X = NaN( size( X, 1 ), size( X, 1 ), n .^ 2 );
parfor nn = 1 : n .^ 2
    
    t_dist_X = NaN( size( X, 1 ), size( X, 1 ) );
    [ x_grid, y_grid ] = meshgrid( [ 1 : dim( 2 ) / n ], [ 1 : dim( 1 ) / n ] );
    x_grid = x_grid( : );
    y_grid = y_grid( : );
    d_D = abs( bsxfun( @minus, x_grid, transpose( x_grid ) ) ) + abs( bsxfun( @minus, y_grid, transpose( y_grid ) ) );
    d_D = d_D / ( ( dim( 1 ) / n ) + ( dim( 2 ) / n ) );
    for n1 = 1 : size( X, 1 )
        for n2 = n1 : size( X, 1 )
            if n1 == n2
                t_dist_X( n1, n2 ) = 0;
            elseif n1 ~= n2
                GR = abs( bsxfun( @minus, transpose( X( n1, idx_n( nn, : ) ) ), X( n2, idx_n( nn, : ) ) ) ) ./ bsxfun( @max, transpose( X( n1, idx_n( nn, : ) ) ), X( n2, idx_n( nn, : ) ) );
                t_dist_X( n1, n2 ) = ( 2 / ( ( 96 .^ 2 ) * ( ( 64 .^ 2 ) - 1 ) ) ) * sum( sum( ( 0.5 * d_D ) + ( 0.5 * GR ), 1, 'omitnan' ), 2, 'omitnan' );
                t_dist_X( n2, n1 ) = t_dist_X( n1, n2 );
            end
        end
        if mod( n1, 100 ) == 0
            disp( [ 'X ', num2str( n1 ) ] )
        end
    end
    
    dist_X( :, :, nn ) = t_dist_X;
    
end


dist_X = ( 1 / ( n .^ 2 ) ) * sum( dist_X, 3 );
