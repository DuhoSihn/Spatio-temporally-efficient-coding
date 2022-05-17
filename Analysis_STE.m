% Analysis_STE
clear all; close all; clc



%% Parameters

io_f = {};
for p = 1 : 4
    img = zeros( 96, 64 );
    if p == 1
        img( 1 : 58, 1 : 38 ) = 1;
    elseif p == 2
        img( 1 : 58, 27 : 64 ) = 1;
    elseif p == 3
        img( 39 : 96, 1 : 38 ) = 1;
    elseif p == 4
        img( 39 : 96, 27 : 64 ) = 1;
    end
    img = reshape( img, [ 1, 96 * 64 ] );
    io_f{ 1, 1 }{ p, 1 } = transpose( find( img == 1 ) );% input, bottom-up
    if p == 1
        io_f{ 1, 1 }{ p, 2 } = transpose( [ 1 : 16 ] );% output, bottom-up
    elseif p == 2
        io_f{ 1, 1 }{ p, 2 } = transpose( [ 17 : 32 ] );% output, bottom-up
    elseif p == 3
        io_f{ 1, 1 }{ p, 2 } = transpose( [ 33 : 48 ] );% output, bottom-up
    elseif p == 4
        io_f{ 1, 1 }{ p, 2 } = transpose( [ 49 : 64 ] );% output, bottom-up
    end
    io_f{ 1, 2 }{ p, 1 } = io_f{ 1, 1 }{ p, 2 };% input, top-down
    io_f{ 1, 2 }{ p, 2 } = io_f{ 1, 1 }{ p, 1 };% output, top-down
    clear img
end; clear p
io_f{ 1, 3 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, recurrent
io_f{ 1, 3 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, recurrent
io_f{ 2, 1 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, bottom-up
io_f{ 2, 1 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, bottom-up
io_f{ 2, 2 }{ 1, 1 } = io_f{ 2, 1 }{ 1, 2 };% input, top-down
io_f{ 2, 2 }{ 1, 2 } = io_f{ 2, 1 }{ 1, 1 };% output, top-down
io_f{ 2, 3 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, recurrent
io_f{ 2, 3 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, recurrent


nZ = [];
for h = 1 : size( io_f, 1 )
    totalZ = [];
    for p = 1 : size( io_f{ h, 1 }, 1 )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end; clear p
    nZ( h, 1 ) = length( unique( totalZ ) );
    clear totalZ
end; clear h


%% Learning curves
% 
% load( 'Results_lambda10.mat' )
% 
% lw = 2;
% colors = [ 1, 0, 0; 0, 1, 0; 0, 0, 1 ];
% iter = 1;
% LS = results{ iter, 3 };
% 
% figure( 'position', [ 100, 100, 400, 220 ] )
% k = 1;
% subplot( 1, 2, k )
% semilogy( LS{ k, 1 }( :, 1 ), '-', 'color', colors( 1, : ), 'linewidth', lw )
% hold on
% semilogy( LS{ k, 1 }( :, 2 ), '-', 'color', colors( 2, : ), 'linewidth', lw )
% semilogy( LS{ k, 1 }( :, 3 ), '-', 'color', colors( 3, : ), 'linewidth', lw )
% set( gca, 'xlim', [ 0, size( LS{ k, 1 }, 1 ) ] )
% ylabel( 'Temporal difference' )
% xlabel( 'Iteration' )
% legend( 'Image', 'Lower hierarchy', 'Upper hierarchy', 'location', 'southeast' )
% k = 2;
% subplot( 1, 2, k )
% semilogy( LS{ k, 1 }( :, 1 ), '-', 'color', colors( 2, : ), 'linewidth', lw )
% hold on
% semilogy( LS{ k, 1 }( :, 2 ), '-', 'color', colors( 3, : ), 'linewidth', lw )
% set( gca, 'xlim', [ 0, size( LS{ k, 1 }, 1 ) ] )
% ylabel( 'Negative entropy' )
% xlabel( 'Iteration' )
% clear k
% 
% clear LS
% clear iter
% clear colors
% clear results
% 

%% Synaptic weightmagnitude on the hierarchy 1
% %
% % % clear all; close all; clc
% %
% %
% % s_W_f = {};
% % ms_W_f = [];
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %
% %     s_W_f{ fn, 1 } = [];
% %     for p = 1 : size( W_f{ 1, 1 }, 1 )
% %         s_W_f{ fn, 1 } = [ s_W_f{ fn, 1 }; sqrt( sum( W_f{ 1, 1 }{ p, 1 }{ end, 1 } .^ 2, 2 ) ) ];
% %     end; clear p
% %     ms_W_f( fn, 1 ) = mean( s_W_f{ fn, 1 }, 1 );
% %
% %     s_W_f{ fn, 2 } = [];
% %     for p = 1 : size( W_f{ 2, 2 }, 1 )
% %         s_W_f{ fn, 2 } = [ s_W_f{ fn, 2 }; sqrt( sum( W_f{ 2, 2 }{ p, 1 }{ end, 1 } .^ 2, 2 ) ) ];
% %     end; clear p
% %     ms_W_f( fn, 2 ) = mean( s_W_f{ fn, 2 }, 1 );
% %
% %     s_W_f{ fn, 3 } = [];
% %     for p = 1
% %         s_W_f{ fn, 3 } = [ s_W_f{ fn, 3 }; sqrt( sum( W_f{ 1, 3 }{ p, 1 }{ end, 1 } .^ 2, 2 ) ) ];
% %     end; clear p
% %     ms_W_f( fn, 3 ) = mean( s_W_f{ fn, 3 }, 1 );
% %
% %     clear W_f
% %     clear iter
% %     clear results
% %
% % end; clear fn
% %
% %
% % save( 'Final_Results_Weights.mat', 's_W_f', 'ms_W_f' )
% %
% %
% load( 'Final_Results_Weights.mat' )
% 
% 
% figure( 'position', [ 100, 100, 300, 200 ] )
% fn = 1;
% semilogy( fn - 0.2, s_W_f{ fn, 1 }( 1 ), '+', 'color', [ 1, 0.5, 0.5 ], 'markersize', 3 )
% hold on
% semilogy( fn + 0, s_W_f{ fn, 3 }( 1 ), '+', 'color', [ 0.75, 0.25, 0.75 ], 'markersize', 3 )
% semilogy( fn + 0.2, s_W_f{ fn, 2 }( 1 ), '+', 'color', [ 0.5, 0, 1 ], 'markersize', 3 )
% clear fn
% for fn = 1 : 4
%     semilogy( fn - 0.2, s_W_f{ fn, 1 }, '+', 'color', [ 1, 0.5, 0.5 ], 'markersize', 3 )
% end; clear h
% for fn = 1 : 4
%     semilogy( fn + 0, s_W_f{ fn, 3 }, '+', 'color', [ 0.75, 0.25, 0.75 ], 'markersize', 3 )
% end; clear h
% for fn = 1 : 4
%     semilogy( fn + 0.2, s_W_f{ fn, 2 }, '+', 'color', [ 0.5, 0, 1 ], 'markersize', 3 )
% end; clear h
% semilogy( [ 1 : 4 ] - 0.2, ms_W_f( :, 1 ), 'sk', 'markersize', 10 )
% semilogy( [ 1 : 4 ] + 0, ms_W_f( :, 3 ), 'sk', 'markersize', 10 )
% semilogy( [ 1 : 4 ] + 0.2, ms_W_f( :, 2 ), 'sk', 'markersize', 10 )
% set( gca, 'xlim', [ 0.5, 4 + 0.5 ], 'xtick', [ 1 : 4 ], 'xticklabel', { 'TEC', 'STEC', 'SEC', 'Sparse' } )
% ylabel( '( \Sigma_{i} w_{ij}^{2} )^{1/2}' )
% title( 'Synaptic weight magnitude' )
% legend( 'Bottom-up', 'Recurrent', 'Top-down', 'location', 'northwest' )
% 
% 
% clear s_W_f ms_W_f
% 

%% Trajectories
% %
% % % clear all; close all; clc
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % Z_1 = {};
% % Z_2 = {};
% % img = {};
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     sX = [];
% %     ct = 0;
% %     for n = [ 5, 7, 9, 10 ]
% %         ct = ct + 1;
% %         sX( :, :, ( ct - 1 ) * nPred + [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     end; clear n ct
% %
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %
% %     Z_1{ fn, 1 } = Z{ 1, 1 };
% %     Z_2{ fn, 1 } = Z{ 2, 1 };
% %
% %     for t = 1 : size( Z{ 1, 1 }, 1 )
% %         img{ fn, 1 }( t, : ) = sX( 1, :, t);
% %         Z_curr = {};
% %         for h = 1 : size( Z, 1 ) + 1
% %             if h == 1
% %                 Z_curr{ h, 1 } = sX( :, :, t );
% %             else
% %                 Z_curr{ h, 1 } = Z{ h - 1, 1 }( t, : );
% %             end
% %         end; clear h
% %         tZ = STE_f_sgm( Z_curr, io_f, W_f, b_f );
% %         img{ fn, 2 }( t, : ) = tZ{ 1, 1 };
% %         clear Z_curr E_curr tZ
% %     end; clear t
% %
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %
% %     clear results iter W_f b_f
% %
% % end; clear fn
% %
% %
% % save( 'Final_Results_Trajectories.mat', 'Z_1', 'Z_2', 'img' )
% %
% %
% load( 'Final_Results_Trajectories.mat' )
% 
% 
% figure( 'position', [ 100, 100, 700, 400 ])
% 
% fn = 2;
% t_img = img{ fn, 1 }( 2 * size( io_f, 1 ) + 1 : 2 * size( io_f, 1 ) + 1 : end, : );
% t_img1 = [];
% for n = 1 : size( t_img, 1 )
%     t_img1 = [ t_img1; transpose( reshape( t_img( n, : ), [ 96, 64 ] ) ) ];
% end; clear n
% t_img = img{ fn, 2 }( 2 * size( io_f, 1 ) + 1 : 2 * size( io_f, 1 ) + 1 : end, : );
% t_img2 = [];
% for n = 1 : size( t_img, 1 )
%     t_img2 = [ t_img2; transpose( reshape( t_img( n, : ), [ 96, 64 ] ) ) ];
% end; clear n
% t_img = [ t_img1, t_img2 ];
% 
% subplot( 2, 4, 1 )
% imagesc( t_img, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'ytick', [], 'xtick', [ 32, 64 + 64 ], 'xticklabel', { 'Original', 'Reconstructed' } )
% ylabel( 'Time (step)' )
% title( [ 'STEC' ] )
% clear fn t_img t_img1 t_img2
% 
% for fn = 1 : 4
%     subplot( 2, 5, fn + 1 )
%     imagesc( Z_1{ fn, 1 }, [ 0, 1 ] )
%     colormap( gca, turbo )
%     if fn == 1
%         ylabel( 'Time (step)' )
%         title( [ 'TEC, hierarchy 1' ] )
%     elseif fn == 2
%         title( [ 'STEC, hierarchy 1' ] )
%     elseif fn == 3
%         title( [ 'SEC, hierarchy 1' ] )
%     elseif fn == 4
%         title( [ 'Sparse, hierarchy 1' ] )
%     end
%     subplot( 2, 5, fn + 5 + 1 )
%     imagesc( Z_2{ fn, 1 }, [ 0, 1 ] )
%     colormap( gca, turbo )
%     xlabel( 'Unit' )
%     if fn == 1
%         ylabel( 'Time (step)' )
%         title( [ 'TEC, hierarchy 2' ] )
%     elseif fn == 2
%         title( [ 'STEC, hierarchy 2' ] )
%     elseif fn == 3
%         title( [ 'SEC, hierarchy 2' ] )
%     elseif fn == 4
%         title( [ 'Sparse, hierarchy 2' ] )
%     end
% end; clear h
% 
% 
% figure
% imagesc( NaN, [ 0, 1 ] )
% colormap( gca, turbo )
% colorbar
% 
% 
% unit = 3;
% figure( 'position', [ 100, 100, 600, 180 ] )
% for fn = 2 : 4
%     subplot( 1, 3, fn - 1 )
%     hold on
%     for s = 1 : 4
%         plot( ( ( s - 1 ) * 5 + 0.5 ) * [ 1, 1 ], [ 0, 1 ], ':k' )
%     end; clear s
%     plot( Z_1{ fn, 1 }( :, unit ), '-', 'color', 'm' )
%     set( gca, 'xlim', [ 1, 20 ], 'ylim', [ 0, 1 ] )
%     xlabel( 'Time (step)' )
%     if fn == 2
%         ylabel( 'Neural response' )
%         title( [ 'STEC' ] )
%     elseif fn == 3
%         title( [ 'SEC' ] )
%     elseif fn == 4
%         title( [ 'Sparse' ] )
%     end
% end; clear fn
% 

%% Distance between samples
% %
% clear all; close all; clc
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % % dist_X = [];
% % % for n = 1 : size( X, 1 )
% % %     dist_X( n, : ) = sqrt( sum( bsxfun( @minus, X( n, : ), X ) .^ 2, 2 ) );
% % %     if mod( n, 100 ) == 0
% % %         disp( [ 'X ', num2str( n ) ] )
% % %     end
% % % end; clear n
% % % save( 'dist_X_Euclidean.mat', 'dist_X' )
% %
% %
% % % dim = [ 96, 64 ];
% % % n = 4;
% % % dist_X = globalDistance( X, dim, n );
% % % clear dim n
% % % save( 'dist_X_GD.mat', 'dist_X' )
% %
% %
% % dist_Z_1 = [];
% % dist_Z_2 = [];
% % traj_Z_1 = [];
% % traj_Z_2 = [];
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     nPred = 2 * nPred;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     Z_1 = [];
% %     Z_2 = [];
% %     t_Z_1 = [];
% %     t_Z_2 = [];
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_1( n, : ) = Z{ 1, 1 }( 2 * size( io_f, 1 ) + 1, : );
% %         Z_2( n, : ) = Z{ 2, 1 }( 2 * size( io_f, 1 ) + 1, : );
% %         t_Z_1( n, : ) = Z{ 1, 1 }( end, : );
% %         t_Z_2( n, : ) = Z{ 2, 1 }( end, : );
% %         traj_Z_1( n, :, fn ) = sqrt( sum( bsxfun( @minus, Z{ 1, 1 }, t_Z_1( n, : ) ) .^ 2, 2 ) );
% %         traj_Z_2( n, :, fn ) = sqrt( sum( bsxfun( @minus, Z{ 2, 1 }, t_Z_2( n, : ) ) .^ 2, 2 ) );
% %     end; clear n
% %
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %
% %     dist_Z_1( :, :, fn ) = permute( sqrt( sum( bsxfun( @minus, Z_1, permute( Z_1, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %     dist_Z_2( :, :, fn ) = permute( sqrt( sum( bsxfun( @minus, Z_2, permute( Z_2, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %     traj_dist_Z_1( :, :, fn ) = permute( sqrt( sum( bsxfun( @minus, t_Z_1, permute( t_Z_1, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %     traj_dist_Z_2( :, :, fn ) = permute( sqrt( sum( bsxfun( @minus, t_Z_2, permute( t_Z_2, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %
% %     clear Z_1 Z_2 t_Z_1 t_Z_2
% %
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %
% %     disp( num2str( fn ) )
% %
% % end; clear fn
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % save( 'dist_Z_Euclidean.mat', 'dist_Z_1', 'dist_Z_2', 'traj_Z_1', 'traj_Z_2', 'traj_dist_Z_1', 'traj_dist_Z_2' )
% %
% %
% % % load( 'dist_X_Euclidean.mat' )
% % load( 'dist_X_GD.mat' )
% % load( 'dist_Z_Euclidean.mat' )
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % corr_100 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 4
% %         corr_100( fn, 1, n ) = corr( transpose( dist_X( n, : ) ), transpose( dist_Z_1( n, :, fn ) ) );
% %         corr_100( fn, 2, n ) = corr( transpose( dist_X( n, : ) ), transpose( dist_Z_2( n, :, fn ) ) );
% %     end; clear fn
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % t_dist_X = [];
% % t_dist_Z_1 = [];
% % t_dist_Z_2 = [];
% % for n = 1 : size( dist_X, 1 )
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( 0.04 * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( 0.04 * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( 0.04 * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     t_dist_X( n, : ) = dist_X( n, sort_idx );
% %     for fn = 1 : 4
% %         t_dist_Z_1( n, :, fn ) = dist_Z_1( n, sort_idx, fn );
% %         t_dist_Z_2( n, :, fn ) = dist_Z_2( n, sort_idx, fn );
% %     end; clear fn
% %     clear sort_data sort_idx
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% %
% % corr_4 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 4
% %         corr_4( fn, 1, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_1( n, :, fn ) ) );
% %         corr_4( fn, 2, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_2( n, :, fn ) ) );
% %     end; clear fn
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% % clear t_dist_X t_dist_Z_1 t_dist_Z_2
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % t_dist_X = [];
% % t_dist_Z_1 = [];
% % t_dist_Z_2 = [];
% % for n = 1 : size( dist_X, 1 )
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( 0.02 * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( 0.02 * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( 0.02 * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     t_dist_X( n, : ) = dist_X( n, sort_idx );
% %     for fn = 1 : 4
% %         t_dist_Z_1( n, :, fn ) = dist_Z_1( n, sort_idx, fn );
% %         t_dist_Z_2( n, :, fn ) = dist_Z_2( n, sort_idx, fn );
% %     end; clear fn
% %     clear sort_data sort_idx
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% %
% % corr_2 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 4
% %         corr_2( fn, 1, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_1( n, :, fn ) ) );
% %         corr_2( fn, 2, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_2( n, :, fn ) ) );
% %     end; clear fn
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% % clear t_dist_X t_dist_Z_1 t_dist_Z_2
% % 
% % 
% % % -------------------------------------------------------------------------
% %
% %
% % t_dist_X = [];
% % t_dist_Z_1 = [];
% % t_dist_Z_2 = [];
% % for n = 1 : size( dist_X, 1 )
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( 0.01 * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( 0.01 * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( 0.01 * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     t_dist_X( n, : ) = dist_X( n, sort_idx );
% %     for fn = 1 : 4
% %         t_dist_Z_1( n, :, fn ) = dist_Z_1( n, sort_idx, fn );
% %         t_dist_Z_2( n, :, fn ) = dist_Z_2( n, sort_idx, fn );
% %     end; clear fn
% %     clear sort_data sort_idx
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% %
% % corr_1 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 4
% %         corr_1( fn, 1, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_1( n, :, fn ) ) );
% %         corr_1( fn, 2, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_2( n, :, fn ) ) );
% %     end; clear fn
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% % clear t_dist_X t_dist_Z_1 t_dist_Z_2
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % ratio_traj2min = [];
% % for fn = 1 : 4
% %
% %     t_dist_Z = traj_dist_Z_1( :, :, fn );
% %     t_traj_Z = traj_Z_1( :, :, fn );
% %     t_dist_Z( logical( eye( size( t_dist_Z ) ) ) ) = NaN;
% %     min_t_dist_Z = min( t_dist_Z, [], 2, 'omitnan' );
% %     ratio_traj2min( fn, 1, :, : ) = bsxfun( @rdivide, t_traj_Z, min_t_dist_Z );
% %     clear t_dist_Z t_traj_Z min_t_dist_Z
% %
% %     t_dist_Z = traj_dist_Z_2( :, :, fn );
% %     t_traj_Z = traj_Z_2( :, :, fn );
% %     t_dist_Z( logical( eye( size( t_dist_Z ) ) ) ) = NaN;
% %     min_t_dist_Z = min( t_dist_Z, [], 2, 'omitnan' );
% %     ratio_traj2min( fn, 2, :, : ) = bsxfun( @rdivide, t_traj_Z, min_t_dist_Z );
% %     clear t_dist_Z t_traj_Z min_t_dist_Z
% %
% % end; clear fn
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % discr_50 = [];
% % thr = 0.5;
% % for n = 1 : size( dist_X, 1 )
% %
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( thr * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( thr * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( thr * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     sort_idx_X = ~sort_idx;
% %
% %     for fn = 1 : 4
% %         sort_data = sort( dist_Z_1( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_1, 1 ) ) );
% %         sort_idx = dist_Z_1( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_1, 1 ) )
% %             sort_idx1 = dist_Z_1( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_1( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_1, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_50( fn, 1, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% %
% %         sort_data = sort( dist_Z_2( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_2, 1 ) ) );
% %         sort_idx = dist_Z_2( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_2, 1 ) )
% %             sort_idx1 = dist_Z_2( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_2( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_2, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_50( fn, 2, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% %
% %     end; clear fn
% %
% %     clear sort_data sort_idx sort_idx_X
% %
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% %
% % end; clear n
% % clear thr
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % discr_10 = [];
% % thr = 0.1;
% % for n = 1 : size( dist_X, 1 )
% %
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( thr * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( thr * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( thr * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     sort_idx_X = ~sort_idx;
% %
% %     for fn = 1 : 4
% %         sort_data = sort( dist_Z_1( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_1, 1 ) ) );
% %         sort_idx = dist_Z_1( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_1, 1 ) )
% %             sort_idx1 = dist_Z_1( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_1( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_1, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_10( fn, 1, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% %
% %         sort_data = sort( dist_Z_2( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_2, 1 ) ) );
% %         sort_idx = dist_Z_2( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_2, 1 ) )
% %             sort_idx1 = dist_Z_2( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_2( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_2, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_10( fn, 2, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% %
% %     end; clear fn
% %
% %     clear sort_data sort_idx sort_idx_X
% %
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% %
% % end; clear n
% % clear thr
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % discr_1 = [];
% % thr = 0.01;
% % for n = 1 : size( dist_X, 1 )
% % 
% %     sort_data = sort( dist_X( n, : ) );
% %     sort_data = sort_data( round( thr * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( thr * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( thr * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     sort_idx_X = ~sort_idx;
% % 
% %     for fn = 1 : 4
% %         sort_data = sort( dist_Z_1( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_1, 1 ) ) );
% %         sort_idx = dist_Z_1( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_1, 1 ) )
% %             sort_idx1 = dist_Z_1( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_1( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_1, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_1( fn, 1, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% % 
% %         sort_data = sort( dist_Z_2( n, :, fn ) );
% %         sort_data = sort_data( round( thr * size( dist_Z_2, 1 ) ) );
% %         sort_idx = dist_Z_2( n, :, fn ) <= sort_data;
% %         if sum( sort_idx, 2 ) > round( thr * size( dist_Z_2, 1 ) )
% %             sort_idx1 = dist_Z_2( n, :, fn ) < sort_data;
% %             sort_idx2 = dist_Z_2( n, :, fn ) == sort_data;
% %             find_sort_idx2 = find( sort_idx2 );
% %             sort_idx2( find_sort_idx2( round( thr * size( dist_Z_2, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %             sort_idx = sort_idx1 | sort_idx2;
% %             clear sort_idx1 sort_idx2 find_sort_idx2
% %         end
% %         discr_1( fn, 2, n ) = sum( ~sort_idx & sort_idx_X, 2 ) / sum( sort_idx_X, 2 );
% % 
% %     end; clear fn
% % 
% %     clear sort_data sort_idx sort_idx_X
% % 
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % 
% % end; clear n
% % clear thr
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % pseudo_discr_50 = [];
% % pseudo_discr_10 = [];
% % pseudo_discr_1 = [];
% %
% % for iter = 1 : size( dist_X, 1 )
% %
% %     idx = zeros( 2, size( dist_X, 1 ) );
% %     idx( 1, randperm( size( dist_X, 1 ), round( 0.5 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx( 2, randperm( size( dist_X, 1 ), round( 0.5 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx = logical( idx );
% %     pseudo_discr_50( iter, 1 ) = sum( ~idx( 2, : ) & ~idx( 1, : ), 2 ) / sum( ~idx( 1, : ), 2 );
% %
% %     idx = zeros( 2, size( dist_X, 1 ) );
% %     idx( 1, randperm( size( dist_X, 1 ), round( 0.1 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx( 2, randperm( size( dist_X, 1 ), round( 0.1 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx = logical( idx );
% %     pseudo_discr_10( iter, 1 ) = sum( ~idx( 2, : ) & ~idx( 1, : ), 2 ) / sum( ~idx( 1, : ), 2 );
% %
% %     idx = zeros( 2, size( dist_X, 1 ) );
% %     idx( 1, randperm( size( dist_X, 1 ), round( 0.01 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx( 2, randperm( size( dist_X, 1 ), round( 0.01 * size( dist_X, 1 ) ) ) ) = 1;
% %     idx = logical( idx );
% %     pseudo_discr_1( iter, 1 ) = sum( ~idx( 2, : ) & ~idx( 1, : ), 2 ) / sum( ~idx( 1, : ), 2 );
% %
% %     clear idx
% %
% % end; clear iter
% %
% %
% % % -------------------------------------------------------------------------
% %
% %
% % save( 'Final_Results_Distance.mat', 'corr_100', 'corr_4', 'corr_2', 'corr_1', 'ratio_traj2min', 'discr_50', 'discr_10', 'discr_1', 'pseudo_discr_50', 'pseudo_discr_10', 'pseudo_discr_1' )
% %
% %
% % load( 'Final_Results_Distance.mat' )
% %
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % dist_X = [];
% % nn = 5;
% % dist_X = sqrt( sum( bsxfun( @minus, X( nn, : ), X ) .^ 2, 2 ) );
% % [ ~, sort_idx ] = sort( dist_X );
% % collected_samples = sort_idx( [ 1, 11, 21, 41, 1001, 2001, 4001 ], 1 );
% % clear nn sort_idx
% %
% %
% % fn = 2;
% %
% % if fn == 1
% %     load( 'Results_lambda0.mat' )
% % elseif fn == 2
% %     load( 'Results_lambda10.mat' )
% % elseif fn == 3
% %     load( 'Results_lambda1000.mat' )
% % elseif fn == 4
% %     load( 'Results_Sparse_lambda1000.mat' )
% % end
% %
% % iter = 1;
% % W_f = results{ iter, 1 };
% % b_f = results{ iter, 2 };
% %
% % nPred = 2 * size( io_f, 1 ) + 1;
% % rX = {};
% % for h = 1 : size( io_f, 1 )
% %     rX{ h, 1 } = zeros( 1, nZ( h ) );
% % end; clear h
% %
% % Z_1 = [];
% % Z_2 = [];
% % ct = 0;
% % for n = transpose( collected_samples )
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     Z_1( ct, : ) = Z{ 1, 1 }( end, : );
% %     Z_2( ct, : ) = Z{ 2, 1 }( end, : );
% % end; clear n ct
% %
% % clear Z E
% % clear sX rX
% % clear nPred
% %
% % dist_Z_1 = permute( sqrt( sum( bsxfun( @minus, Z_1, permute( Z_1, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% % dist_Z_2 = permute( sqrt( sum( bsxfun( @minus, Z_2, permute( Z_2, [ 3, 2, 1 ] ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %
% % clear Z_1 Z_2
% %
% % clear W_f b_f
% % clear iter
% % clear results
% %
% % clear fn
% %
% %
% % dist_X = dist_X( collected_samples );
% % dist_Z_1 = dist_Z_1( 1, : );
% % dist_Z_2 = dist_Z_2( 1, : );
% %
% % images = [];
% % ct = 0;
% % for n = transpose( collected_samples )
% %     ct = ct + 1;
% %     images( :, :, ct ) = transpose( reshape( X( n, : ), [ 96, 64 ] ) );
% % end; clear n ct
% %
% %
% % save( 'Final_Results_Distance.mat', 'corr_100', 'corr_4', 'corr_2', 'corr_1', 'ratio_traj2min', 'discr_50', 'discr_10', 'discr_1', 'pseudo_discr_50', 'pseudo_discr_10', 'pseudo_discr_1', 'collected_samples', 'dist_X', 'dist_Z_1', 'dist_Z_2', 'images' )
% %
% %
% load( 'Final_Results_Distance.mat' )
% 
% 
% m_corr_100 = mean( corr_100, 3, 'omitnan' );
% s_corr_100 = std( corr_100, 0, 3, 'omitnan' );
% m_corr_4 = mean( corr_4, 3, 'omitnan' );
% s_corr_4 = std( corr_4, 0, 3, 'omitnan' );
% m_corr_2 = mean( corr_2, 3, 'omitnan' );
% s_corr_2 = std( corr_2, 0, 3, 'omitnan' );
% m_corr_1 = mean( corr_1, 3, 'omitnan' );
% s_corr_1 = std( corr_1, 0, 3, 'omitnan' );
% disp( [ 'Exceptions: ', num2str( 100 * sum( sum( sum( sum( isinf( ratio_traj2min ) ) ) ) ) / prod( size( ratio_traj2min ) ) ), ' %' ] )
% ratio_traj2min( isinf( ratio_traj2min ) ) = NaN;
% m_ratio_traj2min = mean( ratio_traj2min, 3, 'omitnan' );
% s_ratio_traj2min = std( ratio_traj2min, 0, 3, 'omitnan' );
% 
% 
% % figure( 'position', [ 100, 100, 250, 200 ] )
% figure( 'position', [ 100, 100, 300, 300 ] )
% bar( [ m_corr_1( 2 : 4, : ), m_corr_2( 2 : 4, : ), m_corr_4( 2 : 4, : ) ] )
% hold on
% sw = 1.3;
% for fn = 2 : 4
%     errorbar( fn - 0.25 * sw - 1, m_corr_1( fn, 1 ), s_corr_1( fn, 1 ), 'k' )
%     errorbar( fn - 0.15 * sw - 1, m_corr_1( fn, 2 ), s_corr_1( fn, 2 ), 'k' )
%     errorbar( fn - 0.05 * sw - 1, m_corr_2( fn, 1 ), s_corr_2( fn, 1 ), 'k' )
%     errorbar( fn + 0.05 * sw - 1, m_corr_2( fn, 2 ), s_corr_2( fn, 2 ), 'k' )
%     errorbar( fn + 0.15 * sw - 1, m_corr_4( fn, 1 ), s_corr_4( fn, 1 ), 'k' )
%     errorbar( fn + 0.25 * sw - 1, m_corr_4( fn, 2 ), s_corr_4( fn, 2 ), 'k' )
% end; clear fn
% clear sw
% set( gca, 'ylim', [ 0, 1 ] )
% set( gca, 'xtick', [ 1 : 3 ], 'xticklabel', { 'STEC', 'SEC', 'Sparse' } )
% ylabel( 'Correlation over distances' )
% legend( 'Lower hierarchy (1%)', 'Upper hierarchy (1%)', 'Lower hierarchy (2%)', 'Upper hierarchy (2%)', 'Lower hierarchy (4%)', 'Upper hierarchy (4%)', 'location', 'southwest' )
% title( 'Local similarity' )
% % title( 'Top 1 % neighbour samples (N = 42)' )
% 
% 
% colors = [ 1, 0, 0; 0, 1, 0; 0, 0, 1 ];
% figure( 'position', [ 100, 100, 600, 180 ] )
% for h = 1 : 2
%     subplot( 1, 2, h )
%     hold on
%     for fn = 2 : 4
%         errorbar( [ 1 : 9 ] + 0.2 * ( fn - 3 ), permute( m_ratio_traj2min( fn, h, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ), permute( s_ratio_traj2min( fn, h, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ), 'color', colors( fn - 1, : ) )
%     end; clear fn
%     plot( [ 0.5, 9 + 0.5 ], [ 1, 1 ], ':k' )
%     set( gca, 'xlim', [ 0.5, 9 + 0.5 ], 'ylim', [ 0, 2 ] )
%     xlabel( 'Time (step)' )
%     if h == 1
%         ylabel( 'Confusion index' )
%         title( 'Lower hierarchy' )
%         legend( 'STEC', 'SEC', 'Sparse', 'location', 'southeast' )
%     elseif h == 2
%         title( 'Upper hierarchy' )
%     end
% end; clear h
% 
% 
% N_division = 4;
% re_dist_X = ( dist_X - min( dist_X( 2 : end ) ) ) / ( max( dist_X( 2 : end ) ) - min( dist_X( 2 : end ) ) );
% re_dist_X = re_dist_X * ( ( N_division - 1 ) / N_division );
% re_dist_Z_1 = ( dist_Z_1 - min( dist_Z_1( 2 : end ) ) ) / ( max( dist_Z_1( 2 : end ) ) - min( dist_Z_1( 2 : end ) ) );
% re_dist_Z_1 = re_dist_Z_1 * ( ( N_division - 1 ) / N_division );
% re_dist_Z_2 = ( dist_Z_2 - min( dist_Z_2( 2 : end ) ) ) / ( max( dist_Z_2( 2 : end ) ) - min( dist_Z_2( 2 : end ) ) );
% re_dist_Z_2 = re_dist_Z_2 * ( ( N_division - 1 ) / N_division );
% 
% figure( 'position', [ 100, 100, 300, 200 ] )
% imagesc( images( :, :, 1 ), [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% 
% figure( 'position', [ 100, 100, 300, 200 ] )
% for n = 2 : length( collected_samples )
%     axes( 'position', [ re_dist_X( n ), re_dist_Z_1( n ), 1 / N_division, 1 / N_division ] )
%     imagesc( images( :, :, n ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
% end; clear n
% 
% figure( 'position', [ 100, 100, 300, 200 ] )
% for n = 2 : length( collected_samples )
%     axes( 'position', [ re_dist_X( n ), re_dist_Z_2( n ), 1 / N_division, 1 / N_division ] )
%     imagesc( images( :, :, n ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
% end; clear n
% 
% 
% stat_discr_1 = [];
% for fn = 1 : 4
%     sort_data = sort( squeeze( discr_1( fn, 1, : ) ) );
%     sort_data = sort_data( round( linspace( 1, length( sort_data ), 5 ) ) );
%     sort_data = sort_data( 2 : 4 );
%     stat_discr_1( fn, 1, : ) = sort_data;
%     clear sort_data
%     sort_data = sort( squeeze( discr_1( fn, 2, : ) ) );
%     sort_data = sort_data( round( linspace( 1, length( sort_data ), 5 ) ) );
%     sort_data = sort_data( 2 : 4 );
%     stat_discr_1( fn, 2, : ) = sort_data;
%     clear sort_data
% end; clear fn
% sort_data = sort( squeeze( pseudo_discr_1 ) );
% sort_data = sort_data( round( linspace( 1, length( sort_data ), 5 ) ) );
% sort_data = sort_data( 2 : 4 );
% stat_pseudo_discr_1 = [];
% stat_pseudo_discr_1( 1, 1, : ) = sort_data;
% clear sort_data
% 
% lw = 1;
% bw = 0.1;
% sw = 0.3;
% figure( 'position', [ 100, 100, 300, 300 ] )
% hold on
% h1 = plot( [ 0, 1 ], [ 0, 1 ], '-' );
% h2 = plot( [ 0, 1 ], [ 0, 1 ], '-' );
% colors = [ h1.Color; h2.Color ];
% clear h1 h2
% clf
% hold on
% plot( [ 0, 0 ], [ 0, 0 ], '-', 'color', colors( 1, : ), 'linewidth', lw )
% plot( [ 0, 0 ], [ 0, 0 ], '-', 'color', colors( 2, : ), 'linewidth', lw )
% for fn = 2 : 4
%     for h = 1 : 2
%         for s = 1 : 3
%             plot( fn - 1 + sw * ( h - 1.5 ) + bw * [ -1, 1 ], stat_discr_1( fn, h, s ) * [ 1, 1 ], '-', 'color', colors( h, : ), 'linewidth', lw )
%         end; clear s
%         plot( fn - 1 + sw * ( h - 1.5 ) + bw * [ -1, -1 ], [ stat_discr_1( fn, h, 1 ), stat_discr_1( fn, h, 3 ) ], '-', 'color', colors( h, : ), 'linewidth', lw )
%         plot( fn - 1 + sw * ( h - 1.5 ) + bw * [ 1, 1 ], [ stat_discr_1( fn, h, 1 ), stat_discr_1( fn, h, 3 ) ], '-', 'color', colors( h, : ), 'linewidth', lw )
%     end; clear h
% end; clear fn
% for s = 1 : 3
%     plot( 4 + bw * [ -1, 1 ], stat_pseudo_discr_1( 1, 1, s ) * [ 1, 1 ], '-k', 'linewidth', lw )
% end; clear s
% plot( 4 + bw * [ -1, -1 ], [ stat_pseudo_discr_1( 1, 1, 1 ), stat_pseudo_discr_1( 1, 1, 3 ) ], '-k', 'linewidth', lw )
% plot( 4 + bw * [ 1, 1 ], [ stat_pseudo_discr_1( 1, 1, 1 ), stat_pseudo_discr_1( 1, 1, 3 ) ], '-k', 'linewidth', lw )
% set( gca, 'xlim', [ 0.5, 4.5 ], 'ylim', [ 0.987, 0.9945 ] )
% set( gca, 'xtick', [ 1 : 4 ], 'xticklabel', { 'STEC', 'SEC', 'Sparse', 'Random' } )
% ylabel( 'Performance' )
% legend( 'Lower hierarchy', 'Upper hierarchy', 'location', 'southwest' )
% title( 'Discriminability' )
% clear bw sw
% 
% % figure
% % for fn = 2 : 4
% %     subplot( 1, 4, fn - 1 )
% %     hold on
% %     plot( sort( squeeze( discr_1( fn, 1, : ) ) ) )
% %     plot( sort( squeeze( discr_1( fn, 2, : ) ) ) )
% %     plot( sort( pseudo_discr_1 ), 'k' )
% % end; clear fn
% 

%% Conditional Entropy
% %
% % nH = size( io_f, 1 );
% % nZ = [];
% % for h = 1 : size( io_f, 1 )
% %     totalZ = [];
% %     for p = 1 : size( io_f{ h, 1 }, 1 )
% %         totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
% %     end; clear p
% %     nZ( h, 1 ) = length( unique( totalZ ) );
% %     clear totalZ
% % end; clear h
% %
% % kWidth = nan( nH, 1 );
% % for h = 1 : nH
% %     kWidth( h, 1 ) = 0.1 * sqrt( nZ( h ) );
% % end; clear h
% %
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % Nlog = [];% negative logarithm
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     nPred = 5 * nPred;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     for n = 1 : size( X, 1 )
% %
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %
% %         for t = 1 : 5
% %
% %             Z1 = {};
% %             for h = 1 : nH
% %                 Z1{ h, 1 } = Z{ h, 1 }( ( t - 1 ) * ( 2 * size( io_f, 1 ) + 1 ) + [ 1 : 2 * size( io_f, 1 ) + 1 ], : );
% %             end
% %
% %             d_Z = {};
% %             ds_Z = {};
% %             dsk_Z = {};
% %             for h = 1 : nH
% %                 d_Z{ h, 1 } = bsxfun( @minus, Z1{ h, 1 }, permute( Z1{ h, 1 }, [ 3, 2, 1 ] ) );
% %                 ds_Z{ h, 1 } = permute( sqrt( sum( d_Z{ h, 1 } .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %                 dsk_Z{ h, 1 } = normpdf( ds_Z{ h, 1 }, 0, kWidth( h ) );
% %                 dsk_Z{ h, 1 }( logical( eye( 2 * size( io_f, 1 ) + 1 ) ) ) = NaN;
% %             end; clear h
% %
% %             for h = 1 : nH
% %                 Nlog( t, h, n, fn ) = mean( log( mean( dsk_Z{ h, 1 }, 2, 'omitnan' ) ), 1 );
% %             end; clear h
% %
% %         end; clear t
% %
% %     end; clear n
% %
% %     clear Z1 d_Z ds_Z dsk_Z
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %
% %     disp( num2str( fn ) )
% %
% % end; clear fn
% %
% %
% % save( 'Final_Results_Conditional_Entropy.mat', 'Nlog' )
%
%
% load( 'Final_Results_Conditional_Entropy.mat' )
% 
% 
% colors = [ 1, 0, 0; 0, 1, 0; 0, 0, 1 ];
% figure( 'position', [ 100, 100, 600, 180 ] )
% for h = 1 : 2
%     subplot( 1, 2, h )
%     hold on
%     for fn = 2 : 4
%         mCH = -mean( Nlog( :, h, :, fn ), 3 );
%         plot( 0.2 * ( fn - 3 ) + [ 5 : 5 : 25 ], mCH, '-<', 'color', colors( fn - 1, : ) )
%     end; clear fn
%     set( gca, 'xlim', [ 0.5, 25 + 0.5 ], 'ylim', [ 0, 11 ] )
%     xlabel( 'Time (step)' )
%     if h == 1
%         ylabel( 'Neuronal noise' )
%         title( 'Lower hierarchy' )
%         legend( 'STEC', 'SEC', 'Sparse', 'location', 'northeast' )
%     elseif h == 2
%         title( 'Upper hierarchy' )
%     end
% end; clear h
% clear mCH
% 

%% Decoding
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% % 
% % 
% % DC = [];% Cetainty
% % DA = [];% Accuracy
% % 
% % for fn = 1 : 4
% %     
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %     
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %     
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     nPred = 2 * nPred + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %     
% %     Z_1 = [];
% %     Z_2 = [];
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_1( :, :, n ) = Z{ 1, 1 };
% %         Z_2( :, :, n ) = Z{ 2, 1 };
% %     end; clear n
% %     
% %     
% %     for n = 1 : size( X, 1 )
% %         d = sqrt( sum( bsxfun( @minus, Z_1( :, :, n ), Z_1( end - 1, :, : ) ) .^ 2, 2 ) );
% %         s = bsxfun( @rdivide, exp( 1 ./ d ), sum( exp( 1 ./ d ), 3 ) );
% %         DC( :, n, 1, fn ) = s( 1 : nPred - 2, :, n );
% %         d = sqrt( sum( bsxfun( @minus, Z_2( :, :, n ), Z_2( end - 1, :, : ) ) .^ 2, 2 ) );
% %         s = bsxfun( @rdivide, exp( 1 ./ d ), sum( exp( 1 ./ d ), 3 ) );
% %         DC( :, n, 2, fn ) = s( 1 : nPred - 2, :, n );
% %     end; clear n
% %     clear d s
% %     
% %     
% %     data_tr = [ permute( Z_1( end, :, : ), [ 3, 2, 1 ] ); permute( Z_1( end - 1, :, : ), [ 3, 2, 1 ] ) ];
% %     idx_tr = [ transpose( [ 1 : size( X, 1 ) ] ); transpose( [ 1 : size( X, 1 ) ] ) ];
% %     data_te = [];
% %     idx_te = [];
% %     for n = 1 : size( X, 1 )
% %         data_te( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], : ) = Z_1( [ 1 : nPred - 2 ], :, n );
% %         idx_te( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], 1 ) = n * ones( nPred - 2, 1 );
% %     end; clear n
% %     try
% %         data_tr = data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) );
% %         Mdl = fitcnb( data_tr, idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = idx_out == idx_te;
% %     catch
% %         acc = NaN( length( idx_te ), 1 );
% %         disp( [ 'P', num2str( fn ), '_Z1 Naive Bayes fail.' ] )
% %     end
% %     for n = 1 : size( X, 1 )
% %         DA( :, n, 1, fn ) = acc( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], 1 );
% %     end; clear n
% %     
% %     data_tr = [ permute( Z_2( end, :, : ), [ 3, 2, 1 ] ); permute( Z_2( end - 1, :, : ), [ 3, 2, 1 ] ) ];
% %     idx_tr = [ transpose( [ 1 : size( X, 1 ) ] ); transpose( [ 1 : size( X, 1 ) ] ) ];
% %     data_te = [];
% %     idx_te = [];
% %     for n = 1 : size( X, 1 )
% %         data_te( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], : ) = Z_2( [ 1 : nPred - 2 ], :, n );
% %         idx_te( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], 1 ) = n * ones( nPred - 2, 1 );
% %     end; clear n
% %     try
% %         data_tr = data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) );
% %         Mdl = fitcnb( data_tr, idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = idx_out == idx_te;
% %     catch
% %         acc = NaN( length( idx_te ), 1 );
% %         disp( [ 'P', num2str( fn ), '_Z2 Naive Bayes fail.' ] )
% %     end
% %     for n = 1 : size( X, 1 )
% %         DA( :, n, 2, fn ) = acc( ( n - 1 ) * ( nPred - 2 ) + [ 1 : nPred - 2 ], 1 );
% %     end; clear n
% %     
% %     clear data_tr idx_tr data_te idx_te idx_out Mdl acc
% %     
% %     
% %     clear Z_1 Z_2
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %     
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %     
% %     disp( num2str( fn ) )
% %     
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Decoding.mat', 'DC', 'DA' )
% %
% %
% load( 'Final_Results_Decoding.mat' )
% 
% 
% colors = [ 1, 0, 0; 0, 1, 0; 0, 0, 1 ];
% figure( 'position', [ 100, 100, 600, 180 ] )
% for h = 1 : 2
%     subplot( 1, 2, h )
%     hold on
%     for fn = 2 : 4
%         mDA = mean( DA( :, :, h, fn ), 2 );
%         sDA = std( DA( :, :, h, fn ), 0, 2 );
%         % errorbar( 0.2 * ( fn - 3 ) + [ 1 : 9 ], mDA, sDA, 'color', colors( fn - 1, : ) )
%         plot( 0.2 * ( fn - 3 ) + [ 1 : 9 ], mDA, 'color', colors( fn - 1, : ) )
%     end; clear fn
%     plot( [ 0, 10 ], ( 1 / 4212 ) * [ 1, 1 ], ':k' )
%     plot( [ 0, 10 ], [ 1, 1 ], ':k' )
%     set( gca, 'xlim', [ 0.5, 9 + 0.5 ], 'ylim', [ -0.2, 1 + 0.2 ] )
%     xlabel( 'Time (step)' )
%     if h == 1
%         ylabel( 'Decoding accuracy' )
%         title( 'Lower hierarchy' )
%     elseif h == 2
%         title( 'Upper hierarchy' )
%         legend( 'STEC', 'SEC', 'Sparse', 'location', 'northwest' )
%     end
% end; clear h
% clear mDA sDA
% 

%% MNIST16_dataset
%
% load( 'MNIST.mat' )
% X = permute( reshape( imgs, [ 400, 60000 ] ), [ 2, 1 ] );
% clear imgs imgs_t labels labels_t
%
% [ grid1, grid2 ] = meshgrid( linspace( 1, 20, 64 ), linspace( 1, 20, 96 ) );
% grid1 = round( grid1 );
% grid2 = round( grid2 );
%
% Y = NaN( 60000, 96 * 64 );
% for n = 1 : 60000
%     tX = X( n, : );
%     Y( n, : ) = tX( sub2ind( [ 20, 20 ], grid1( : ), grid2( : ) ) );
%     clear tX
% end; clear n
%
% Y = single( Y );
%
% save( 'MNIST16_dataset.mat', 'Y' )
% clear X grid1 grid2 Y
%

%% Learned & Unlearned
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'MNIST16_dataset.mat' )
% % Y = double( Y( 1 : 4212, : ) );
% %
% %
% % hist_X = {};
% % hist_Y = {};
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     nBins = 10;
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     hist_X{ 1, fn } = zeros( nPred, nBins );
% %     hist_X{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_X{ 1, fn }( t, : ) = hist_X{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_X{ 2, fn }( t, : ) = hist_X{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     hist_Y{ 1, fn } = zeros( nPred, nBins );
% %     hist_Y{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( Y, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_Y{ 1, fn }( t, : ) = hist_Y{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_Y{ 2, fn }( t, : ) = hist_Y{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %     clear nBins
% %
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %
% %     disp( [ num2str( fn ) ] )
% %
% % end; clear fn
% %
% %
% % n_hist_X = {};
% % n_hist_Y = {};
% % for fn = 1 : 3
% %     n_hist_X{ 1, fn } = bsxfun( @rdivide, hist_X{ 1, fn }, sum( hist_X{ 1, fn }, 2 ) );
% %     n_hist_X{ 2, fn } = bsxfun( @rdivide, hist_X{ 2, fn }, sum( hist_X{ 2, fn }, 2 ) );
% %     n_hist_Y{ 1, fn } = bsxfun( @rdivide, hist_Y{ 1, fn }, sum( hist_Y{ 1, fn }, 2 ) );
% %     n_hist_Y{ 2, fn } = bsxfun( @rdivide, hist_Y{ 2, fn }, sum( hist_Y{ 2, fn }, 2 ) );
% % end; clear fn
% %
% %
% % img_X = [];
% % img_Y = [];
% % for n = [ 5, 7, 9, 10 ]
% %     img_X = [ img_X; transpose( reshape( X( n, : ), [ 96, 64 ] ) ) ];
% %     img_Y = [ img_Y; transpose( reshape( Y( n, : ), [ 96, 64 ] ) ) ];
% % end; clear n ct_n
% %
% %
% % hist_inv_X = {};
% % hist_inv_Y = {};
% %
% % for fn = 1
% %
% %     load( 'Results_MNIST_lambda10.mat' )
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     nBins = 10;
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     hist_inv_X{ 1, fn } = zeros( nPred, nBins );
% %     hist_inv_X{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_inv_X{ 1, fn }( t, : ) = hist_inv_X{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_inv_X{ 2, fn }( t, : ) = hist_inv_X{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     hist_inv_Y{ 1, fn } = zeros( nPred, nBins );
% %     hist_inv_Y{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( Y, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_inv_Y{ 1, fn }( t, : ) = hist_inv_Y{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_inv_Y{ 2, fn }( t, : ) = hist_inv_Y{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %     clear nBins
% %
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %
% %     disp( [ 'inv' ] )
% %
% % end; clear fn
% %
% %
% % n_hist_inv_X = {};
% % n_hist_inv_Y = {};
% % for fn = 1
% %     n_hist_inv_X{ 1, fn } = bsxfun( @rdivide, hist_inv_X{ 1, fn }, sum( hist_inv_X{ 1, fn }, 2 ) );
% %     n_hist_inv_X{ 2, fn } = bsxfun( @rdivide, hist_inv_X{ 2, fn }, sum( hist_inv_X{ 2, fn }, 2 ) );
% %     n_hist_inv_Y{ 1, fn } = bsxfun( @rdivide, hist_inv_Y{ 1, fn }, sum( hist_inv_Y{ 1, fn }, 2 ) );
% %     n_hist_inv_Y{ 2, fn } = bsxfun( @rdivide, hist_inv_Y{ 2, fn }, sum( hist_inv_Y{ 2, fn }, 2 ) );
% % end; clear fn
% %
% %
% % save( 'Final_Results_Learned_Unlearned.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y', 'hist_inv_X', 'hist_inv_Y', 'n_hist_inv_X', 'n_hist_inv_Y' )
% %
% %
% % load( 'Final_Results_Learned_Unlearned.mat' )
% %
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'MNIST16_dataset.mat' )
% % Y = double( Y( 1 : 4212, : ) );
% %
% %
% % fn = 2;
% %
% % if fn == 1
% %     load( 'Results_lambda0.mat' )
% % elseif fn == 2
% %     load( 'Results_lambda10.mat' )
% % elseif fn == 3
% %     load( 'Results_lambda1000.mat' )
% % elseif fn == 4
% %     load( 'Results_Sparse_lambda1000.mat' )
% % end
% %
% % iter = 1;
% % W_f = results{ iter, 1 };
% % b_f = results{ iter, 2 };
% %
% %
% % nBins = 10;
% %
% % nPred = 2 * size( io_f, 1 ) + 1;
% % rX = {};
% % for h = 1 : size( io_f, 1 )
% %     rX{ h, 1 } = zeros( 1, nZ( h ) );
% % end; clear h
% %
% % test_hist_X{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_X{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_X{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_X{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % test_hist_Y{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_Y{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_Y{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_Y{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % clear Z E
% % clear sX rX
% % clear nPred
% % clear nBins
% %
% % clear W_f b_f
% % clear iter
% % clear results
% %
% % clear fn
% %
% %
% % n_test_hist_X = {};
% % n_test_hist_Y = {};
% % n_test_hist_X{ 1, 1 } = bsxfun( @rdivide, test_hist_X{ 1, 1 }, sum( test_hist_X{ 1, 1 }, 2 ) );
% % n_test_hist_X{ 2, 1 } = bsxfun( @rdivide, test_hist_X{ 2, 1 }, sum( test_hist_X{ 2, 1 }, 2 ) );
% % n_test_hist_Y{ 1, 1 } = bsxfun( @rdivide, test_hist_Y{ 1, 1 }, sum( test_hist_Y{ 1, 1 }, 2 ) );
% % n_test_hist_Y{ 2, 1 } = bsxfun( @rdivide, test_hist_Y{ 2, 1 }, sum( test_hist_Y{ 2, 1 }, 2 ) );
% %
% %
% % load( 'Results_MNIST_lambda10.mat' )
% %
% % iter = 1;
% % W_f = results{ iter, 1 };
% % b_f = results{ iter, 2 };
% %
% %
% % nBins = 10;
% %
% % nPred = 2 * size( io_f, 1 ) + 1;
% % rX = {};
% % for h = 1 : size( io_f, 1 )
% %     rX{ h, 1 } = zeros( 1, nZ( h ) );
% % end; clear h
% %
% % test_hist_inv_X{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_inv_X{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_inv_X{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_inv_X{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % test_hist_inv_Y{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_inv_Y{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_inv_Y{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_inv_Y{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % clear Z E
% % clear sX rX
% % clear nPred
% % clear nBins
% %
% % clear W_f b_f
% % clear iter
% % clear results
% %
% %
% % n_test_hist_inv_X = {};
% % n_test_hist_inv_Y = {};
% % n_test_hist_inv_X{ 1, 1 } = bsxfun( @rdivide, test_hist_inv_X{ 1, 1 }, sum( test_hist_inv_X{ 1, 1 }, 2 ) );
% % n_test_hist_inv_X{ 2, 1 } = bsxfun( @rdivide, test_hist_inv_X{ 2, 1 }, sum( test_hist_inv_X{ 2, 1 }, 2 ) );
% % n_test_hist_inv_Y{ 1, 1 } = bsxfun( @rdivide, test_hist_inv_Y{ 1, 1 }, sum( test_hist_inv_Y{ 1, 1 }, 2 ) );
% % n_test_hist_inv_Y{ 2, 1 } = bsxfun( @rdivide, test_hist_inv_Y{ 2, 1 }, sum( test_hist_inv_Y{ 2, 1 }, 2 ) );
% %
% %
% % save( 'Final_Results_Learned_Unlearned.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y', 'hist_inv_X', 'hist_inv_Y', 'n_hist_inv_X', 'n_hist_inv_Y', 'test_hist_X', 'test_hist_Y', 'n_test_hist_X', 'n_test_hist_Y', 'test_hist_inv_X', 'test_hist_inv_Y', 'n_test_hist_inv_X', 'n_test_hist_inv_Y' )
% %
% %
% load( 'Final_Results_Learned_Unlearned.mat' )
%
%
% figure( 'position', [  100, 100, 350, 350 ] )
% subplot( 1, 2, 1 )
% imagesc( img_X, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Learned' )
% subplot( 1, 2, 2 )
% imagesc( img_Y, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Unlearned' )
%
%
% figure( 'position', [ 100, 100, 350, 350 ] )
% for n = 1 : 4
%     subplot( 4, 2, ( n - 1 ) * 2 + 1 )
%     imagesc( transpose( n_test_hist_X{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_X{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_X{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Learned' )
%     end
%     subplot( 4, 2, ( n - 1 ) * 2 + 2 )
%     imagesc( transpose( n_test_hist_Y{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_Y{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_Y{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Unlearned' )
%     end
% end; clear n
%
%
% figure( 'position', [ 100, 100, 350, 300 ] )
% fn = 2;
%
% subplot( 2, 2, 1 )
% imagesc( transpose( n_hist_X{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Learned' ] )
%
% subplot( 2, 2, 2 )
% imagesc( transpose( n_hist_Y{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Unlearned' ] )
%
% subplot( 2, 2, 3 )
% imagesc( transpose( n_hist_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Learned' ] )
%
% subplot( 2, 2, 4 )
% imagesc( transpose( n_hist_Y{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Unlearned' ] )
%
% clear fn
%
%
% figure( 'position', [  100, 100, 350, 350 ] )
% subplot( 1, 2, 1 )
% imagesc( img_Y, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Learned' )
% subplot( 1, 2, 2 )
% imagesc( img_X, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Unlearned' )
%
%
% figure( 'position', [ 100, 100, 350, 350 ] )
% for n = 1 : 4
%     subplot( 4, 2, ( n - 1 ) * 2 + 1 )
%     imagesc( transpose( n_test_hist_inv_Y{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_inv_Y{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_inv_Y{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Learned' )
%     end
%     subplot( 4, 2, ( n - 1 ) * 2 + 2 )
%     imagesc( transpose( n_test_hist_inv_X{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_inv_X{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_inv_X{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Unlearned' )
%     end
% end; clear n
%
%
% figure( 'position', [ 100, 100, 350, 300 ] )
% fn = 1;
%
% subplot( 2, 2, 1 )
% imagesc( transpose( n_hist_inv_Y{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_inv_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_inv_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Learned' ] )
%
% subplot( 2, 2, 2 )
% imagesc( transpose( n_hist_inv_X{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_inv_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_inv_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Unlearned' ] )
%
% subplot( 2, 2, 3 )
% imagesc( transpose( n_hist_inv_Y{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_inv_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_inv_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Learned' ] )
%
% subplot( 2, 2, 4 )
% imagesc( transpose( n_hist_inv_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_inv_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_inv_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Unlearned' ] )
%
% clear fn
%

%% Learned & Unlearned - Sparse
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'MNIST16_dataset.mat' )
% % Y = double( Y( 1 : 4212, : ) );
% %
% %
% % fname = 'Results_Sparse_lambda5.mat';
% %
% %
% % hist_X = {};
% % hist_Y = {};
% %
% % for fn = 1
% %
% %     if fn == 1
% %         load( fname )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     nBins = 10;
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     hist_X{ 1, fn } = zeros( nPred, nBins );
% %     hist_X{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_X{ 1, fn }( t, : ) = hist_X{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_X{ 2, fn }( t, : ) = hist_X{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     hist_Y{ 1, fn } = zeros( nPred, nBins );
% %     hist_Y{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( Y, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             hist_Y{ 1, fn }( t, : ) = hist_Y{ 1, fn }( t, : ) + histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             hist_Y{ 2, fn }( t, : ) = hist_Y{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     clear Z E
% %     clear sX rX
% %     clear nPred
% %     clear nBins
% %
% %     clear W_f b_f
% %     clear iter
% %     clear results
% %
% %     disp( [ num2str( fn ) ] )
% %
% % end; clear fn
% %
% %
% % n_hist_X = {};
% % n_hist_Y = {};
% % for fn = 1
% %     n_hist_X{ 1, fn } = bsxfun( @rdivide, hist_X{ 1, fn }, sum( hist_X{ 1, fn }, 2 ) );
% %     n_hist_X{ 2, fn } = bsxfun( @rdivide, hist_X{ 2, fn }, sum( hist_X{ 2, fn }, 2 ) );
% %     n_hist_Y{ 1, fn } = bsxfun( @rdivide, hist_Y{ 1, fn }, sum( hist_Y{ 1, fn }, 2 ) );
% %     n_hist_Y{ 2, fn } = bsxfun( @rdivide, hist_Y{ 2, fn }, sum( hist_Y{ 2, fn }, 2 ) );
% % end; clear fn
% %
% %
% % img_X = [];
% % img_Y = [];
% % for n = [ 5, 7, 9, 10 ]
% %     img_X = [ img_X; transpose( reshape( X( n, : ), [ 96, 64 ] ) ) ];
% %     img_Y = [ img_Y; transpose( reshape( Y( n, : ), [ 96, 64 ] ) ) ];
% % end; clear n ct_n
% %
% %
% % save( 'Final_Results_Learned_Unlearned_Sparse.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y' )
% %
% %
% % load( 'Final_Results_Learned_Unlearned_Sparse.mat' )
% %
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'MNIST16_dataset.mat' )
% % Y = double( Y( 1 : 4212, : ) );
% %
% %
% % fn = 1;
% %
% % if fn == 1
% %     load( fname )
% % end
% %
% % iter = 1;
% % W_f = results{ iter, 1 };
% % b_f = results{ iter, 2 };
% %
% %
% % nBins = 10;
% %
% % nPred = 2 * size( io_f, 1 ) + 1;
% % rX = {};
% % for h = 1 : size( io_f, 1 )
% %     rX{ h, 1 } = zeros( 1, nZ( h ) );
% % end; clear h
% %
% % test_hist_X{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_X{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_X{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_X{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % test_hist_Y{ 1, 1 } = nan( nPred, nBins, 4 );
% % test_hist_Y{ 2, 1 } = nan( nPred, nBins, 4 );
% % ct = 0;
% % for n = [ 5, 7, 9, 10 ]
% %     ct = ct + 1;
% %     sX = [];
% %     sX( :, :, [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     for t = 1 : nPred
% %         test_hist_Y{ 1, 1 }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         test_hist_Y{ 2, 1 }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %     end; clear t
% % end; clear n
% %
% % clear Z E
% % clear sX rX
% % clear nPred
% % clear nBins
% %
% % clear W_f b_f
% % clear iter
% % clear results
% %
% % clear fn
% %
% %
% % n_test_hist_X = {};
% % n_test_hist_Y = {};
% % n_test_hist_X{ 1, 1 } = bsxfun( @rdivide, test_hist_X{ 1, 1 }, sum( test_hist_X{ 1, 1 }, 2 ) );
% % n_test_hist_X{ 2, 1 } = bsxfun( @rdivide, test_hist_X{ 2, 1 }, sum( test_hist_X{ 2, 1 }, 2 ) );
% % n_test_hist_Y{ 1, 1 } = bsxfun( @rdivide, test_hist_Y{ 1, 1 }, sum( test_hist_Y{ 1, 1 }, 2 ) );
% % n_test_hist_Y{ 2, 1 } = bsxfun( @rdivide, test_hist_Y{ 2, 1 }, sum( test_hist_Y{ 2, 1 }, 2 ) );
% %
% %
% % save( 'Final_Results_Learned_Unlearned_Sparse.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y', 'test_hist_X', 'test_hist_Y', 'n_test_hist_X', 'n_test_hist_Y' )
% %
% %
% % load( 'Final_Results_Learned_Unlearned_Sparse.mat' )
% %
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'MNIST16_dataset.mat' )
% % Y = double( Y( 1 : 4212, : ) );
% %
% %
% % fn = 1;
% %
% % if fn == 1
% %     load( fname )
% % end
% %
% % iter = 1;
% % W_f = results{ iter, 1 };
% % b_f = results{ iter, 2 };
% %
% %
% % nBins = 10;
% %
% % nPred = 2 * size( io_f, 1 ) + 1;
% % rX = {};
% % for h = 1 : size( io_f, 1 )
% %     rX{ h, 1 } = zeros( 1, nZ( h ) );
% % end; clear h
% %
% % ct = 0;
% % sX = [];
% % for n = [ 5, 7, 9, 10 ]
% %     sX( :, :, ct * nPred + [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %     ct = ct + 1;
% % end; clear n ct
% % [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% % Z_X{ 1, 1 } = Z{ 1, 1 };
% % Z_X{ 2, 1 } = Z{ 2, 1 };
% %
% % ct = 0;
% % sX = [];
% % for n = [ 5, 7, 9, 10 ]
% %     sX( :, :, ct * nPred + [ 1 : nPred ] ) = repmat( Y( n, : ), [ 1, 1, nPred ] );
% %     ct = ct + 1;
% % end; clear n ct
% % [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% % Z_Y{ 1, 1 } = Z{ 1, 1 };
% % Z_Y{ 2, 1 } = Z{ 2, 1 };
% %
% % clear Z E
% % clear sX rX
% % clear nPred
% % clear nBins
% %
% % clear W_f b_f
% % clear iter
% % clear results
% %
% % clear fn
% %
% %
% % save( 'Final_Results_Learned_Unlearned_Sparse.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y', 'test_hist_X', 'test_hist_Y', 'n_test_hist_X', 'n_test_hist_Y', 'Z_X', 'Z_Y' )
%
%
% load( 'Final_Results_Learned_Unlearned_Sparse.mat' )
%
%
% figure( 'position', [  100, 100, 800, 350 ] )
% subplot( 1, 12, [ 1, 2 ] )
% imagesc( img_X, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Learned' )
% subplot( 1, 12, [ 3, 4 ] )
% imagesc( img_Y, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Unlearned' )
% subplot( 1, 12, [ 7 : 9 ] )
% imagesc( Z_X{ 1, 1 }, [ 0, 1 ] )
% colormap( gca, turbo )
% xlabel( 'Unit' )
% ylabel( 'Time (step)' )
% title( [ 'Learned, Lower hierarchy' ] )
% subplot( 1, 12, [ 10 : 12 ] )
% imagesc( Z_Y{ 1, 1 }, [ 0, 1 ] )
% colormap( gca, turbo )
% xlabel( 'Unit' )
% % ylabel( 'Time (step)' )
% title( [ 'Unlearned, Lower hierarchy' ] )
%
%
% figure( 'position', [ 100, 100, 350, 350 ] )
% for n = 1 : 4
%     subplot( 4, 2, ( n - 1 ) * 2 + 1 )
%     imagesc( transpose( n_test_hist_X{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_X{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_X{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Learned' )
%     end
%     subplot( 4, 2, ( n - 1 ) * 2 + 2 )
%     imagesc( transpose( n_test_hist_Y{ 1, 1 }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_Y{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_Y{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'Unlearned' )
%     end
% end; clear n
%
%
% figure( 'position', [ 100, 100, 350, 300 ] )
% fn = 1;
%
% subplot( 2, 2, 1 )
% imagesc( transpose( n_hist_X{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Learned' ] )
%
% subplot( 2, 2, 2 )
% imagesc( transpose( n_hist_Y{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Lower hierarchy, Unlearned' ] )
%
% subplot( 2, 2, 3 )
% imagesc( transpose( n_hist_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Learned' ] )
%
% subplot( 2, 2, 4 )
% imagesc( transpose( n_hist_Y{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'Upper hierarchy, Unlearned' ] )
%
% clear fn
%

%% Homeostasis
% %
% % load( 'vanHateren16_dataset.mat' )
% % X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
% % X( X > 2000 ) = 2000;
% % X( X < 0 ) = 0;
% % X = X / 2000;
% % clear data
% %
% %
% % load( 'Final_Results_Learned_Unlearned.mat' )
% %
% %
% % test_hist_Xs = {};
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     nBins = 10;
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %
% %     test_hist_Xs{ 1, fn } = nan( nPred, nBins, 4 );
% %     test_hist_Xs{ 2, fn } = nan( nPred, nBins, 4 );
% %     ct = 0;
% %     for n = [ 5, 7, 9, 10 ]
% %         ct = ct + 1;
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             test_hist_Xs{ 1, fn }( t, :, ct ) = histcounts( Z{ 1, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %             test_hist_Xs{ 2, fn }( t, :, ct ) = histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% % end; clear fn
% %
% %
% % n_test_hist_Xs = {};
% % for fn = 1 : 4
% %     n_test_hist_Xs{ 1, fn } = bsxfun( @rdivide, test_hist_Xs{ 1, fn }, sum( test_hist_Xs{ 1, fn }, 2 ) );
% %     n_test_hist_Xs{ 2, fn } = bsxfun( @rdivide, test_hist_Xs{ 2, fn }, sum( test_hist_Xs{ 2, fn }, 2 ) );
% % end; clear fn
% %
% %
% % save( 'Final_Results_Homeostasis.mat', 'hist_X', 'n_hist_X', 'img_X', 'test_hist_Xs', 'n_test_hist_Xs' )
%
%
% load( 'Final_Results_Homeostasis.mat' )
% 
% 
% figure( 'position', [  100, 100, 200, 350 ] )
% imagesc( img_X, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% axis image
% 
% 
% figure( 'position', [ 100, 100, 350, 350 ] )
% for n = 1 : 4
%     subplot( 4, 2, ( n - 1 ) * 2 + 1 )
%     fn = 2;
%     imagesc( transpose( n_test_hist_Xs{ 1, fn }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_Xs{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_Xs{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'STEC; Lower hierarchy' )
%     end
%     subplot( 4, 2, ( n - 1 ) * 2 + 2 )
%     fn = 3;
%     imagesc( transpose( n_test_hist_Xs{ 1, fn }( :, :, n ) ), [ 0, 0.2 ] )
%     colormap( gca, parula )
%     colorbar
%     axis xy
%     set( gca, 'ytick', [ 0.5, size( n_test_hist_Xs{ 1, 1 }, 2 ) / 2 + 0.5, size( n_test_hist_Xs{ 1, 1 }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
%     ylabel( 'Response' )
%     if n == 4
%         xlabel( 'Time (step)' )
%     end
%     if n == 1
%         title( 'SEC; Lower hierarchy' )
%     end
%     clear fn
% end; clear n
% 
% 
% figure( 'position', [ 100, 100, 350, 300 ] )
% 
% subplot( 2, 2, 1 )
% fn = 2;
% imagesc( transpose( n_hist_X{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'STEC; Lower hierarchy' ] )
% 
% subplot( 2, 2, 2 )
% fn = 3;
% imagesc( transpose( n_hist_X{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'SEC; Lower hierarchy' ] )
% 
% subplot( 2, 2, 3 )
% fn = 2;
% imagesc( transpose( n_hist_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'STEC; Upper hierarchy' ] )
% 
% subplot( 2, 2, 4 )
% fn = 3;
% imagesc( transpose( n_hist_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (step)' )
% % title( [ 'SEC; Upper hierarchy' ] )
% 
% clear fn
% 

%% Cardinal rule for simple cell receptive field
% %
% % % clear all; close all; clc
% %
% %
% % bar_img = {};
% % bar_width = 0.1;
% % ct_theta = 0;
% % for bar_theta = pi * [ 0 : 0.125 : 0.875 ]
% %     ct_theta = ct_theta + 1;
% %     bar_img{ ct_theta, 1 } = [];
% %     ct_shift = 0;
% %     for bar_shift = -3 : 0.1 : 3
% %         ct_shift = ct_shift + 1;
% %
% %         img = zeros( 96, 64 );
% %         [ X_grid, Y_grid ] = meshgrid( linspace( -2, 2, 64 ), linspace( -3, 3, 96 ) );
% %         XY_grid = [];
% %         XY_grid( :, :, 1 ) = X_grid;
% %         XY_grid( :, :, 2 ) = Y_grid;
% %         XY_grid = reshape( XY_grid, [ 96 * 64, 2 ] );
% %         XY_grid = [ cos( bar_theta ), -sin( bar_theta ); sin( bar_theta ), cos( bar_theta ) ] * transpose( XY_grid );
% %         XY_grid = transpose( XY_grid );
% %         XY_grid = reshape( XY_grid, [ 96, 64, 2 ] );
% %         img( XY_grid( :, :, 2 ) > -bar_width - bar_shift & XY_grid( :, :, 2 ) < bar_width - bar_shift ) = 1;
% %         clear X_grid Y_grid XY_grid
% %
% %         bar_img{ ct_theta, 1 }( :, :, ct_shift ) = img;
% %         clear img
% %
% %     end; clear bar_shift ct_shift
% % end; clear bar_theta ct_theta
% % clear bar_width
% %
% %
% % Z_1 = {};
% % Z_2 = {};
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( size( bar_img{ 1, 1 }, 3 ), nZ( h ) );
% %     end; clear h
% %
% %     for r = 1 : size( bar_img, 1 )
% %         sX = transpose( reshape( bar_img{ r, 1 }, [ 96 * 64, size( bar_img{ r, 1 }, 3 ) ] ) );
% %         sX = repmat( sX, [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_1{ r, fn } = [];
% %         Z_2{ r, fn } = [];
% %         for t = 1 : nPred
% %             Z_1{ r, fn }( :, :, t ) = Z{ 1, 1 }( ( t - 1 ) * size( bar_img{ 1, 1 }, 3 ) + [ 1 : size( bar_img{ 1, 1 }, 3 ) ], : );
% %             Z_2{ r, fn }( :, :, t ) = Z{ 2, 1 }( ( t - 1 ) * size( bar_img{ 1, 1 }, 3 ) + [ 1 : size( bar_img{ 1, 1 }, 3 ) ], : );
% %         end; clear t
% %         clear sX Z E
% %     end; clear r
% %
% %     clear nPred rX
% %     clear results iter W_f b_f
% %
% %     disp( [ num2str( fn ) ] )
% %
% % end; clear fn
% %
% %
% % max_Z_1 = {};
% % max_Z_2 = {};
% % for fn = 1 : 3
% %     for r = 1 : size( Z_1, 1 )
% %         for t = 1 : 2 * size( io_f, 1 ) + 1
% %             max_Z_1{ 1, fn }( r, :, t ) = max( Z_1{ r, fn }( :, :, t ), [], 1 );
% %             max_Z_2{ 1, fn }( r, :, t ) = max( Z_2{ r, fn }( :, :, t ), [], 1 );
% %         end; clear t
% %     end; clear r
% % end; clear fn
% %
% %
% % max_angle_1 = {};
% % max_angle_2 = {};
% % for fn = 1 : 3
% %     for t = 1 : 2 * size( io_f, 1 ) + 1
% %         [ ~, max_angle_1{ 1, fn }( t, : ) ] = max( max_Z_1{ 1, fn }( :, :, t ), [], 1 );
% %         [ ~, max_angle_2{ 1, fn }( t, : ) ] = max( max_Z_2{ 1, fn }( :, :, t ), [], 1 );
% %     end; clear t
% % end; clear fn
% %
% %
% % hist_angle_1 = {};
% % hist_angle_2 = {};
% % for fn = 1 : 3
% %     for t = 1 : 2 * size( io_f, 1 ) + 1
% %         hist_angle_1{ 1, fn }( t, : ) = histcounts( max_angle_1{ 1, fn }( t, : ), [ 0.5 : 1 : size( bar_img, 1 ) + 0.5 ] );
% %         hist_angle_2{ 1, fn }( t, : ) = histcounts( max_angle_2{ 1, fn }( t, : ), [ 0.5 : 1 : size( bar_img, 1 ) + 0.5 ] );
% %     end; clear t
% % end; clear fn
% %
% %
% %
% %
% % rf = {};
% %
% % for fn = 1 : 4
% %
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda1000.mat' )
% %     elseif fn == 4
% %         load( 'Results_Sparse_lambda1000.mat' )
% %     end
% %
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %
% %
% %     hw = 8;
% %     N_iter = 2000;
% %     ssX_ct = 0;
% %     while ~isempty( find( ssX_ct < 1 ) )
% %         ssX = nan( N_iter, 96 * 64 );
% %         for iter = 1 : N_iter
% %             csX = randperm( ( 96 - 2 * hw ) * ( 64 - 2 * hw ), 1 );
% %             [ coord1, coord2 ] = ind2sub( [ 96 - 2 * hw, 64 - 2 * hw ], csX );
% %             tsX = 0.5 * ones( 96, 64 );
% %             tsX( coord1 + hw + [ -hw : hw ], coord2 + hw + [ -hw : hw ] ) = 1;
% %             ssX( iter, : ) = tsX( : );
% %             clear csX coord1 coord2 tsX
% %         end; clear iter
% %         ssX_ct = [];
% %         for s = 1 : 96 * 64
% %             idx = ssX( :, s ) == 1;
% %             ssX_ct( s, 1 ) = sum( idx );
% %             clear idx
% %         end; clear s
% %     end
% %     clear ssX_ct
% %
% %
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( N_iter, nZ( h ) );
% %     end; clear h
% %
% %
% %     sX = repmat( ssX, [ 1, 1, prod( nPred, 2 ) ] );
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %     img = {};
% %     for h = 1 : size( Z, 1 )
% %         for tt = 1 : prod( nPred, 2 )
% %             img{ h, 1 }( [ 1 : N_iter ], :, tt ) = Z{ h, 1 }( N_iter * ( tt - 1 ) + [ 1 : N_iter ], : );
% %         end; clear tt
% %     end; clear h
% %     clear Z E
% %     clear sX
% %
% %
% %     for h = 1 : size( img, 1 )
% %         for tt = 1 : prod( nPred, 2 )
% %             for s = 1 : 96 * 64
% %                 idx = ssX( :, s ) == 1;
% %                 rf{ h, fn }( s, :, tt ) = mean( img{ h, 1 }( idx, :, tt ), 1 );
% %                 clear idx
% %             end; clear s
% %         end; clear tt
% %     end; clear h
% %
% %
% %     clear nPred rX
% %     clear results iter W_f b_f
% %
% %     disp( [ num2str( fn ) ] )
% %
% % end; clear fn
% %
% %
% % save( 'Final_Results_Cardinal_Rule', 'bar_img', 'Z_1', 'Z_2', 'max_Z_1', 'max_Z_2', 'max_angle_1', 'max_angle_2', 'hist_angle_1', 'hist_angle_2', 'rf' )
% %
% %
% load( 'Final_Results_Cardinal_Rule.mat' )
% 
% 
% figure( 'position', [ 100, 100, 800, 100 ] )
% ct_r = 0;
% for r = [ 5 : -1 : 1, 8 : -1 : 6 ]%1 : size( bar_img, 1 )
%     ct_r = ct_r + 1;
%     % subplot( 2, size( bar_img, 1 ) / 2, ct_r )
%     subplot( 1, size( bar_img, 1 ), ct_r )
%     t_img = transpose( bar_img{ r, 1 }( :, :, round( size( bar_img{ r, 1 }, 3 ) / 2 ) ) );
%     imagesc( t_img, [ 0, 1 ] )
%     colormap( gca, 'gray' )
%     axis image
%     set( gca, 'xtick', [], 'ytick', [] )
%     if r == 5
%         title( [ 'Orientation: 0 (rad)' ] )
%     elseif r == 1
%         title( [ 'Orientation: \pi/2 (rad)' ] )
%     end
%     clear t_img
% end; clear r
% 
% 
% t = 5;
% fn = 2;
% figure( 'position', [ 100, 100, 600, 200 ] )
% subplot( 1, 2, 1 )
% % hist_angle = hist_angle_1{ 1, fn }( t, : );
% hist_angle = [ hist_angle_1{ 1, fn }( t, 5 : -1 : 1 ), hist_angle_1{ 1, fn }( t, 8 : -1 : 6 ) ];
% bar( hist_angle, 1, 'k' )
% set( gca, 'xlim', [ 0, size( bar_img, 1 ) + 1 ], 'xtick', [ 1 : size( bar_img, 1 ) / 2 : size( bar_img, 1 ) + 1 ], 'xticklabel', { '0', '\pi/2', '\pi' } )
% set( gca, 'ylim', [ 0, 1.1 * max( hist_angle )] )
% ylabel( '# of units' )
% xlabel( 'Preferred Orientation (rad)' )
% title( [ 'Lower hierarchy' ] )
% % subplot( 1, 2, 2 )
% % % hist_angle = hist_angle_2{ 1, fn }( t, : );
% % hist_angle = [ hist_angle_2{ 1, fn }( t, 5 : -1 : 1 ), hist_angle_2{ 1, fn }( t, 8 : -1 : 6 ) ];
% % bar( hist_angle, 1, 'k' )
% % set( gca, 'xlim', [ 0, size( bar_img, 1 ) + 1 ], 'xtick', [ 1 : size( bar_img, 1 ) / 2 : size( bar_img, 1 ) + 1 ], 'xticklabel', { '0', '\pi/2', '\pi' } )
% % set( gca, 'ylim', [ 0, 1.1 * max( hist_angle )] )
% % ylabel( '# of units' )
% % xlabel( 'Preferred Orientation (rad)' )
% % title( [ 'Upper hierarchy' ] )
% clear hist_angle
% clear fn
% 
% 
% for fn = 2
%     for h = 1 : 2
%         figure( 'position', [ 100, 100, 400, 500 ] )
%         ct_k = 0;
%         for k = [ 0 * 16 + [ 1 : 2 ], 1 * 16 + [ 1 : 2 ], 2 * 16 + [ 1 : 2 ], 3 * 16 + [ 1 : 2 ] ]
%             ct_k = ct_k + 1;
%             for tt = 1 : 5
%                 subplot( 8, 5, ( ct_k - 1 ) * 5 + tt )
%                 t_img = transpose( reshape( rf{ h, fn }( :, k, tt ), [ 96, 64 ] ) );
%                 imagesc( t_img, [ 0, 1 ] )
%                 colormap( gray )
%                 axis image
%                 set( gca, 'xtick', [], 'ytick', [] )
%                 clear t_img
%             end; clear tt
%         end; clear k
%     end; clear h
% end; clear fn
% 
% 
% t = 5;
% idx_max_Z_1 = cell( 1, 3 );
% idx_max_Z_2 = cell( 1, 3 );
% for fn = 1 : 3
%     for r = 1 : 8
%         [ ~, loc ] = max( Z_1{ r, fn }( :, :, t ), [], 1 );
%         idx_max_Z_1{ 1, fn } = [ idx_max_Z_1{ 1, fn }; loc ];
%         [ ~, loc ] = max( Z_2{ r, fn }( :, :, t ), [], 1 );
%         idx_max_Z_2{ 1, fn } = [ idx_max_Z_2{ 1, fn }; loc ];
%         clear loc
%     end; clear r
% end; clear fn
% clear t
% colors = hsv( 8 );
% fn = 2;
% figure( 'position', [ 100, 100, 700, 200 ] )
% ct_unit = 0;
% for unit = [ 1 : 16 : 64 ]
%     ct_unit = ct_unit + 1;
%     subplot( 1, 4, ct_unit )
%     hold on
%     ct = 0;
%     for r = [ 5 : -1 : 1, 8 : -1 : 6 ]
%         ct = ct + 1;
%         plot( [ 0 : 5 ], [ 0; squeeze( Z_1{ r, fn }( idx_max_Z_1{ 1, fn }( r, unit ), unit, : ) ) ], '-', 'color', colors( ct, : ), 'linewidth', 2 )
%     end; clear r ct
%     set( gca, 'xlim', [ 0.5, 5.5 ], 'ylim', [ 0.4, 1 ] )
%     xlabel( 'Time (step)' )
%     ylabel( 'Response' )
%     if ct_unit == 4
%         legend( '0', '\pi/8', '2\pi/8', '3\pi/8', '\pi/2', '5\pi/8', '6\pi/8', '7\pi/8' )
%     end
% end; clear unit ct_unit
% 
