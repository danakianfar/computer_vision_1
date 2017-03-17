clear, clc

% Read image
im1 = imread('../Images/image2.jpeg');

imshow(im1)
figure

% Read black noisy patch from image
data = im1(1:80,70:150);

% Show selected patch
subplot(2,1,1)
imshow(data)

% Cast values from uint8 to double
data = double(data(:));

%Normalize data for mean and std
data = (data(:) - mean(data(:))) / std(data(:));
disp('Kolmogorov-Smirnov Test under H0 = data comes from standard normal distribution')
disp('1 if rejects H0 - 0 if fails to reject H0')
disp(kstest(data))

% Plot empirical and theoretical CDF
subplot(2,1,2)
[f,x_values] = ecdf(data);
F = plot(x_values,f);
set(F,'LineWidth',2);
hold on;
G = plot(x_values,normcdf(x_values,0,1),'r-');
set(G,'LineWidth',2);
legend([F G],...
       'Empirical CDF','Standard Normal CDF',...
       'Location','SE');
%%
% Read image
im1 = imread('../Images/spn.png');

imshow(im1)
figure

% Read black noisy patch from image
data = im1(1:80,1:80);

% Show selected patch
subplot(2,1,1)
imshow(data)

% Cast values from uint8 to double
data = double(data(:));

%Normalize data for mean and std
data = (data(:) - mean(data(:))) / std(data(:));
disp('Kolmogorov-Smirnov Test under H0 = data comes from standard normal distribution')
disp('1 if rejects H0 - 0 if fails to reject H0')
disp(kstest(data))

% Plot empirical and theoretical CDF
subplot(2,1,2)
[f,x_values] = ecdf(data);
F = plot(x_values,f);
set(F,'LineWidth',2);
hold on;
G = plot(x_values,normcdf(x_values,0,1),'r-');
set(G,'LineWidth',2);
legend([F G],...
       'Empirical CDF','Standard Normal CDF',...
       'Location','SE');