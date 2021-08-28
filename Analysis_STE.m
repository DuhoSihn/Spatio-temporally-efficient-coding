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
io_f{ 2, 1 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, bottom-up
io_f{ 2, 1 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, bottom-up
io_f{ 2, 2 }{ 1, 1 } = io_f{ 2, 1 }{ 1, 2 };% input, top-down
io_f{ 2, 2 }{ 1, 2 } = io_f{ 2, 1 }{ 1, 1 };% output, top-down


nZ = [];
for h = 1 : size( io_f, 1 )
    totalZ = [];
    for p = 1 : size( io_f{ h, 1 }, 1 )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end; clear p
    nZ( h, 1 ) = length( unique( totalZ ) );
    clear totalZ
end; clear h


%% Synaptic weightmagnitude on the hierarchy 1
% %
% % % clear all; close all; clc
% %
% %
% % s_W_f = {};
% % ms_W_f = [];
% %
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% figure( 'position', [ 100, 100, 250, 200 ] )
% fn = 1;
% semilogy( fn - 0.1, s_W_f{ fn, 1 }( 1 ), '+', 'color', [ 1, 0.5, 0.5 ], 'markersize', 3 )
% hold on
% semilogy( fn + 0.1, s_W_f{ fn, 2 }( 1 ), '+', 'color', [ 0.5, 0, 1 ], 'markersize', 3 )
% clear fn
% for fn = 1 : 3
%     semilogy( fn - 0.1, s_W_f{ fn, 1 }, '+', 'color', [ 1, 0.5, 0.5 ], 'markersize', 3 )
% end; clear h
% for fn = 1 : 3
%     semilogy( fn + 0.1, s_W_f{ fn, 2 }, '+', 'color', [ 0.5, 0, 1 ], 'markersize', 3 )
% end; clear h
% semilogy( [ 1 : 3 ] - 0.1, ms_W_f( :, 1 ), 'sk', 'markersize', 10 )
% semilogy( [ 1 : 3 ] + 0.1, ms_W_f( :, 2 ), 'sk', 'markersize', 10 )
% set( gca, 'xlim', [ 0.5, 3 + 0.5 ], 'xtick', [ 1 : 3 ], 'xticklabel', { '10', '30', '100' } )
% ylabel( '( \Sigma_{i} w_{ij}^{2} )^{1/2}' )
% xlabel( '\lambda' )
% title( 'Synaptic weight magnitude' )
% legend( 'Bottom-up', 'Top-down', 'location', 'southeast' )
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
% % img = {};
% %
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% % save( 'Final_Results_Trajectories.mat', 'Z_1', 'img' )
% %
% %
% load( 'Final_Results_Trajectories.mat' )
%
%
% figure( 'position', [ 100, 100, 600, 200 ])
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
% subplot( 1, 4, 1 )
% imagesc( t_img, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'ytick', [], 'xtick', [ 32, 64 + 64 ], 'xticklabel', { 'Original', 'Reconstructed' } )
% ylabel( 'Time (a.u.)' )
% title( [ '\lambda = 30' ] )
% clear fn t_img t_img1 t_img2
%
% for fn = 1 : 3
%     subplot( 1, 4, fn + 1 )
%     imagesc( Z_1{ fn, 1 }, [ 0, 1 ] )
%     colormap( gca, turbo )
%     xlabel( 'Unit' )
%     ylabel( 'Time (a.u.)' )
%     if fn == 1
%         title( [ '\lambda = 10' ] )
%     elseif fn == 2
%         title( [ '\lambda = 30' ] )
%     elseif fn == 3
%         title( [ '\lambda = 100' ] )
%     end
% end; clear h
%
%
% figure
% imagesc( NaN, [ 0, 1 ] )
% colormap( gca, turbo )
% colorbar
%

%% Deviant Trajectories
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
% % for fn = 1 : 2
% % 
% %     if fn == 1
% %         load( 'Results_lambda0.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda100000.mat' )
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
% % save( 'Final_Results_Deviant_Trajectories.mat', 'Z_1', 'Z_2', 'img' )
% %
% %
% load( 'Final_Results_Deviant_Trajectories.mat' )
% 
% 
% figure( 'position', [ 100, 100, 800, 200 ])
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
% subplot( 1, 5, 1 )
% imagesc( t_img, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'ytick', [], 'xtick', [ 32, 64 + 64 ], 'xticklabel', { 'Original', 'Reconstructed' } )
% ylabel( 'Time (a.u.)' )
% title( [ '\lambda = 10^5' ] )
% clear fn t_img t_img1 t_img2
% 
% for fn = 1 : 2
%     subplot( 1, 5, 1 + 2 * ( fn - 1 ) + 1 )
%     imagesc( Z_1{ fn, 1 }, [ 0, 1 ] )
%     colormap( gca, turbo )
%     xlabel( 'Unit' )
%     ylabel( 'Time (a.u.)' )
%     if fn == 1
%         title( [ '\lambda = 0, hierarchy 1' ] )
%     elseif fn == 2
%         title( [ '\lambda = 10^5, hierarchy 1' ] )
%     end
%     subplot( 1, 5, 1 + 2 * ( fn - 1 ) + 2 )
%     imagesc( Z_2{ fn, 1 }, [ 0, 1 ] )
%     colormap( gca, turbo )
%     xlabel( 'Unit' )
%     ylabel( 'Time (a.u.)' )
%     if fn == 1
%         title( [ '\lambda = 0, hierarchy 2' ] )
%     elseif fn == 2
%         title( [ '\lambda = 10^5, hierarchy 2' ] )
%     end
% end; clear h
% 
% 
% % figure
% % imagesc( NaN, [ 0, 1 ] )
% % colormap( gca, turbo )
% % colorbar
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
% % dist_X = [];
% % for n = 1 : size( X, 1 )
% %     dist_X( n, : ) = sqrt( sum( bsxfun( @minus, X( n, : ), X ) .^ 2, 2 ) );
% %     if mod( n, 100 ) == 0
% %         disp( [ 'X ', num2str( n ) ] )
% %     end
% % end; clear n
% % 
% % 
% % dist_Z_1 = [];
% % dist_Z_2 = [];
% % traj_Z_1 = [];
% % traj_Z_2 = [];
% % 
% % for fn = 1 : 3
% % 
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% % save( 'Final_Results_Distance.mat', 'dist_X', 'dist_Z_1', 'dist_Z_2', 'traj_Z_1', 'traj_Z_2', 'traj_dist_Z_1', 'traj_dist_Z_2' )
% % 
% % 
% % load( 'Final_Results_Distance.mat' )
% % 
% % 
% % % -------------------------------------------------------------------------
% % 
% % 
% % corr_100 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 3
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
% %     sort_data = sort_data( round( 0.05 * size( dist_X, 1 ) ) );
% %     sort_idx = dist_X( n, : ) <= sort_data;
% %     if sum( sort_idx, 2 ) > round( 0.05 * size( dist_X, 1 ) )
% %         sort_idx1 = dist_X( n, : ) < sort_data;
% %         sort_idx2 = dist_X( n, : ) == sort_data;
% %         find_sort_idx2 = find( sort_idx2 );
% %         sort_idx2( find_sort_idx2( round( 0.05 * size( dist_X, 1 ) ) - sum( sort_idx1, 2 ) + 1 : end ) ) = false;
% %         sort_idx = sort_idx1 | sort_idx2;
% %         clear sort_idx1 sort_idx2 find_sort_idx2
% %     end
% %     t_dist_X( n, : ) = dist_X( n, sort_idx );
% %     for fn = 1 : 3
% %         t_dist_Z_1( n, :, fn ) = dist_Z_1( n, sort_idx, fn );
% %         t_dist_Z_2( n, :, fn ) = dist_Z_2( n, sort_idx, fn );
% %     end; clear fn
% %     clear sort_data sort_idx
% %     if mod( n, 100 ) == 0
% %         disp( [ num2str( n ) ] )
% %     end
% % end; clear n
% % 
% % corr_5 = [];
% % for n = 1 : size( dist_X, 1 )
% %     for fn = 1 : 3
% %         corr_5( fn, 1, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_1( n, :, fn ) ) );
% %         corr_5( fn, 2, n ) = corr( transpose( t_dist_X( n, : ) ), transpose( t_dist_Z_2( n, :, fn ) ) );
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
% %     for fn = 1 : 3
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
% %     for fn = 1 : 3
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
% % for fn = 1 : 3
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
% % save( 'Final_Results_Distance.mat', 'corr_100', 'corr_5', 'corr_1', 'ratio_traj2min' )
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
% %     load( 'Results_lambda10.mat' )
% % elseif fn == 2
% %     load( 'Results_lambda30.mat' )
% % elseif fn == 3
% %     load( 'Results_lambda100.mat' )
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
% % save( 'Final_Results_Distance.mat', 'corr_100', 'corr_5', 'corr_1', 'ratio_traj2min', 'collected_samples', 'dist_X', 'dist_Z_1', 'dist_Z_2', 'images' )
% %
% %
% load( 'Final_Results_Distance.mat' )
% 
% 
% m_corr_100 = mean( corr_100, 3, 'omitnan' );
% s_corr_100 = std( corr_100, 0, 3, 'omitnan' );
% m_corr_5 = mean( corr_5, 3, 'omitnan' );
% s_corr_5 = std( corr_5, 0, 3, 'omitnan' );
% m_corr_1 = mean( corr_1, 3, 'omitnan' );
% s_corr_1 = std( corr_1, 0, 3, 'omitnan' );
% disp( [ 'Exceptions: ', num2str( 100 * sum( sum( sum( sum( isinf( ratio_traj2min ) ) ) ) ) / prod( size( ratio_traj2min ) ) ), ' %' ] )
% ratio_traj2min( isinf( ratio_traj2min ) ) = NaN;
% m_ratio_traj2min = mean( ratio_traj2min, 3, 'omitnan' );
% s_ratio_traj2min = std( ratio_traj2min, 0, 3, 'omitnan' );
% 
% 
% figure( 'position', [ 100, 100, 250, 200 ] )
% bar( m_corr_100 )
% hold on
% for fn = 1 : 3
%     errorbar( fn - 0.15, m_corr_100( fn, 1 ), s_corr_100( fn, 1 ), 'k' )
%     errorbar( fn + 0.15, m_corr_100( fn, 2 ), s_corr_100( fn, 2 ), 'k' )
% end; clear fn
% set( gca, 'ylim', [ 0, 1 ] )
% set( gca, 'xtick', [ 1 : 3 ], 'xticklabel', { '10', '30', '100' } )
% ylabel( 'Correlation over distances' )
% xlabel( '\lambda' )
% legend( 'Hierarchy 1', 'Hierarchy 2', 'location', 'southwest' )
% title( 'Global similarity' )
% % title( '100 % of samples (N = 4212)' )
% 
% % figure( 'position', [ 100, 100, 250, 200 ] )
% % bar( m_corr_5 )
% % hold on
% % for fn = 1 : 3
% %     errorbar( fn - 0.15, m_corr_5( fn, 1 ), s_corr_5( fn, 1 ), 'k' )
% %     errorbar( fn + 0.15, m_corr_5( fn, 2 ), s_corr_5( fn, 2 ), 'k' )
% % end; clear fn
% % set( gca, 'ylim', [ 0, 1 ] )
% % set( gca, 'xtick', [ 1 : 3 ], 'xticklabel', { '10', '30', '100' } )
% % ylabel( 'Correlation over distances' )
% % xlabel( '\lambda' )
% % legend( 'Hierarchy 1', 'Hierarchy 2', 'location', 'southwest' )
% % title( 'Intermediate level similarity' )
% % % title( '5 % of samples (N = 4212 / 20)' )
% 
% figure( 'position', [ 100, 100, 250, 200 ] )
% bar( m_corr_1 )
% hold on
% for fn = 1 : 3
%     errorbar( fn - 0.15, m_corr_1( fn, 1 ), s_corr_1( fn, 1 ), 'k' )
%     errorbar( fn + 0.15, m_corr_1( fn, 2 ), s_corr_1( fn, 2 ), 'k' )
% end; clear fn
% set( gca, 'ylim', [ 0, 1 ] )
% set( gca, 'xtick', [ 1 : 3 ], 'xticklabel', { '10', '30', '100' } )
% ylabel( 'Correlation over distances' )
% xlabel( '\lambda' )
% legend( 'Hierarchy 1', 'Hierarchy 2', 'location', 'southwest' )
% title( 'Local similarity' )
% % title( 'Top 1 % neighbour samples (N = 42)' )
% 
% figure( 'position', [ 100, 100, 700, 200 ] )
% for fn = 1 : 3
%     subplot( 1, 3, fn )
%     hold on
%     errorbar( [ 1 : 9 ] - 0.1, permute( m_ratio_traj2min( fn, 1, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ), permute( s_ratio_traj2min( fn, 1, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ) )
%     errorbar( [ 1 : 9 ] + 0.1, permute( m_ratio_traj2min( fn, 2, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ), permute( s_ratio_traj2min( fn, 2, 1, 1 : 9 ), [ 3, 4, 1, 2 ] ) )
%     plot( [ 0.5, 9 + 0.5 ], [ 1, 1 ], ':k' )
%     set( gca, 'xlim', [ 0.5, 9 + 0.5 ], 'ylim', [ 0, 1.6 ] )
%     ylabel( 'Relative temporal variation' )
%     xlabel( 'Time (a.u.)' )
%     if fn == 1
%         title( [ '\lambda = 10' ] )
%     elseif fn == 2
%         title( [ '\lambda = 30' ] )
%     elseif fn == 3
%         title( [ '\lambda = 100' ] )
%     end
%     legend( 'Hierarchy 1', 'Hierarchy 2', 'location', 'northeast' )
% end; clear fn
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

%% Dimension reduction
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
% % for fn = 1 : 3
% %     
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
% %     end
% %     
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% %     
% %     nPred = 2 * size( io_f, 1 ) + 1;
% %     rX = {};
% %     for h = 1 : size( io_f, 1 )
% %         rX{ h, 1 } = zeros( 1, nZ( h ) );
% %     end; clear h
% %     
% %     Z_1{ 1, fn } = [];
% %     Z_2{ 1, fn } = [];
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_1{ 1, fn }( n, : ) = Z{ 1, 1 }( end, : );
% %         Z_2{ 1, fn }( n, : ) = Z{ 2, 1 }( end, : );
% %     end; clear n
% %     
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
% % save( 'Final_Results_Dimension_Reduction.mat', 'Z_1', 'Z_2' )
% % 
% % 
% % load( 'Final_Results_Dimension_Reduction.mat' )
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
% % tic
% % DR_X = tsne( X, 'Algorithm', 'exact' );
% % toc
% % 
% % DR_Z_1 = {};
% % DR_Z_2 = {};
% % for fn = 1 : 3
% %     tic
% %     DR_Z_1{ 1, fn } = tsne( Z_1{ 1, fn }, 'Algorithm', 'exact' );
% %     toc
% %     tic
% %     DR_Z_2{ 1, fn } = tsne( Z_2{ 1, fn }, 'Algorithm', 'exact' );
% %     toc
% %     disp( num2str( fn ) )
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Dimension_Reduction.mat', 'Z_1', 'Z_2', 'DR_X', 'DR_Z_1', 'DR_Z_2' )
% % 
% % 
% load( 'Final_Results_Dimension_Reduction.mat' )
% 
% 
% fn = 2;
% 
% dist_DR_X = sqrt( sum( bsxfun( @minus, DR_X( 5, : ), DR_X ) .^ 2, 2 ) );
% dist_DR_X = dist_DR_X / max( dist_DR_X );
% dist_DR_X( 5 ) = 1;
% 
% % idx_samples = randperm( size( DR_X, 1 ), 210 );
% idx_samples = randperm( size( DR_X, 1 ), 4212 );
% 
% figure( 'position', [ 100, 100, 1500, 500 ] )
% colors = colormap( turbo );
% colors = colors( ceil( length( colors ) * dist_DR_X ), : );
% colors( 5, : ) = [ 0, 0, 0 ];
% subplot( 1, 3, 1 )
% hold on
% for n = 1 : size( DR_X, 1 )
%     if ismember( n, idx_samples )
%         plot( DR_X( n, 1 ), DR_X( n, 2 ), '.', 'color', colors( n, : ) )
%     end
% end; clear n
% plot( DR_X( 5, 1 ), DR_X( 5, 2 ), '+', 'color', colors( 5, : ), 'markersize', 20 )
% colorbar
% axis tight
% set( gca, 'xtick', [], 'ytick', [] )
% % title( 'Image' )
% subplot( 1, 3, 2 )
% hold on
% for n = 1 : size( DR_Z_1{ 1, fn }, 1 )
%     if ismember( n, idx_samples )
%         plot( DR_Z_1{ 1, fn }( n, 1 ), DR_Z_1{ 1, fn }( n, 2 ), '.', 'color', colors( n, : ) )
%     end
% end; clear n
% colorbar
% axis tight
% set( gca, 'xtick', [], 'ytick', [] )
% % title( 'Hierarchy 1' )
% subplot( 1, 3, 3 )
% hold on
% for n = 1 : size( DR_Z_2{ 1, fn }, 1 )
%     if ismember( n, idx_samples )
%         plot( DR_Z_2{ 1, fn }( n, 1 ), DR_Z_2{ 1, fn }( n, 2 ), '.', 'color', colors( n, : ) )
%     end
% end; clear n
% colorbar
% axis tight
% set( gca, 'xtick', [], 'ytick', [] )
% % title( 'Hierarchy 2' )
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

%% Familiar & Unfamiliar
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
% % Y = double( Y );
% %
% %
% % hist_X = {};
% % hist_Y = {};
% %
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% % save( 'Final_Results_Familiar_Unfamiliar.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y' )
% %
% %
% % load( 'Final_Results_Familiar_Unfamiliar.mat' )
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
% % Y = double( Y );
% %
% %
% % fn = 2;
% %
% % if fn == 1
% %     load( 'Results_lambda10.mat' )
% % elseif fn == 2
% %     load( 'Results_lambda30.mat' )
% % elseif fn == 3
% %     load( 'Results_lambda100.mat' )
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
% %
% %
% % save( 'Final_Results_Familiar_Unfamiliar.mat', 'hist_X', 'hist_Y', 'n_hist_X', 'n_hist_Y', 'img_X', 'img_Y', 'test_hist_X', 'test_hist_Y', 'n_test_hist_X', 'n_test_hist_Y' )
% %
% %
% load( 'Final_Results_Familiar_Unfamiliar.mat' )
%
%
% figure( 'position', [  100, 100, 350, 350 ] )
% subplot( 1, 2, 1 )
% imagesc( img_X, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Familiar' )
% subplot( 1, 2, 2 )
% imagesc( img_Y, [ 0, 1 ] )
% colormap( gca, gray )
% set( gca, 'xtick', [], 'ytick', [] )
% title( 'Unfamiliar' )
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
%         xlabel( 'Time (a.u.)' )
%     end
%     if n == 1
%         title( 'Familiar' )
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
%         xlabel( 'Time (a.u.)' )
%     end
%     if n == 1
%         title( 'Unfamiliar' )
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
% xlabel( 'Time (a.u.)' )
% title( [ 'Hierarchy 1, Familiar' ] )
%
% subplot( 2, 2, 2 )
% imagesc( transpose( n_hist_Y{ 1, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 1, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 1, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (a.u.)' )
% title( [ 'Hierarchy 1, Unfamiliar' ] )
%
% subplot( 2, 2, 3 )
% imagesc( transpose( n_hist_X{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (a.u.)' )
% title( [ 'Hierarchy 2, Familiar' ] )
%
% subplot( 2, 2, 4 )
% imagesc( transpose( n_hist_Y{ 2, fn } ), [ 0, 0.2 ] )
% colormap( gca, parula )
% colorbar
% axis xy
% set( gca, 'ytick', [ 0.5, size( n_hist_X{ 2, fn }, 2 ) / 2 + 0.5, size( n_hist_X{ 2, fn }, 2 ) + 0.5 ], 'yticklabel', { '0', '0.5', '1' } )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ] )
% ylabel( 'Response' )
% xlabel( 'Time (a.u.)' )
% title( [ 'Hierarchy 2, Unfamiliar' ] )
%
% clear fn
%

%% Synthesis
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
% % Y = double( Y );
% %
% %
% % Z_1 = {};
% % img = {};
% % Z_1_c = {};
% % img_c = {};
% %
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% %
% %     sX = [];
% %     ct = 0;
% %     for n = [ 5, 7, 9, 10 ]
% %         ct = ct + 1;
% %         tX = reshape( X( n, : ), [ 96, 64 ] );
% %         tY = reshape( Y( n, : ), [ 96, 64 ] );
% %         % tX( 1 : 58, 1 : 38 ) = tY( 1 : 58, 1 : 38 );
% %         tX( 1 : 38, 1 : 26 ) = tY( 1 : 38, 1 : 26 );
% %         tX = reshape( tX, [ 1, 96 * 64 ] );
% %         sX( :, :, ( ct - 1 ) * nPred + [ 1 : nPred ] ) = repmat( tX, [ 1, 1, nPred ] );
% %         clear tX tY
% %     end; clear n ct
% %
% %     [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %
% %     Z_1_c{ fn, 1 } = Z{ 1, 1 };
% %
% %     for t = 1 : size( Z{ 1, 1 }, 1 )
% %         img_c{ fn, 1 }( t, : ) = sX( 1, :, t);
% %         Z_curr = {};
% %         for h = 1 : size( Z, 1 ) + 1
% %             if h == 1
% %                 Z_curr{ h, 1 } = sX( :, :, t );
% %             else
% %                 Z_curr{ h, 1 } = Z{ h - 1, 1 }( t, : );
% %             end
% %         end; clear h
% %         tZ = STE_f_sgm( Z_curr, io_f, W_f, b_f );
% %         img_c{ fn, 2 }( t, : ) = tZ{ 1, 1 };
% %         clear Z_curr E_curr tZ
% %     end; clear t
% %
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
% % hist_X = {};
% % hist_C = {};
% %
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% %     hist_X{ 1, fn } = zeros( nPred, nBins, size( io_f{ 1, 1 }, 1 ) );
% %     hist_X{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             for p = 1 : size( io_f{ 1, 1 }, 1 )
% %                 hist_X{ 1, fn }( t, :, p ) = hist_X{ 1, fn }( t, :, p ) + histcounts( Z{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 } ), linspace( 0, 1, nBins + 1 ) );
% %             end; clear p
% %             hist_X{ 2, fn }( t, : ) = hist_X{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
% %         end; clear t
% %     end; clear n
% %
% %     hist_C{ 1, fn } = zeros( nPred, nBins, size( io_f{ 1, 1 }, 1 ) );
% %     hist_C{ 2, fn } = zeros( nPred, nBins );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         tX = reshape( X( n, : ), [ 96, 64 ] );
% %         tY = reshape( Y( n, : ), [ 96, 64 ] );
% %         % tX( 1 : 58, 1 : 38 ) = tY( 1 : 58, 1 : 38 );
% %         tX( 1 : 38, 1 : 26 ) = tY( 1 : 38, 1 : 26 );
% %         tX = reshape( tX, [ 1, 96 * 64 ] );
% %         sX( :, :, [ 1 : nPred ] ) = repmat( tX, [ 1, 1, nPred ] );
% %         clear tX tY
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         for t = 1 : nPred
% %             for p = 1 : size( io_f{ 1, 1 }, 1 )
% %                 hist_C{ 1, fn }( t, :, p ) = hist_C{ 1, fn }( t, :, p ) + histcounts( Z{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 } ), linspace( 0, 1, nBins + 1 ) );
% %             end; clear p
% %             hist_C{ 2, fn }( t, : ) = hist_C{ 2, fn }( t, : ) + histcounts( Z{ 2, 1 }( t, : ), linspace( 0, 1, nBins + 1 ) );
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
% % n_hist_C = {};
% % for fn = 1 : 3
% %     n_hist_X{ 1, fn } = bsxfun( @rdivide, hist_X{ 1, fn }, sum( hist_X{ 1, fn }, 2 ) );
% %     n_hist_X{ 2, fn } = bsxfun( @rdivide, hist_X{ 2, fn }, sum( hist_X{ 2, fn }, 2 ) );
% %     n_hist_C{ 1, fn } = bsxfun( @rdivide, hist_C{ 1, fn }, sum( hist_C{ 1, fn }, 2 ) );
% %     n_hist_C{ 2, fn } = bsxfun( @rdivide, hist_C{ 2, fn }, sum( hist_C{ 2, fn }, 2 ) );
% % end; clear fn
% %
% %
% % save( 'Final_Results_Synthesis.mat', 'Z_1', 'img', 'Z_1_c', 'img_c', 'hist_X', 'hist_C', 'n_hist_X', 'n_hist_C' )
% %
% %
% % load( 'Final_Results_Synthesis.mat' )
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
% % Y = double( Y );
% % 
% % 
% % dist_X_C = {};
% % 
% % for fn = 1 : 3
% %     
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% %     Z_X{ 1, 1 } = NaN( nPred, nZ( 1 ), size( X, 1 ) );
% %     Z_X{ 2, 1 } = NaN( nPred, nZ( 2 ), size( X, 1 ) );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         sX( :, :, [ 1 : nPred ] ) = repmat( X( n, : ), [ 1, 1, nPred ] );
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_X{ 1, 1 }( :, :, n ) = Z{ 1, 1 };
% %         Z_X{ 2, 1 }( :, :, n ) = Z{ 2, 1 };
% %     end; clear n
% %     
% %     Z_C{ 1, 1 } = NaN( nPred, nZ( 1 ), size( X, 1 ) );
% %     Z_C{ 2, 1 } = NaN( nPred, nZ( 2 ), size( X, 1 ) );
% %     for n = 1 : size( X, 1 )
% %         sX = [];
% %         tX = reshape( X( n, : ), [ 96, 64 ] );
% %         tY = reshape( Y( n, : ), [ 96, 64 ] );
% %         % tX( 1 : 58, 1 : 38 ) = tY( 1 : 58, 1 : 38 );
% %         tX( 1 : 38, 1 : 26 ) = tY( 1 : 38, 1 : 26 );
% %         tX = reshape( tX, [ 1, 96 * 64 ] );
% %         sX( :, :, [ 1 : nPred ] ) = repmat( tX, [ 1, 1, nPred ] );
% %         clear tX tY
% %         [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %         Z_C{ 1, 1 }( :, :, n ) = Z{ 1, 1 };
% %         Z_C{ 2, 1 }( :, :, n ) = Z{ 2, 1 };
% %     end; clear n
% %     
% %     dist_X_C{ 1, fn } = NaN( nPred, size( X, 1 ), size( io_f{ 1, 1 }, 1 ) );
% %     dist_X_C{ 2, fn } = NaN( nPred, size( X, 1 ) );
% %     for t = 1 : nPred
% %         for p = 1 : size( io_f{ 1, 1 }, 1 )
% %             t_dist_X_X = permute( sqrt( sum( bsxfun( @minus, permute( Z_X{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 }, : ), [ 3, 2, 1 ] ), Z_X{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 }, : ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %             t_dist_X_X = sort( t_dist_X_X, 2 );
% %             t_dist_X_X = mean( t_dist_X_X( :, 2 : 43 ), 2 );% 1 percent of neighboring samples
% %             dist_X_C{ 1, fn }( t, :, p ) = permute( sqrt( sum( ( Z_X{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 }, : ) - Z_C{ 1, 1 }( t, io_f{ 1, 1 }{ p, 2 }, : ) ) .^ 2, 2 ) ), [ 3, 1, 2 ] ) ./ t_dist_X_X;
% %             clear t_dist_X_X
% %         end; clear p
% %         
% %         t_dist_X_X = permute( sqrt( sum( bsxfun( @minus, permute( Z_X{ 2, 1 }( t, :, : ), [ 3, 2, 1 ] ), Z_X{ 2, 1 }( t, :, : ) ) .^ 2, 2 ) ), [ 1, 3, 2 ] );
% %         t_dist_X_X = sort( t_dist_X_X, 2 );
% %         t_dist_X_X = mean( t_dist_X_X( :, 2 : 43 ), 2 );% 1 percent of neighboring samples
% %         dist_X_C{ 2, fn }( t, : ) = permute( sqrt( sum( ( Z_X{ 2, 1 }( t, :, : ) - Z_C{ 2, 1 }( t, :, : ) ) .^ 2, 2 ) ), [ 3, 1, 2 ] ) ./ t_dist_X_X;
% %         clear t_dist_X_X
% %     end; clear t
% %     
% %     dist_X_C{ 1, fn }( isinf( dist_X_C{ 1, fn } ) ) = NaN;
% %     dist_X_C{ 2, fn }( isinf( dist_X_C{ 2, fn } ) ) = NaN;
% %     
% %     clear Z_X Z_C
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
% % save( 'Final_Results_Synthesis.mat', 'Z_1', 'img', 'Z_1_c', 'img_c', 'hist_X', 'hist_C', 'n_hist_X', 'n_hist_C', 'dist_X_C' )
% %
% %
% load( 'Final_Results_Synthesis.mat' )
% 
% 
% fn = 2;
% figure( 'position', [ 100, 100, 550, 300 ] )
% ct_t = 0;
% for t = 1 : 5
%     ct_t = ct_t + 1;
%     subplot( 4, 5, t )
%     imagesc( transpose( reshape( img{ fn, 1 }( t, : ), [ 96, 64 ] ) ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
%     subplot( 4, 5, 5 + t )
%     imagesc( transpose( reshape( img{ fn, 2 }( t, : ), [ 96, 64 ] ) ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
%     subplot( 4, 5, 10 + t )
%     imagesc( transpose( reshape( img_c{ fn, 2 }( t, : ), [ 96, 64 ] ) ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
%     subplot( 4, 5, 15 + t )
%     imagesc( transpose( reshape( img_c{ fn, 1 }( t, : ), [ 96, 64 ] ) ), [ 0, 1 ] )
%     colormap( gca, gray )
%     set( gca, 'xtick', [], 'ytick', [] )
% end; clear t ct_t
% clear fn
% 
% 
% fn = 2;
% 
% figure( 'position', [ 100, 100, 300, 300 ] )
% for p = 1 : size( io_f{ 1, 1 }, 1 )
%     if p == 1
%         subplot( 2, 2, 1 )
%     elseif p == 2
%         subplot( 2, 2, 3 )
%     elseif p == 3
%         subplot( 2, 2, 2 )
%     elseif p == 4
%         subplot( 2, 2, 4 )
%     end
%     h = bar( transpose( [ n_hist_X{ 1, fn }( end, :, p ); n_hist_C{ 1, fn }( end, :, p ) ] ) );
%     set( h(1), 'facecolor', [ 0, 0.6, 1 ], 'edgecolor', [ 0, 0.6, 1 ] )
%     set( h(2), 'facecolor', [ 1, 0.6, 0 ], 'edgecolor', [ 1, 0.6, 0 ] )
%     clear h
%     set( gca, 'ylim', [ 0, 0.25 ] )
%     set( gca, 'ytick', [ 0 : 0.05 : 0.25 ])
%     set( gca, 'xtick', [ 1, ( size( n_hist_X{ 1, fn }, 2 ) / 2 ) + 0.5, size( n_hist_X{ 1, fn }, 2 ) ], 'xticklabel', { '0', '0.5', '1' } )
%     ylabel( 'Proportion' )
%     xlabel( 'Response' )
% end; clear p
% 
% figure( 'position', [ 100, 100, 300, 300 ] )
% h = bar( transpose( [ n_hist_X{ 2, fn }( end, : ); n_hist_C{ 2, fn }( end, : ) ] ) );
% set( h(1), 'facecolor', [ 0, 0.6, 1 ], 'edgecolor', [ 0, 0.6, 1 ] )
% set( h(2), 'facecolor', [ 1, 0.6, 0 ], 'edgecolor', [ 1, 0.6, 0 ] )
% clear h
% set( gca, 'ylim', [ 0, 0.25 ] )
% set( gca, 'ytick', [ 0 : 0.05 : 0.25 ])
% set( gca, 'xtick', [ 1, ( size( n_hist_X{ 2, fn }, 2 ) / 2 ) + 0.5, size( n_hist_X{ 2, fn }, 2 ) ], 'xticklabel', { '0', '0.5', '1' } )
% ylabel( 'Proportion' )
% xlabel( 'Response' )
% legend( 'Familiar', 'Partially unfamiliar' )
% 
% clear fn
% 
% 
% m_dist_X_C = {};
% s_dist_X_C = {};
% for fn = 1 : 3
%     m_dist_X_C{ 1, fn } = permute( mean( dist_X_C{ 1, fn }, 2, 'omitnan' ), [ 1, 3, 2 ] );
%     s_dist_X_C{ 1, fn } = permute( std( dist_X_C{ 1, fn }, 0, 2, 'omitnan' ), [ 1, 3, 2 ] );
%     m_dist_X_C{ 2, fn } = mean( dist_X_C{ 2, fn }, 2, 'omitnan' );
%     s_dist_X_C{ 2, fn } = std( dist_X_C{ 2, fn }, 0, 2, 'omitnan' );
% end; clear fn
% 
% 
% figure( 'position', [ 100, 100, 400, 400 ] )
% for p = 1 : size( io_f{ 1, 1 }, 1 )
%     if p == 1
%         subplot( 2, 2, 1 )
%     elseif p == 2
%         subplot( 2, 2, 3 )
%     elseif p == 3
%         subplot( 2, 2, 2 )
%     elseif p == 4
%         subplot( 2, 2, 4 )
%     end
%     hold on
%     for fn = 1 : 3
%         errorbar( [ 1 : 2 * size( io_f, 1 ) + 1 ] + ( fn - 1 ) * 0.1 , m_dist_X_C{ 1, fn }( :, p ), s_dist_X_C{ 1, fn }( :, p ) )
%     end; clear fn
%     plot( [ 0.5, 2 * size( io_f, 1 ) + 1 + 0.5 ], [ 1, 1 ], ':k' )
%     set( gca, 'xlim', [ 0.5, 2 * size( io_f, 1 ) + 1 + 0.5 ], 'ylim', [ 0, 3.5 ] )
%     set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ], 'ytick', [ 1 : 3 ] )
%     ylabel( 'Relative temporal variation' )
%     xlabel( 'Time (a.u.)' )
% end; clear p
% 
% figure( 'position', [ 100, 100, 300, 300 ] )
% hold on
% for fn = 1 : 3
%     errorbar( [ 1 : 2 * size( io_f, 1 ) + 1 ] + ( fn - 1 ) * 0.1 , m_dist_X_C{ 2, fn }, s_dist_X_C{ 2, fn } )
% end; clear fn
% plot( [ 0.5, 2 * size( io_f, 1 ) + 1 + 0.5 ], [ 1, 1 ], ':k' )
% set( gca, 'xlim', [ 0.5, 2 * size( io_f, 1 ) + 1 + 0.5 ], 'ylim', [ 0, 3.5 ] )
% set( gca, 'xtick', [ 1 : 2 * size( io_f, 1 ) + 1 ], 'ytick', [ 1 : 3 ] )
% ylabel( 'Relative temporal variation' )
% xlabel( 'Time (a.u.)' )
% legend( '\lambda = 10', '\lambda = 30', '\lambda = 100' )
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
% % for fn = 1 : 3
% %
% %     if fn == 1
% %         load( 'Results_lambda10.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda30.mat' )
% %     elseif fn == 3
% %         load( 'Results_lambda100.mat' )
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
% %         for t = 1 : nPred
% %             Z_1{ r, fn }( :, :, t ) = Z{ 1, 1 }( ( t - 1 ) * size( bar_img{ 1, 1 }, 3 ) + [ 1 : size( bar_img{ 1, 1 }, 3 ) ], : );
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
% % for fn = 1 : 3
% %     for r = 1 : size( Z_1, 1 )
% %         for t = 1 : 2 * size( io_f, 1 ) + 1
% %             max_Z_1{ 1, fn }( r, :, t ) = max( Z_1{ r, fn }( :, :, t ), [], 1 );
% %         end; clear t
% %     end; clear r
% % end; clear fn
% %
% %
% % max_angle = {};
% % for fn = 1 : 3
% %     for t = 1 : 2 * size( io_f, 1 ) + 1
% %         [ ~, max_angle{ 1, fn }( t, : ) ] = max( max_Z_1{ 1, fn }( :, :, t ), [], 1 );
% %     end; clear t
% % end; clear fn
% %
% %
% % hist_angle = {};
% % for fn = 1 : 3
% %     for t = 1 : 2 * size( io_f, 1 ) + 1
% %         hist_angle{ 1, fn }( t, : ) = histcounts( max_angle{ 1, fn }( t, : ), [ 0.5 : 1 : size( bar_img, 1 ) + 0.5 ] );
% %     end; clear t
% % end; clear fn
% %
% %
% % save( 'Final_Results_Cardinal_Rule', 'bar_img', 'Z_1', 'max_Z_1', 'max_angle', 'hist_angle' )
% %
% %
% load( 'Final_Results_Cardinal_Rule.mat' )
% 
% 
% figure( 'position', [ 100, 100, 600, 200 ] )
% ct_r = 0;
% for r = [ 5 : -1 : 1, 8 : -1 : 6 ]%1 : size( bar_img, 1 )
%     ct_r = ct_r + 1;
%     subplot( 2, size( bar_img, 1 ) / 2, ct_r )
%     t_img = transpose( bar_img{ r, 1 }( :, :, round( size( bar_img{ r, 1 }, 3 ) / 2 ) ) );
%     imagesc( t_img, [ 0, 1 ] )
%     colormap( gca, 'gray' )
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
% figure( 'position', [ 100, 100, 600, 200 ] )
% for fn = 1 : 3
%     subplot( 1, 3, fn )
%     % bar( hist_angle{ 1, fn }( t, : ), 1, 'k' )
%     bar( [ hist_angle{ 1, fn }( t, 5 : -1 : 1 ), hist_angle{ 1, fn }( t, 8 : -1 : 6 ) ], 1, 'k' )
%     set( gca, 'xlim', [ 0, size( bar_img, 1 ) + 1 ], 'xtick', [ 1 : size( bar_img, 1 ) / 2 : size( bar_img, 1 ) + 1 ], 'xticklabel', { '0', '\pi/2', '\pi' } )
%     ylabel( '# of units' )
%     xlabel( 'Preferred Orientation (rad)' )
%     if fn == 1
%         title( [ '\lambda = 10' ] )
%     elseif fn == 2
%         title( [ '\lambda = 30' ] )
%     elseif fn == 3
%         title( [ '\lambda = 100' ] )
%     end
% end; clear fn
% 
% 
% figure( 'position', [ 100, 100, 600, 200 ] )
% for fn = 1 : 3
%     subplot( 1, 3, fn )
%     % bar( mean( hist_angle{ 1, fn }, 1 ), 1, 'k' )
%     bar( [ mean( hist_angle{ 1, fn }( :, 5 : -1 : 1 ), 1 ), mean( hist_angle{ 1, fn }( :, 8 : -1 : 6 ), 1 ) ], 1, 'k' )
%     set( gca, 'xlim', [ 0, size( bar_img, 1 ) + 1 ], 'xtick', [ 1 : size( bar_img, 1 ) / 2 : size( bar_img, 1 ) + 1 ], 'xticklabel', { '0', '\pi/2', '\pi' } )
%     ylabel( '# of units' )
%     xlabel( 'Preferred Orientation (rad)' )
%     if fn == 1
%         title( [ '\lambda = 10' ] )
%     elseif fn == 2
%         title( [ '\lambda = 30' ] )
%     elseif fn == 3
%         title( [ '\lambda = 100' ] )
%     end
% end; clear fn
% 
