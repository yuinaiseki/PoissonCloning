% objects
bunny = load('mat/transparent/objects/bunny.mat');
bunny_I = bunny.I; % オブジェクトの元画像(RGB) 400x600x3 double
bunny_obj = bunny.composite; % 白背景のオブジェクト 400x600x3 double
bunny_alpha = bunny.alpha; % オブジェクトのアルファマスク 400x600 double
bunny_logical = bunny.logical_mask; % オブジェクトの論理マスク 400x600 Logical
bunny_N = bunny.N; % オブジェクトのN Matrix 400x600 double
bunny_composite_nan = bunny.composite_nan; % 背景をNaNにした画像 400x600x3 double



% background
old = load('mat/transparent/backgrounds/old_paper.mat');
background = old.bg; % これだけ 
