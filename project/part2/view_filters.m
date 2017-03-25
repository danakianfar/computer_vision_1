
figure(1) ; clf ; colormap gray ;
vl_imarraysc(squeeze(net.params(1).value),'spacing',2)
axis equal ;
title('filters in the first layer') ;

%%


figure(2) ; clf ; colormap gray ;
vl_imarraysc(squeeze(nets.fine_tuned.layers{1}.weights{1}),'spacing',2)
axis equal ;
title('filters in the first layer') ;
