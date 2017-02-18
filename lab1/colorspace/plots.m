% test your code by using this simple script

clear
clc
close all

I = imread('peppers.png');
J = ConvertColorSpace(I,'ycbcr');
H = J(:,:,1);
S = J(:,:,2);
V = J(:,:,3);

h = H(:);
s = S(:);
v = V(:);

C = double(reshape(I,[],size(I,3),1))/255;

return
close ALL
figure;
ha = axes;
scatter3(h,s,v, 10, C,'filled');

%#projection on the X-Z plane
view(ha,[0,0])
print('1','-dpng')

%#projection on the Y-Z plane
view(ha,[90,0])
savefig('2.png')

%#projection on the X-Y plane
view(ha,[0,90])
savefig('2.png')