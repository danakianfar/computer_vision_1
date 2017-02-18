% test your code by using this simple script

clear
clc
close all

disp('Press any key between execution to continue to the next method');

I = imread('flowers.jpg');

J = ConvertColorSpace(I,'opponent');
%w = waitforbuttonpress;

close all
J = ConvertColorSpace(I,'rgb');
%w = waitforbuttonpress;

close all
J = ConvertColorSpace(I,'hsv');
%w = waitforbuttonpress;

close all
J = ConvertColorSpace(I,'ycbcr');
%w = waitforbuttonpress;

close all
J = ConvertColorSpace(I,'gray');