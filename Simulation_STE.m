% Simulation_STE
clear all; close all; clc



%% Data & Parameters

load( 'vanHateren16_dataset.mat' )
X = double( permute( reshape( data, [ 96 * 64, 4212 ] ), [ 2, 1 ] ) );
X( X > 2000 ) = 2000;
X( X < 0 ) = 0;
X = X / 2000;
clear data

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

hl_f = {};
hl_f{ 1, 1 }{ 1, 1 } = [];% bottom-up
hl_f{ 1, 1 }{ 2, 1 } = [];% bottom-up
hl_f{ 1, 1 }{ 3, 1 } = [];% bottom-up
hl_f{ 1, 1 }{ 4, 1 } = [];% bottom-up
hl_f{ 1, 2 }{ 1, 1 } = [ 2 * 64; 16 * 64 ];% top-down
hl_f{ 1, 2 }{ 2, 1 } = [ 2 * 64; 16 * 64 ];% top-down
hl_f{ 1, 2 }{ 3, 1 } = [ 2 * 64; 16 * 64 ];% top-down
hl_f{ 1, 2 }{ 4, 1 } = [ 2 * 64; 16 * 64 ];% top-down
hl_f{ 2, 1 }{ 1, 1 } = [];% bottom-up
hl_f{ 2, 2 }{ 1, 1 } = [];% top-down

nH = size( io_f, 1 );
nZ = [];
for h = 1 : size( io_f, 1 )
    totalZ = [];
    for p = 1 : size( io_f{ h, 1 }, 1 )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end; clear p
    nZ( h, 1 ) = length( unique( totalZ ) );
    clear totalZ
end; clear h

kWidth = nan( nH, 1 );
for h = 1 : nH
    kWidth( h, 1 ) = 0.1 * sqrt( nZ( h ) );
end; clear h

miniBatchSize = 40;
nPred = 2 * size( io_f, 1 ) + 1;
nMaxIter = repmat( 10000, [ 5, 1 ] );

N_iter = 1;


%%

lambda = 0;

results = {};
for iter = 1 : N_iter

    tic
    % [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter );
    [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'GPU' );
    toc

    results{ iter, 1 } = W_f;
    results{ iter, 2 } = b_f;
    results{ iter, 3 } = LS;
    save( 'Results_lambda0.mat', 'results' )
    disp( [ '# of iter. = ', num2str( iter ) ] )
    clear W_f b_f LS
end; clear iter

clear results

clear lambda


%%

lambda = 10;

results = {};
for iter = 1 : N_iter

    tic
    % [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter );
    [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'GPU' );
    toc

    results{ iter, 1 } = W_f;
    results{ iter, 2 } = b_f;
    results{ iter, 3 } = LS;
    save( 'Results_lambda10.mat', 'results' )
    disp( [ '# of iter. = ', num2str( iter ) ] )
    clear W_f b_f LS
end; clear iter

clear results

clear lambda


%%

lambda = 30;

results = {};
for iter = 1 : N_iter

    tic
    % [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter );
    [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'GPU' );
    toc

    results{ iter, 1 } = W_f;
    results{ iter, 2 } = b_f;
    results{ iter, 3 } = LS;
    save( 'Results_lambda30.mat', 'results' )
    disp( [ '# of iter. = ', num2str( iter ) ] )
    clear W_f b_f LS
end; clear iter

clear results

clear lambda


%%

lambda = 100;

results = {};
for iter = 1 : N_iter

    tic
    % [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter );
    [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'GPU' );
    toc

    results{ iter, 1 } = W_f;
    results{ iter, 2 } = b_f;
    results{ iter, 3 } = LS;
    save( 'Results_lambda100.mat', 'results' )
    disp( [ '# of iter. = ', num2str( iter ) ] )
    clear W_f b_f LS
end; clear iter

clear results

clear lambda


%%

lambda = 100000;

results = {};
for iter = 1 : N_iter

    tic
    % [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter );
    [ W_f, b_f, LS ] = RR_STE_learn_sgm( X, io_f, hl_f, lambda, kWidth, miniBatchSize, nPred, nMaxIter, 'GPU' );
    toc

    results{ iter, 1 } = W_f;
    results{ iter, 2 } = b_f;
    results{ iter, 3 } = LS;
    save( 'Results_lambda100000.mat', 'results' )
    disp( [ '# of iter. = ', num2str( iter ) ] )
    clear W_f b_f LS
end; clear iter

clear results

clear lambda


%% Shows, LS
% 
% % clear all; close all; clc
% 
% load( 'Results_lambda0.mat' )
% % load( 'Results_lambda10.mat' )
% % load( 'Results_lambda30.mat' )
% % load( 'Results_lambda100.mat' )
% % load( 'Results_lambda100000.mat' )
% 
% for iter = 1 : size( results, 1 )
% 
%     LS = results{ iter, 3 };
% 
%     figure
%     for k = 1 : 2
%         subplot( 1, 2, k )
%         plot( LS{ k, 1 } )
%     end; clear k
% 
%     clear LS
% 
% end; clear iter
% 
% clear results
% 
